#!/bin/zsh
# Beacon → Braintrust bridge launcher.
# Mirrors .beacon/sidecar/run.sh: source the shared Infisical bootstrap file
# (chmod 600, outside ~/Documents/) and exec the daemon under `infisical run`
# so BRAINTRUST_API_KEY / BRAINTRUST_API_URL / BRAINTRUST_PROJECT are injected
# from the dev environment without ever touching disk.

set -eu

ENV_FILE="/Users/elvis/.beacon/sidecar/infisical.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "missing $ENV_FILE; cannot bootstrap Infisical auth" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

exec /opt/homebrew/bin/infisical run \
  --projectId "$INFISICAL_PROJECT_ID" \
  --token "$INFISICAL_TOKEN" \
  --env=dev \
  --silent \
  -- /usr/bin/python3 /Users/elvis/.beacon/braintrust-bridge/bridge.py
