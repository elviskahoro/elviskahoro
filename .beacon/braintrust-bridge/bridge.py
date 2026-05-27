#!/usr/bin/env python3
# Beacon → Braintrust traces bridge.
#
# Braintrust's OTLP ingress only accepts traces (/otel/v1/traces), not logs —
# the sibling sidecar therefore drops Braintrust from its logs pipeline. This
# daemon closes the gap by tailing the same runtime.jsonl the sidecar reads
# and POSTing each Beacon event to Braintrust as a one-span OTLP/JSON trace.
#
# Stdlib-only on purpose (system Python 3.9 on macOS); no uv / pip dependency
# chain so the launchd agent is robust to environment drift.

from __future__ import annotations

import argparse
import json
import os
import secrets
import signal
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

DEFAULT_INPUT = Path("/Users/elvis/.beacon/endpoint/logs/runtime.jsonl")
DEFAULT_BATCH_SIZE = 16
DEFAULT_FLUSH_SECONDS = 5.0
HTTP_TIMEOUT = 10.0
SCOPE_NAME = "beacon-braintrust-bridge"
SCOPE_VERSION = "0.1"


def log(level: str, msg: str, **fields: Any) -> None:
    ts = datetime.now(timezone.utc).isoformat(timespec="milliseconds")
    extra = " ".join(f"{k}={json.dumps(v, default=str)}" for k, v in fields.items())
    line = f"{ts} {level} {msg}"
    if extra:
        line = f"{line} {extra}"
    print(line, file=sys.stderr, flush=True)


def parse_timestamp_ns(value: str) -> int:
    # Beacon writes RFC3339; Python 3.9 fromisoformat rejects the trailing Z.
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    dt = datetime.fromisoformat(value)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return int(dt.timestamp() * 1_000_000_000)


def attr_value(v: Any) -> dict:
    # OTLP/JSON AnyValue encoding. Stringify nested structures so Braintrust
    # always sees a leaf primitive (its UI flattens these into key/value rows).
    if isinstance(v, bool):
        return {"boolValue": v}
    if isinstance(v, int):
        return {"intValue": str(v)}
    if isinstance(v, float):
        return {"doubleValue": v}
    if isinstance(v, str):
        return {"stringValue": v}
    if v is None:
        return {"stringValue": ""}
    return {"stringValue": json.dumps(v, default=str, separators=(",", ":"))}


def flatten(obj: Any, prefix: str = "") -> Iterable[tuple[str, Any]]:
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = f"{prefix}.{k}" if prefix else k
            yield from flatten(v, key)
    elif isinstance(obj, list):
        # Lists are kept as JSON strings under the parent key — OTLP attributes
        # are a flat map and don't model heterogeneous arrays well enough to
        # round-trip cleanly.
        yield prefix, obj
    else:
        yield prefix, obj


def to_attributes(d: dict) -> list[dict]:
    return [{"key": k, "value": attr_value(v)} for k, v in flatten(d) if k]


def derive_trace_id(event: dict) -> str:
    sess = (event.get("session") or {}).get("id")
    if isinstance(sess, str):
        hex_only = sess.replace("-", "")
        if len(hex_only) == 32 and all(c in "0123456789abcdefABCDEF" for c in hex_only):
            return hex_only.lower()
    return secrets.token_hex(16)


def derive_span_name(event: dict) -> str:
    msg = event.get("message")
    if isinstance(msg, str) and msg.strip():
        return msg.strip()
    action = (event.get("event") or {}).get("action")
    if isinstance(action, str) and action.strip():
        return action.strip()
    return "beacon.event"


def event_to_span(event: dict) -> dict:
    ts_str = event.get("timestamp")
    if not isinstance(ts_str, str):
        # Unknown shape — skip rather than backdate.
        raise ValueError("missing timestamp")
    start_ns = parse_timestamp_ns(ts_str)
    # Beacon events are point-in-time. Give a 1µs dummy duration so the span
    # is non-degenerate in trace viewers that filter zero-duration spans.
    end_ns = start_ns + 1_000
    return {
        "traceId": derive_trace_id(event),
        "spanId": secrets.token_hex(8),
        "name": derive_span_name(event),
        "kind": 1,  # SPAN_KIND_INTERNAL
        "startTimeUnixNano": str(start_ns),
        "endTimeUnixNano": str(end_ns),
        "attributes": to_attributes(event),
        "status": {"code": severity_to_status(event.get("severity"))},
    }


def severity_to_status(severity: Any) -> int:
    # OTel StatusCode: 0=UNSET, 1=OK, 2=ERROR.
    if isinstance(severity, str) and severity.lower() in {"error", "critical", "fatal"}:
        return 2
    return 0


def build_payload(spans: list[dict], resource_attrs: dict) -> bytes:
    body = {
        "resourceSpans": [
            {
                "resource": {"attributes": to_attributes(resource_attrs)},
                "scopeSpans": [
                    {
                        "scope": {"name": SCOPE_NAME, "version": SCOPE_VERSION},
                        "spans": spans,
                    }
                ],
            }
        ]
    }
    return json.dumps(body, separators=(",", ":")).encode()


def post_batch(endpoint: str, auth: str, parent: str, payload: bytes) -> None:
    req = urllib.request.Request(
        endpoint,
        data=payload,
        headers={
            "Authorization": f"Bearer {auth}",
            "Content-Type": "application/json",
            "x-bt-parent": parent,
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT) as resp:
        status = resp.status
        body = resp.read(512)
    if status >= 300:
        log("warn", "braintrust returned non-2xx", status=status, body=body.decode(errors="replace"))


def tail_lines(path: Path, stop: dict) -> Iterable[str]:
    # Tail-F semantics: open at end, poll for new bytes, follow inode rotation.
    # `stop` is a single-key dict the signal handler flips so we can exit cleanly.
    pos = 0
    inode = None
    buf = b""
    while not stop.get("stop"):
        try:
            st = path.stat()
        except FileNotFoundError:
            time.sleep(1.0)
            continue
        if inode is None or st.st_ino != inode:
            inode = st.st_ino
            pos = st.st_size  # start at tail on first open or after rotation
            buf = b""
            log("info", "tailing", path=str(path), inode=inode, start_offset=pos)
        if st.st_size < pos:
            # File truncated; rewind.
            log("info", "file truncated, resetting", path=str(path))
            pos = 0
        if st.st_size > pos:
            with path.open("rb") as f:
                f.seek(pos)
                chunk = f.read(st.st_size - pos)
                pos = f.tell()
            buf += chunk
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                if line.strip():
                    yield line.decode("utf-8", errors="replace")
        else:
            time.sleep(0.5)


def env(name: str, default: str | None = None) -> str:
    v = os.environ.get(name, default)
    if v is None or v == "":
        log("error", "missing required env var", name=name)
        sys.exit(2)
    return v


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default=str(DEFAULT_INPUT), help="JSONL file to tail")
    parser.add_argument("--batch-size", type=int, default=DEFAULT_BATCH_SIZE)
    parser.add_argument("--flush-seconds", type=float, default=DEFAULT_FLUSH_SECONDS)
    parser.add_argument("--once", action="store_true", help="Drain available lines and exit (for testing)")
    args = parser.parse_args()

    api_url = env("BRAINTRUST_API_URL").rstrip("/")
    api_key = env("BRAINTRUST_API_KEY")
    project = env("BRAINTRUST_PROJECT")
    endpoint = f"{api_url}/otel/v1/traces"
    parent = f"project_name:{project}"
    resource_attrs = {
        "service.name": "beacon-bridge",
        "service.version": SCOPE_VERSION,
        "telemetry.sdk.name": "beacon-braintrust-bridge",
        "telemetry.sdk.language": "python",
    }

    stop: dict = {}
    def handle_signal(signum, _frame):
        log("info", "received signal, draining", signum=signum)
        stop["stop"] = True
    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    log("info", "starting", endpoint=endpoint, input=args.input, batch=args.batch_size)

    batch: list[dict] = []
    last_flush = time.monotonic()
    sent = 0
    dropped = 0

    def flush() -> None:
        nonlocal sent, dropped, last_flush
        if not batch:
            return
        payload = build_payload(batch, resource_attrs)
        try:
            post_batch(endpoint, api_key, parent, payload)
            sent += len(batch)
            log("info", "flushed", spans=len(batch), total_sent=sent, bytes=len(payload))
        except urllib.error.HTTPError as e:
            body = e.read(512).decode(errors="replace") if e.fp else ""
            log("warn", "http error", status=e.code, body=body)
            dropped += len(batch)
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            log("warn", "transport error", error=str(e))
            dropped += len(batch)
        batch.clear()
        last_flush = time.monotonic()

    path = Path(args.input)
    line_iter = tail_lines(path, stop)
    while not stop.get("stop"):
        try:
            line = next(line_iter)
        except StopIteration:
            break
        try:
            event = json.loads(line)
            span = event_to_span(event)
        except (json.JSONDecodeError, ValueError) as e:
            log("warn", "skip malformed line", error=str(e), preview=line[:120])
            continue
        batch.append(span)
        if len(batch) >= args.batch_size or (time.monotonic() - last_flush) >= args.flush_seconds:
            flush()
        if args.once and not batch:
            break

    flush()
    log("info", "exit", total_sent=sent, total_dropped=dropped)
    return 0


if __name__ == "__main__":
    sys.exit(main())
