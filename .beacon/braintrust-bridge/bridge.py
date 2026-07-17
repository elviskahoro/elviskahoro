#!/usr/bin/env python3
# Beacon -> traces bridge.
#
# Several observability backends only accept OTLP *traces* (/v1/traces), not
# logs -- the sibling sidecar collector therefore drops them from its logs
# pipeline. This daemon closes the gap: it tails the same runtime.jsonl the
# sidecar reads and POSTs Beacon events as OTLP/JSON spans to every configured
# trace backend (Braintrust, LangSmith, Langfuse, Arize).
#
# Events are NOT sent as a flat pile of root spans. Each harness session becomes
# ONE trace whose events nest under synthetic container spans: session -> turn
# -> call (tool/model). Backends that list one row per root span (Braintrust,
# LangSmith, Langfuse) therefore show one entry per session with its turns and
# tool/model calls nested inside, instead of one entry per raw event. See
# build_containers()/plan_event() for the tier logic.
#
# A backend is enabled iff its credentials are present in the environment
# (injected by `infisical run`), so backends are added incrementally just by
# adding the relevant secrets in Infisical -- no code change required. With no
# backend configured the daemon exits 2 so the launchd agent surfaces it.
#
# Stdlib-only on purpose (system Python 3.9 on macOS); no uv / pip dependency
# chain so the launchd agent is robust to environment drift.

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import secrets
import signal
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING, NamedTuple

if TYPE_CHECKING:
    from collections.abc import Iterable

DEFAULT_INPUT = Path("/Users/elvis/.beacon/endpoint/logs/runtime.jsonl")
DEFAULT_BATCH_SIZE = 16
DEFAULT_FLUSH_SECONDS = 5.0
HTTP_TIMEOUT = 10.0
SCOPE_NAME = "beacon-traces-bridge"
# 0.3: session-scoped hierarchy (session -> turn -> call) replaced flat
# one-root-span-per-event output.
SCOPE_VERSION = "0.3"
HTTP_INVALID_STATUS = 300
HEX_TRACE_ID_LENGTH = 32
EXIT_NO_BACKENDS = 2

# Coarse -> fine correlation tiers used to nest a session's events under
# synthetic container spans. For each tier the first key present on the event
# (looked up in raw.attributes) supplies the grouping id, so one spec spans
# harnesses: claude_code emits prompt.id / tool_use_id / request_id, codex_cli
# emits conversation.id / call_id. The session tier is always the trace root
# and is handled separately (see plan_event).
GROUP_TIERS = (
    ("turn", ("prompt.id", "conversation.id")),
    ("call", ("tool_use_id", "request_id", "call_id")),
)

# Backend OTLP/HTTP trace endpoints used when a per-backend override env var is
# absent. All accept OTLP/JSON at a `.../v1/traces` path; they differ only in
# how they authenticate, which build_destinations() encodes per backend.
DEFAULT_BRAINTRUST_API_URL = "https://api.braintrust.dev"
DEFAULT_LANGSMITH_ENDPOINT = "https://api.smith.langchain.com/otel/v1/traces"
# Beacon traces get their OWN LangSmith project so they never mix into the
# shared LANGSMITH_PROJECT that app code (e.g. gtm-sdk) writes to.
DEFAULT_LANGSMITH_PROJECT = "beacon"
DEFAULT_LANGFUSE_HOST = "https://us.cloud.langfuse.com"
DEFAULT_ARIZE_ENDPOINT = "https://otlp.arize.com/v1/traces"
# Observability backends that already receive logs from the sidecar and also
# accept OTLP traces at these endpoints (Dash0's is region-specific, so it is
# derived from DASH0_OTLP_ENDPOINT instead of a constant).
DEFAULT_HYPERDX_ENDPOINT = "https://in-otel.hyperdx.io/v1/traces"
DEFAULT_LOGFIRE_ENDPOINT = "https://logfire-us.pydantic.dev/v1/traces"


class Destination(NamedTuple):
    """One trace backend: where to POST and how to authenticate."""

    name: str
    endpoint: str
    headers: dict


def log(level: str, msg: str, **fields: object) -> None:
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


def attr_value(v: object) -> dict:
    # OTLP/JSON AnyValue encoding. Stringify nested structures so backends
    # always see a leaf primitive (their UIs flatten these into key/value rows).
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


def flatten(obj: object, prefix: str = "") -> Iterable[tuple[str, object]]:
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = f"{prefix}.{k}" if prefix else k
            yield from flatten(v, key)
    elif isinstance(obj, list):
        # Lists are kept as JSON strings under the parent key -- OTLP attributes
        # are a flat map and don't model heterogeneous arrays well enough to
        # round-trip cleanly.
        yield prefix, obj
    else:
        yield prefix, obj


def to_attributes(d: dict) -> list[dict]:
    return [{"key": k, "value": attr_value(v)} for k, v in flatten(d) if k]


def attr_lookup(event: dict, keys: Iterable[str]) -> str | None:
    """First non-empty value among `keys` in the event's raw.attributes."""
    attrs = (event.get("raw") or {}).get("attributes") or {}
    for k in keys:
        v = attrs.get(k)
        if v not in (None, ""):
            return str(v)
    return None


def session_id_of(event: dict) -> str | None:
    """The session id, preferring the top-level envelope, then raw.attributes.

    Returns None for session-less events (e.g. process-global aggregate
    metrics), which are then emitted as standalone root spans.
    """
    sess = (event.get("session") or {}).get("id")
    if isinstance(sess, str) and sess.strip():
        return sess.strip()
    return attr_lookup(event, ("session.id",))


def _stable_hex(text: str, nbytes: int) -> str:
    # Deterministic id: same input -> same id across batches and process
    # restarts, so a child span emitted in one flush links to its container even
    # when they never share a batch.
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[: nbytes * 2]


def trace_id_for(session_key: str) -> str:
    # Reuse a UUID session's own hex (recognizable in backends); otherwise hash
    # any session string to a stable 32-hex trace id so grouping still works.
    hex_only = session_key.replace("-", "").lower()
    if len(hex_only) == HEX_TRACE_ID_LENGTH and all(c in "0123456789abcdef" for c in hex_only):
        return hex_only
    return _stable_hex("beacon-trace:" + session_key, 16)


def span_id_for(*parts: str) -> str:
    return _stable_hex("beacon-span:" + "\x1f".join(parts), 8)


def derive_span_name(event: dict) -> str:
    msg = event.get("message")
    if isinstance(msg, str) and msg.strip():
        return msg.strip()
    action = (event.get("event") or {}).get("action")
    if isinstance(action, str) and action.strip():
        return action.strip()
    return "beacon.event"


def severity_to_status(severity: object) -> int:
    # OTel StatusCode: 0=UNSET, 1=OK, 2=ERROR.
    if isinstance(severity, str) and severity.lower() in {"error", "critical", "fatal"}:
        return 2
    return 0


def build_leaf_span(event: dict, trace_id: str, parent_id: str | None) -> dict:
    ts_str = event.get("timestamp")
    if not isinstance(ts_str, str):
        # Unknown shape -- skip rather than backdate.
        msg = "missing timestamp"
        raise TypeError(msg)
    start_ns = parse_timestamp_ns(ts_str)
    # Beacon events are point-in-time. Give a 1us dummy duration so the span
    # is non-degenerate in trace viewers that filter zero-duration spans.
    end_ns = start_ns + 1_000
    span = {
        "traceId": trace_id,
        "spanId": secrets.token_hex(8),
        "name": derive_span_name(event),
        "kind": 1,  # SPAN_KIND_INTERNAL
        "startTimeUnixNano": str(start_ns),
        "endTimeUnixNano": str(end_ns),
        "attributes": to_attributes(event),
        "status": {"code": severity_to_status(event.get("severity"))},
    }
    if parent_id:
        span["parentSpanId"] = parent_id
    return span


def container_name(tier: str, key: str, event: dict) -> str:
    # Human-readable label for a grouping span, using the triggering event when
    # it carries something friendlier than the raw correlation id.
    attrs = (event.get("raw") or {}).get("attributes") or {}
    if tier == "turn":
        prompt = attrs.get("prompt")
        if isinstance(prompt, str) and prompt.strip():
            return "turn: " + prompt.strip().splitlines()[0][:60]
        return f"turn {key[:8]}"
    if tier == "call":
        tool = attrs.get("tool_name") or attrs.get("slug")
        if isinstance(tool, str) and tool.strip():
            return "tool " + tool.strip()
        model = attrs.get("model")
        if isinstance(model, str) and model.strip():
            return "model " + model.strip()
        return f"call {key[:8]}"
    return f"{tier} {key[:8]}"


def plan_event(event: dict) -> tuple[str, dict, list[dict]]:
    """Map one Beacon event to a leaf span plus the container spans it nests in.

    The container chain is session -> turn -> call, each tier included only when
    the event carries the id that defines it, so a session becomes ONE trace
    whose spans nest by turn and by tool/model call instead of a flat pile of
    root spans. Returns (trace_id, leaf_span, containers) where containers are
    descriptor dicts (coarsest first); their start/end are filled in at flush
    from the spans they contain. Raises TypeError if the event has no timestamp.
    """
    session_key = session_id_of(event)
    if session_key is None:
        # Session-less aggregate metrics (token/cost/active_time totals) have no
        # session to nest under; keep the legacy one-standalone-root-span shape.
        trace_id = secrets.token_hex(16)
        return trace_id, build_leaf_span(event, trace_id, None), []

    trace_id = trace_id_for(session_key)
    harness = (event.get("harness") or {}).get("name") or "agent"

    session_span_id = span_id_for(trace_id, "session")
    containers: list[dict] = [
        {
            "span_id": session_span_id,
            "trace_id": trace_id,
            "parent_id": None,
            "tier": "session",
            "name": f"{harness} session {session_key[:8]}",
            "attributes": {
                "beacon.tier": "session",
                "session.id": session_key,
                "harness.name": harness,
            },
        },
    ]
    parent_id = session_span_id
    for tier_name, keys in GROUP_TIERS:
        key = attr_lookup(event, keys)
        if not key or key == session_key:
            # Skip a tier that just re-labels the session (codex_cli reuses the
            # session uuid as conversation.id) -- it would add an inert wrapper.
            continue
        tier_span_id = span_id_for(trace_id, tier_name, key)
        containers.append(
            {
                "span_id": tier_span_id,
                "trace_id": trace_id,
                "parent_id": parent_id,
                "tier": tier_name,
                "name": container_name(tier_name, key, event),
                "attributes": {
                    "beacon.tier": tier_name,
                    f"{tier_name}.id": key,
                    "session.id": session_key,
                },
            },
        )
        parent_id = tier_span_id

    return trace_id, build_leaf_span(event, trace_id, parent_id), containers


def make_container_span(desc: dict, start_ns: int, end_ns: int) -> dict:
    if end_ns <= start_ns:
        end_ns = start_ns + 1_000
    span = {
        "traceId": desc["trace_id"],
        "spanId": desc["span_id"],
        "name": desc["name"],
        "kind": 1,  # SPAN_KIND_INTERNAL
        "startTimeUnixNano": str(start_ns),
        "endTimeUnixNano": str(end_ns),
        "attributes": to_attributes(desc["attributes"]),
        "status": {"code": 0},
    }
    if desc.get("parent_id"):
        span["parentSpanId"] = desc["parent_id"]
    return span


def build_payload(spans: list[dict], resource_attrs: dict) -> bytes:
    body = {
        "resourceSpans": [
            {
                "resource": {"attributes": to_attributes(resource_attrs)},
                "scopeSpans": [
                    {
                        "scope": {"name": SCOPE_NAME, "version": SCOPE_VERSION},
                        "spans": spans,
                    },
                ],
            },
        ],
    }
    return json.dumps(body, separators=(",", ":")).encode()


def build_destinations() -> list[Destination]:
    """Assemble the enabled trace backends from environment credentials.

    Each backend is opt-in: present credentials -> enabled. This lets the user
    turn a backend on by adding its Infisical secret, with no code change.
    """
    dests: list[Destination] = []

    braintrust_key = os.environ.get("BRAINTRUST_API_KEY")
    if braintrust_key:
        api_url = os.environ.get("BRAINTRUST_API_URL", DEFAULT_BRAINTRUST_API_URL).rstrip("/")
        project = os.environ.get("BRAINTRUST_PROJECT", "beacon")
        dests.append(
            Destination(
                "braintrust",
                f"{api_url}/otel/v1/traces",
                {
                    "Authorization": f"Bearer {braintrust_key}",
                    "x-bt-parent": f"project_name:{project}",
                },
            ),
        )

    langsmith_key = os.environ.get("LANGSMITH_API_KEY")
    if langsmith_key:
        endpoint = os.environ.get("LANGSMITH_OTEL_ENDPOINT", DEFAULT_LANGSMITH_ENDPOINT)
        # Deliberately NOT os.environ["LANGSMITH_PROJECT"]: that is the shared
        # app project; beacon telemetry routes to its own via the beacon-scoped
        # override, defaulting to "beacon".
        project = os.environ.get("BEACON_LANGSMITH_PROJECT", DEFAULT_LANGSMITH_PROJECT)
        headers = {"x-api-key": langsmith_key, "Langsmith-Project": project}
        dests.append(Destination("langsmith", endpoint, headers))

    langfuse_public = os.environ.get("LANGFUSE_PUBLIC_KEY")
    langfuse_secret = os.environ.get("LANGFUSE_SECRET_KEY")
    if langfuse_public and langfuse_secret:
        host = os.environ.get("LANGFUSE_HOST", DEFAULT_LANGFUSE_HOST).rstrip("/")
        token = base64.b64encode(f"{langfuse_public}:{langfuse_secret}".encode()).decode()
        dests.append(
            Destination(
                "langfuse",
                f"{host}/api/public/otel/v1/traces",
                {"Authorization": f"Basic {token}"},
            ),
        )

    arize_space = os.environ.get("ARIZE_SPACE_ID")
    arize_key = os.environ.get("ARIZE_API_KEY")
    if arize_space and arize_key:
        endpoint = os.environ.get("ARIZE_OTEL_ENDPOINT", DEFAULT_ARIZE_ENDPOINT)
        dests.append(
            Destination("arize", endpoint, {"space_id": arize_space, "api_key": arize_key}),
        )

    # Log-native backends that ALSO accept OTLP traces: send the synthesized
    # spans so HyperDX/Logfire/Dash0 have correlated logs + traces. Same creds
    # as the sidecar's logs pipeline.
    hyperdx_key = os.environ.get("HYPERDX_API_KEY")
    if hyperdx_key:
        endpoint = os.environ.get("HYPERDX_OTEL_TRACES_ENDPOINT", DEFAULT_HYPERDX_ENDPOINT)
        # HyperDX takes the raw key in a lowercase `authorization` header.
        dests.append(Destination("hyperdx", endpoint, {"authorization": hyperdx_key}))

    # LOGFIRE_TOKEN is revoked ("Unknown token"); prefer the valid write token.
    logfire_token = os.environ.get("LOGFIRE_WRITE_TOKEN") or os.environ.get("LOGFIRE_TOKEN")
    if logfire_token:
        endpoint = os.environ.get("LOGFIRE_OTEL_TRACES_ENDPOINT", DEFAULT_LOGFIRE_ENDPOINT)
        dests.append(
            Destination("logfire", endpoint, {"Authorization": f"Bearer {logfire_token}"}),
        )

    dash0_token = os.environ.get("DASH0_AUTH_TOKEN")
    dash0_endpoint = os.environ.get("DASH0_OTLP_ENDPOINT")
    if dash0_token and dash0_endpoint:
        base = dash0_endpoint.rstrip("/")
        headers = {
            "Authorization": f"Bearer {dash0_token}",
            "Dash0-Dataset": os.environ.get("DASH0_DATASET", "default"),
        }
        dests.append(Destination("dash0", f"{base}/v1/traces", headers))

    return dests


def post_batch(dest: Destination, payload: bytes) -> None:
    parsed = urllib.parse.urlparse(dest.endpoint)
    if parsed.scheme not in ("http", "https"):
        msg = f"Invalid URL scheme: {parsed.scheme}"
        raise ValueError(msg)
    headers = {"Content-Type": "application/json", **dest.headers}
    req = urllib.request.Request(  # noqa: S310
        dest.endpoint,
        data=payload,
        headers=headers,
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT) as resp:  # noqa: S310
        status = resp.status
        body = resp.read(512)
    if status >= HTTP_INVALID_STATUS:
        log(
            "warn",
            "backend returned non-2xx",
            backend=dest.name,
            status=status,
            body=body.decode(errors="replace"),
        )


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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default=str(DEFAULT_INPUT),
        help="JSONL file to tail",
    )
    parser.add_argument("--batch-size", type=int, default=DEFAULT_BATCH_SIZE)
    parser.add_argument("--flush-seconds", type=float, default=DEFAULT_FLUSH_SECONDS)
    parser.add_argument(
        "--once",
        action="store_true",
        help="Drain available lines and exit (for testing)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    destinations = build_destinations()
    if not destinations:
        log(
            "error",
            "no trace backends configured; set BRAINTRUST_API_KEY / "
            "LANGSMITH_API_KEY / LANGFUSE_PUBLIC_KEY+LANGFUSE_SECRET_KEY / "
            "ARIZE_SPACE_ID+ARIZE_API_KEY",
        )
        return EXIT_NO_BACKENDS

    resource_attrs = {
        "service.namespace": "beacon",
        "service.name": "beacon-bridge",
        "service.version": SCOPE_VERSION,
        "telemetry.sdk.name": SCOPE_NAME,
        "telemetry.sdk.language": "python",
        # Arize rejects spans (HTTP 500) unless they carry a model_id resource
        # attribute or an arize.project.name span attribute. The other backends
        # ignore this extra resource attribute, so it is safe to set globally.
        "model_id": os.environ.get("ARIZE_MODEL_ID", "beacon"),
    }

    stop: dict = {}

    def handle_signal(signum: int, _frame: object) -> None:
        log("info", "received signal, draining", signum=signum)
        stop["stop"] = True

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    log(
        "info",
        "starting",
        backends=[d.name for d in destinations],
        input=args.input,
        batch=args.batch_size,
    )

    # batch holds parsed events (not spans): container spans are synthesized at
    # flush time so a container's duration can span the child events in the
    # batch. emitted_containers dedupes containers across flushes so each
    # session/turn/call root is sent once (a restart may re-emit at most one per
    # live container -- benign: backends upsert by span id or the row is inert).
    batch: list[dict] = []
    emitted_containers: set = set()
    last_flush = time.monotonic()
    counters: dict = {d.name: {"sent": 0, "dropped": 0} for d in destinations}

    def build_spans() -> tuple[list[dict], int]:
        """Turn the buffered events into leaf spans + newly-seen container spans."""
        spans: list[dict] = []
        pending: dict = {}  # container span_id -> {"desc", "start", "end"}
        for event in batch:
            try:
                _trace_id, leaf, containers = plan_event(event)
            except (ValueError, TypeError) as e:
                log("warn", "skip unplannable event", error=str(e))
                continue
            spans.append(leaf)
            start, end = int(leaf["startTimeUnixNano"]), int(leaf["endTimeUnixNano"])
            for c in containers:
                if c["span_id"] in emitted_containers:
                    continue
                p = pending.get(c["span_id"])
                if p is None:
                    pending[c["span_id"]] = {"desc": c, "start": start, "end": end}
                else:
                    p["start"] = min(p["start"], start)
                    p["end"] = max(p["end"], end)
        for span_id, p in pending.items():
            spans.append(make_container_span(p["desc"], p["start"], p["end"]))
            emitted_containers.add(span_id)
        return spans, len(pending)

    def flush() -> None:
        nonlocal last_flush
        if not batch:
            return
        spans, n_containers = build_spans()
        if not spans:
            batch.clear()
            last_flush = time.monotonic()
            return
        payload = build_payload(spans, resource_attrs)
        for dest in destinations:
            try:
                post_batch(dest, payload)
                counters[dest.name]["sent"] += len(spans)
                log(
                    "info",
                    "flushed",
                    backend=dest.name,
                    spans=len(spans),
                    containers=n_containers,
                    total_sent=counters[dest.name]["sent"],
                    bytes=len(payload),
                )
            except urllib.error.HTTPError as e:
                body = e.read(512).decode(errors="replace") if e.fp else ""
                log("warn", "http error", backend=dest.name, status=e.code, body=body)
                counters[dest.name]["dropped"] += len(spans)
            except (urllib.error.URLError, TimeoutError, OSError) as e:
                log("warn", "transport error", backend=dest.name, error=str(e))
                counters[dest.name]["dropped"] += len(spans)
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
        except json.JSONDecodeError as e:
            log("warn", "skip malformed line", error=str(e), preview=line[:120])
            continue
        if not isinstance(event, dict):
            log("warn", "skip non-object line", preview=line[:120])
            continue
        batch.append(event)
        if len(batch) >= args.batch_size or (time.monotonic() - last_flush) >= args.flush_seconds:
            flush()
        if args.once and not batch:
            break

    flush()
    log("info", "exit", counters=counters)
    return 0


if __name__ == "__main__":
    sys.exit(main())
