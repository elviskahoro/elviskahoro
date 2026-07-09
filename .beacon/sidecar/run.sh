#!/bin/bash
# Beacon sidecar collector launcher.
# Injects HYPERDX_API_KEY / LOGFIRE_TOKEN / DASH0_AUTH_TOKEN from Infisical,
# then execs otelcol-contrib reading runtime.jsonl and fanning out via OTLP.

set -eu

# Bootstrap creds live outside ~/Documents/ because macOS TCC blocks launchd-
# spawned processes from reading files under that path. Regenerate this file
# from ~/Documents/ai/.env.local whenever the Infisical token rotates.
ENV_FILE="/Users/elvis/.beacon/sidecar/infisical.env"
if [[ ! -f ${ENV_FILE} ]]; then
  echo "missing ${ENV_FILE}; cannot bootstrap Infisical auth" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

exec /opt/homebrew/bin/infisical run \
  --projectId "${INFISICAL_PROJECT_ID}" \
  --token "${INFISICAL_TOKEN}" \
  --env=dev \
  --silent \
  -- /Users/elvis/.local/bin/otelcol-contrib \
  --config /Users/elvis/.beacon/sidecar/otelcol.yaml
