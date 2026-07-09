---
name: redeploy-beacon-agents
description: Redeploy the Beacon telemetry launch agents (sidecar collector + traces bridge) with fresh Infisical credentials from dotfiles/beacon.env, TCC-safely.
version: 1.0.0
metadata:
  author: elviskahoro
---

# Redeploy Beacon agents

Redeploy the two macOS launch agents that ship agent-harness telemetry, and/or
rotate their Infisical bootstrap credentials. Use this when the user says
"redeploy beacon", "rotate the beacon/Infisical token", "beacon isn't sending
traces", or after editing anything under `.beacon/`.

## The two agents

Both are per-user launchd agents. Both `source` the **same** bootstrap file and
exec their program under `infisical run`, which injects every `dev`-env secret
of the Infisical project:

| Label | Program (in `$HOME`) | Purpose |
| --- | --- | --- |
| `com.beacon.sidecar.otlp.user` | `~/.beacon/sidecar/run.sh` → `otelcol-contrib` | Tails `runtime.jsonl`, fans out **logs** (Hyperdx / Logfire / Dash0) |
| `com.beacon.braintrust.bridge.user` | `~/.beacon/braintrust-bridge/run.sh` → `bridge.py` | Tails the same file, POSTs **traces** (Braintrust / LangSmith / Langfuse / Arize) |

(`com.beacon.endpoint.collector.user` is Beacon's own upstream collector —
managed by the `beacon` CLI, **not** by this skill.)

## Credential flow — source of truth is `dotfiles/beacon.env`

```
dotfiles/beacon.env            # source of truth, repo root, gitignored via *.env
   │  ./setup.sh copies        # copy_mappings: "beacon.env=>.beacon/sidecar/infisical.env"
   ▼
~/.beacon/sidecar/infisical.env   # REAL file, 0600, outside ~/Documents/
   │  sourced by both run.sh (INFISICAL_PROJECT_ID + INFISICAL_TOKEN)
   ▼
infisical run --projectId … --token … --env=dev -- <program>   # injects dev secrets
```

`beacon.env` holds only the bootstrap pair (`INFISICAL_PROJECT_ID`,
`INFISICAL_TOKEN`); every backend credential lives in the Infisical project's
`dev` environment and is injected at runtime — add a secret there, redeploy, and
that backend lights up with no code change.

## ⚠️ Never symlink the bootstrap file into `~/Documents/`

macOS **TCC** blocks launchd-spawned processes from reading anything whose
resolved path is under `~/Documents/`. `~/.beacon/sidecar/infisical.env` must be
a **real file** (which is why `setup.sh` *copies* it, and every runtime file,
rather than symlinking). A symlink pointing at `dotfiles/beacon.env` crashloops
the agent — verified failure:

```
run.sh: line 18: /Users/elvis/.beacon/sidecar/infisical.env: Operation not permitted
# launchctl print → last exit code = 1, state = spawn scheduled (KeepAlive throttle-loop, 10s)
```

The same rule applies to `run.sh`, `otelcol.yaml`, `bridge.py`, and the launchd
plists — all copied, never symlinked.

## Redeploy procedure

1. **(Rotation only)** Put the new creds in the source of truth:

   ```sh
   $EDITOR ~/Documents/elviskahoro/dotfiles/beacon.env   # INFISICAL_PROJECT_ID / INFISICAL_TOKEN
   ```

2. **Redeploy** — regenerates the real bootstrap file (0600) and kickstarts both
   agents in one step:

   ```sh
   cd ~/Documents/elviskahoro/dotfiles && ./setup.sh copies
   ```

   `cmd_copies` copies any changed runtime file, `chmod 600`s `infisical.env`,
   then `launchctl kickstart -k`s each loaded beacon agent so it re-`source`s and
   re-injects. (`./setup.sh copies` is idempotent — unchanged files are skipped,
   and if nothing changed it won't kickstart. Force a restart with the manual
   kickstart below.)

## Verify

```sh
DOMAIN="gui/$(id -u)"
for l in com.beacon.sidecar.otlp.user com.beacon.braintrust.bridge.user; do
  launchctl print "$DOMAIN/$l" | grep -E "state =|pid =|last exit code ="
done
# expect: state = running, last exit code = 0

# end-to-end: fire a synthetic event and watch it flush downstream
beacon endpoint test-event
sleep 8
tail -n 5 ~/.beacon/braintrust-bridge/bridge.log   # → "flushed backend=… spans=…"
grep -iE "error|denied|not permitted" ~/.beacon/sidecar/sidecar.log | tail   # should be empty/stale
```

The bridge logs `Injecting N Infisical secrets` on startup and one `flushed
backend=…` line per backend per batch; the sidecar's `filelog` uses
`start_at: end`, so **only events written after restart appear** — always fire a
fresh `beacon endpoint test-event` to verify.

## Manual fallback (no `setup.sh`)

```sh
install -m 600 ~/Documents/elviskahoro/dotfiles/beacon.env ~/.beacon/sidecar/infisical.env
DOMAIN="gui/$(id -u)"
launchctl kickstart -k "$DOMAIN/com.beacon.sidecar.otlp.user"
launchctl kickstart -k "$DOMAIN/com.beacon.braintrust.bridge.user"
```

## Gotchas

- **`beacon endpoint repair` does not touch these agents** — different binary,
  label, and config dir. It only manages the upstream endpoint collector.
- **Both agents share one bootstrap file.** Rotating the token redeploys both.
- **Backend enabled ⇔ its secret is present** in the Infisical `dev` env. A
  missing cred just leaves that backend dark (e.g. `langsmith` drops if
  `LANGSMITH_API_KEY` is unset) — it does not fail the agent.
- **`beacon.env` must stay gitignored.** It carries a live service token; the
  repo `.gitignore` covers it via `*.env`. Never rename it to something that
  escapes that pattern.
