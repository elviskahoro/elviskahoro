# Beacon → traces bridge

Standalone Python daemon that ships Beacon events to one or more **trace**
backends as OTLP/JSON spans. Historically Braintrust-only (hence the directory
name); now fans out to any of **Braintrust, LangSmith, Langfuse, Arize**.

## Why this exists

These backends' OTLP ingress only accepts `/v1/traces`, not `/v1/logs`:

- **Braintrust** — POSTs to `/v1/logs` fall through to upstream AWS infra and
  return HTTP 403 (an AWS SigV4 error, not Braintrust's own gateway).
- **Arize / LangSmith / Langfuse** — trace-oriented LLM-observability products;
  they reject or 502 on log-signal payloads.

The sibling [sidecar collector](../sidecar/) only emits **logs** (its `filelog`
receiver produces log records, and `otelcol-contrib` has no log→trace
connector), so those backends can't live in the sidecar's logs pipeline. This
daemon closes the gap: it tails the same `runtime.jsonl` and POSTs the events as
OTLP/JSON spans to every configured backend, grouped into one trace per session
(see [Session-scoped hierarchy](#session-scoped-hierarchy)).

```text
                          ┌─▶ Braintrust  /otel/v1/traces      (Bearer + x-bt-parent)
runtime.jsonl ─tail─▶ bridge.py ─▶ LangSmith   /otel/v1/traces  (x-api-key + Langsmith-Project)
                          ├─▶ Langfuse   /api/public/otel/v1/traces (Basic pk:sk)
                          └─▶ Arize      /v1/traces             (space_id + api_key)
```

## Backends are opt-in via credentials

A backend is enabled **iff** its secrets are present in the environment
(injected by `infisical run`). Add the secret in Infisical, restart the daemon,
and that backend lights up — no code change. With no backend configured the
daemon exits 2 so the launchd agent surfaces the misconfiguration.

| Backend | Required env | Optional env (defaults) |
| --- | --- | --- |
| Braintrust | `BRAINTRUST_API_KEY` | `BRAINTRUST_PROJECT` (`beacon`), `BRAINTRUST_API_URL` (`https://api.braintrust.dev`) |
| LangSmith | `LANGSMITH_API_KEY` | `BEACON_LANGSMITH_PROJECT` (`beacon`), `LANGSMITH_OTEL_ENDPOINT` (US) |
| Langfuse | `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY` | `LANGFUSE_HOST` (`https://us.cloud.langfuse.com`) |
| Arize | `ARIZE_SPACE_ID`, `ARIZE_API_KEY` | `ARIZE_OTEL_ENDPOINT` (`https://otlp.arize.com/v1/traces`) |

> **LangSmith project isolation:** the bridge deliberately does **not** read the
> shared `LANGSMITH_PROJECT` secret (used by app code such as gtm-sdk) — beacon
> telemetry would pollute it. It routes to `BEACON_LANGSMITH_PROJECT` instead,
> defaulting to `beacon`.

## Session-scoped hierarchy

A harness session becomes **one trace** whose events nest under synthetic
container spans, instead of one root span per event (which made every backend
that lists one row per root span show a session as a flat pile of unrelated
entries). The tiers, coarsest first:

```text
session          (traceId = session.id; one root span per session)
└── turn         (prompt.id ‖ conversation.id)
    └── call     (tool_use_id ‖ request_id ‖ call_id)   e.g. "tool Bash", "model claude-opus-4-8"
        └── event leaf spans (the raw Beacon events)
```

Each tier is included only when the event carries the id that defines it, and a
tier whose id equals the session id is skipped (codex_cli reuses the session
uuid as `conversation.id`, so its tree is just session → call). The correlation
keys are harness-agnostic — claude_code emits `prompt.id` / `tool_use_id` /
`request_id`; codex_cli emits `conversation.id` / `call_id`. Container span ids
are a **deterministic** hash of the tier's ids, so a child emitted in one flush
links to its container even when they never share a batch (or a restart).

Events with **no** session id (process-global aggregate metrics — token/cost/
active-time totals) have nothing to nest under, so they stay as standalone root
spans as before.

### Span fields

| OTel field | Leaf (event) | Container (session / turn / call) |
| --- | --- | --- |
| `traceId` | `session.id` → 32 hex (UUID reused, else hashed); random when session-less | same as its leaves |
| `spanId` | random 8 bytes | deterministic hash of the tier ids |
| `parentSpanId` | deepest container present (absent when session-less) | its parent tier (absent on the session root) |
| `name` | `event.message` ‖ `event.event.action` ‖ `"beacon.event"` | e.g. `claude_code session <8hex>`, `turn: <prompt>`, `tool Bash`, `model <id>` |
| `startTimeUnixNano` | from `event.timestamp` | earliest child in the flush that first emits it |
| `endTimeUnixNano` | start + 1µs (events are point-in-time) | latest child in that flush |
| `attributes` | dot-flattened event envelope | tier + its id + session id |
| `status.code` | `ERROR` when `severity ∈ {error, critical, fatal}`, else `UNSET` | `UNSET` |

The same payload goes to every backend; only the auth headers differ. Resource
attributes carry `service.name=beacon-bridge`; scope is `beacon-traces-bridge`
version `0.3`.

## Files

| Path (in `$HOME`) | Source (in dotfiles) | Purpose |
| --- | --- | --- |
| `~/.beacon/braintrust-bridge/bridge.py` | `.beacon/braintrust-bridge/bridge.py` | Daemon (stdlib only) |
| `~/.beacon/braintrust-bridge/run.sh` | `.beacon/braintrust-bridge/run.sh` | Launcher; wraps `bridge.py` in `infisical run` |
| `~/Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist` | `Library/LaunchAgents/…` | macOS user launch agent |
| `~/.beacon/braintrust-bridge/bridge.log` | **(not tracked)** | Stdout/stderr |

The bridge reuses the sidecar's `~/.beacon/sidecar/infisical.env` for the
`INFISICAL_PROJECT_ID` / `INFISICAL_TOKEN` bootstrap pair; `infisical run` then
injects every project secret, so any backend's creds become available the
moment they're added in Infisical.

## Verifying

```sh
launchctl print "gui/$(id -u)/com.beacon.braintrust.bridge.user" | grep -E "state =|pid ="
# each flush line names the backend, span count, running total, payload bytes:
tail -f ~/.beacon/braintrust-bridge/bridge.log
```

## Gotchas

- **Tail starts at end.** Like the sidecar (`start_at: end`), the bridge doesn't
  replay history on restart — events written while it was down are lost.
- **Per-backend isolation.** A failing backend (bad cred, transport error)
  increments only its own dropped counter; other backends still receive the
  batch. No cross-backend retry.
- **Stdlib only on purpose.** System Python 3.9 keeps the launchd agent immune
  to environment drift (no `uv` / `pip` chain to break).
- **Truncation/rotation.** If `runtime.jsonl` rotates (inode change) or is
  truncated, the bridge re-opens from the new end automatically.
