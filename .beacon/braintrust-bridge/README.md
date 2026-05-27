# Beacon → Braintrust traces bridge

Standalone Python daemon that ships Beacon events into the Braintrust
`agents-otel` project as OTLP/JSON traces.

## Why this exists

Braintrust's OTLP ingress at `https://api.braintrust.dev/otel/` only accepts
`/v1/traces`. POSTs to `/v1/logs` fall through to upstream AWS infra and come
back with HTTP 403 (`Invalid key=value pair (missing equal-sign) in
Authorization header (hashed with SHA-256 and encoded with Base64)…`) — that
error format is AWS SigV4, not Braintrust's own gateway.

The sibling [sidecar collector](../sidecar/) only emits logs (its `filelog`
receiver only produces log records, and standard `otelcol-contrib` has no
log→trace connector). So Braintrust is intentionally absent from the
sidecar's `service.pipelines.logs.exporters`, and this small daemon closes
the gap by reading the same `runtime.jsonl` and POSTing each event as a
single OTLP span to `/otel/v1/traces`.

```text
runtime.jsonl ──tail──▶ bridge.py ──OTLP/JSON──▶ Braintrust /otel/v1/traces
                                                 (agents-otel project)
```

## Span shape

| OTel field | Source |
| --- | --- |
| `traceId` | `event.session.id` with dashes stripped (UUID → 32 hex), else random 16 bytes — groups all events in one harness session into one Braintrust trace |
| `spanId` | random 8 bytes per event |
| `name` | `event.message` ‖ `event.event.action` ‖ `"beacon.event"` |
| `kind` | `SPAN_KIND_INTERNAL` |
| `startTimeUnixNano` | from `event.timestamp` |
| `endTimeUnixNano` | start + 1µs (Beacon events are point-in-time) |
| `attributes` | dot-flattened envelope + `raw.attributes.*` (already-OTel keys from the upstream harness) |
| `status.code` | `ERROR` when `severity ∈ {error, critical, fatal}`, else `UNSET` |

Resource attributes carry `service.name=beacon-bridge`. Scope is
`beacon-braintrust-bridge`.

## Files

| Path (in `$HOME`) | Source (in dotfiles) | Purpose |
| --- | --- | --- |
| `~/.beacon/braintrust-bridge/bridge.py` | `.beacon/braintrust-bridge/bridge.py` | Daemon (stdlib only) |
| `~/.beacon/braintrust-bridge/run.sh` | `.beacon/braintrust-bridge/run.sh` | Launcher; wraps `bridge.py` in `infisical run` |
| `~/Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist` | `Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist` | macOS user launch agent |
| `~/.beacon/braintrust-bridge/bridge.log` | **(not tracked)** | Stdout/stderr |

The bridge reuses the sidecar's `~/.beacon/sidecar/infisical.env` for the
`INFISICAL_PROJECT_ID` / `INFISICAL_TOKEN` bootstrap pair.

## Install (one-time)

1. Make sure the sidecar is set up first (its `infisical.env` is required).
2. Copy the runtime files into `~/.beacon/braintrust-bridge/`:

   ```sh
   mkdir -p ~/.beacon/braintrust-bridge
   cp ~/Documents/elviskahoro/dotfiles/.beacon/braintrust-bridge/{bridge.py,run.sh} \
      ~/.beacon/braintrust-bridge/
   chmod +x ~/.beacon/braintrust-bridge/{bridge.py,run.sh}
   ```

3. Symlink the launch agent and bootstrap:

   ```sh
   ln -s ~/Documents/elviskahoro/dotfiles/Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist \
      ~/Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist
   launchctl bootstrap "gui/$(id -u)" \
      ~/Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist
   ```

## Verifying

```sh
# Daemon up?
launchctl print "gui/$(id -u)/com.beacon.braintrust.bridge.user" | grep -E "state =|pid ="

# Recent flushes (each line shows span count, total sent, payload bytes):
tail -f ~/.beacon/braintrust-bridge/bridge.log
```

Confirm data in Braintrust via BTQL:

```sh
infisical run --env=dev -- bash -c '
  PROJECT_ID="$(curl -sS -H "Authorization: Bearer $BRAINTRUST_API_KEY" \
    "https://api.braintrust.dev/v1/project?limit=1" | jq -r ".objects[0].id")"
  curl -sS -X POST -H "Authorization: Bearer $BRAINTRUST_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"SELECT id, created FROM project_logs('$PROJECT_ID', shape => 'traces') ORDER BY created DESC LIMIT 5\",\"fmt\":\"json\"}" \
    "https://api.braintrust.dev/btql" | jq
'
```

Or open `https://www.braintrust.dev/app/elviskahoro/p/agents-otel`.

## Gotchas

- **Tail starts at end.** Like the sidecar (`start_at: end`), the bridge
  doesn't replay history on restart — events written while the daemon was
  down are lost. This is intentional: Beacon's `runtime.jsonl` is unbounded
  and replay would dwarf live traffic.
- **No retry.** Failed POSTs (5xx, transport errors) increment the dropped
  counter and the batch is dropped. Braintrust is reliable; if drops climb,
  add retry/backoff rather than ramping up batch sizes.
- **Stdlib only on purpose.** System Python 3.9.6 is enough — keeps the
  launchd agent immune to environment drift (no `uv` / `pip` chain to break).
- **Truncation handling.** If `runtime.jsonl` is rotated (inode change) or
  truncated, the bridge re-opens from the new end automatically.
