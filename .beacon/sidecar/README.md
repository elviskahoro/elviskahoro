# Beacon sidecar collector

Standard `otelcol-contrib` running alongside [Asymptote Beacon](https://github.com/Asymptote-Labs/agent-beacon).
Beacon emits normalized agent-harness telemetry to a local JSONL file; this
sidecar tails that file and fans out via OTLP/HTTP **logs** to the backends that
natively ingest logs: Hyperdx, Logfire, and Dash0. Trace-only backends
(Braintrust, LangSmith, Langfuse, Arize) are **not** wired into the sidecar —
their OTLP ingress only accepts `/v1/traces`, not logs. Beacon events reach
those via the sibling [traces bridge](../braintrust-bridge/) daemon, which
synthesizes spans from the same `runtime.jsonl`.

Beacon ships its own custom `beacon-otelcol` build that only exports to
`beaconjson`, `falcon_hec`, and `splunk_hec` — no `otlp`/`otlphttp` exporters
are compiled in. That's why this lives as a separate collector instead of
extending Beacon's own config.

```text
Claude Code / Codex ──OTLP──▶ beacon-otelcol ──▶ runtime.jsonl
                                                       │
                                       ┌───────────────┴───────────────┐
                                       ▼                               ▼
                               this sidecar (filelog)         traces bridge
                               ──otlphttp logs──▶             (Python, OTLP/JSON spans)
                               Hyperdx / Logfire / Dash0      ──▶ Braintrust / LangSmith
                                                                  / Langfuse / Arize
```

## Files

| Path (in `$HOME`) | Source (in dotfiles) | Purpose |
| --- | --- | --- |
| `~/.beacon/sidecar/otelcol.yaml` | `.beacon/sidecar/otelcol.yaml` | Collector config |
| `~/.beacon/sidecar/run.sh` | `.beacon/sidecar/run.sh` | Launcher; wraps `otelcol-contrib` in `infisical run` |
| `~/Library/LaunchAgents/com.beacon.sidecar.otlp.user.plist` | `Library/LaunchAgents/com.beacon.sidecar.otlp.user.plist` | macOS user launch agent |
| `~/.beacon/sidecar/infisical.env` | **(not tracked)** | Bootstrap creds for Infisical |
| `~/.beacon/sidecar/sidecar.log` | **(not tracked)** | Rotating stdout/stderr |

## One-time setup on a new machine

1. Install [Beacon](https://github.com/Asymptote-Labs/agent-beacon) and bring up the endpoint agent:

   ```sh
   brew tap asymptote-labs/tap
   brew install beacon
   beacon endpoint install --harness=claude,codex
   ```

2. Install `otelcol-contrib` (no Homebrew formula — grab the release tarball):

   ```sh
   curl -fsSL -o /tmp/otelcol-contrib.tar.gz \
     "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.121.0/otelcol-contrib_0.121.0_darwin_arm64.tar.gz"
   tar -xzf /tmp/otelcol-contrib.tar.gz -C /tmp otelcol-contrib
   install -m 0755 /tmp/otelcol-contrib ~/.local/bin/otelcol-contrib
   ```

3. Run `./setup.sh symlinks copies` to materialize the launchd plist symlink
   and copy the collector runtime files into `~/.beacon/sidecar/`. The runtime
   files (`otelcol.yaml`, `run.sh`) are copied rather than symlinked because
   macOS TCC blocks launchd-spawned processes from reading anything under
   `~/Documents/`. Re-run `./setup.sh copies` after any edit to those files.

4. Create the secrets bootstrap file (chmod 600, never committed):

   ```sh
   umask 077
   cat > ~/.beacon/sidecar/infisical.env <<'EOF'
   INFISICAL_PROJECT_ID=<project-uuid>
   INFISICAL_TOKEN=<service-token-with-dev-read>
   EOF
   ```

   The Infisical project must define these secrets in the `dev` env:
   `HYPERDX_API_KEY`, `LOGFIRE_TOKEN`, `DASH0_AUTH_TOKEN`, `ARIZE_API_KEY`,
   `ARIZE_SPACE_ID`. The `BRAINTRUST_API_KEY` / `BRAINTRUST_API_URL` /
   `BRAINTRUST_PROJECT` secrets are also expected but consumed by the
   sibling `braintrust-bridge`, not this sidecar.

5. Bootstrap the launchd agent:

   ```sh
   launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.beacon.sidecar.otlp.user.plist
   ```

## Verifying

```sh
beacon endpoint test-event                       # writes a synthetic event
sleep 10
grep -iE "error|fail|denied" ~/.beacon/sidecar/sidecar.log   # any exporter errors?
```

Each backend has its own UI / API to confirm ingestion (e.g.
`dash0 logs query --from now-2m`).

## Gotchas

- **macOS TCC blocks `~/Documents/` for launchd-spawned processes.** The
  secrets file lives at `~/.beacon/sidecar/infisical.env`, *not* in any
  `Documents/.env.local`, because launchd can't read the latter without Full
  Disk Access.
- **`beacon endpoint repair` does not touch this sidecar** — different binary,
  different launchd label, different config dir.
- **Filelog uses `start_at: end`.** Events written *before* the sidecar starts
  are not replayed. After a config change + kickstart, fire a fresh
  `beacon endpoint test-event` to verify.
- **The `debug` exporter is intentionally absent.** Re-add it temporarily under
  `service.pipelines.logs.exporters` if a backend goes silent — it logs
  per-batch counts so you can prove records left the collector.
