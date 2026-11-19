#!/usr/bin/env bash
# Create a Conductor cloud workspace for a GitHub issue.
# Usage: conductor-issue.sh <owner/repo> <issue-number>
# Needs CONDUCTOR_API_KEY (create one at https://app.conductor.build/home/api-keys).
set -euo pipefail

repo="${1:?usage: conductor-issue.sh <owner/repo> <issue-number>}"
num="${2:?usage: conductor-issue.sh <owner/repo> <issue-number>}"

# Load CONDUCTOR_API_KEY from ~/.config/gh-dash/.envrc via direnv, so it works
# no matter which directory gh-dash was launched from.
if [ -z "${CONDUCTOR_API_KEY:-}" ] && command -v direnv >/dev/null 2>&1; then
  cd "$(dirname "$0")"
  eval "$(direnv export bash 2>/dev/null)" || true
  cd - >/dev/null
fi

if [ -z "${CONDUCTOR_API_KEY:-}" ]; then
  echo "CONDUCTOR_API_KEY is not set (put it in ~/.config/gh-dash/.envrc and run: direnv allow)" >&2
  read -r -p "press enter to close" _ || true
  exit 1
fi

issue_url="https://github.com/${repo}/issues/${num}"
title="$(gh issue view "$num" --repo "$repo" --json title -q .title)"

# Workspace name: GH + 4-digit issue number + title-cased repo name,
# e.g. GH0005 Epic Sermons (repo epic-sermons).
repo_name="${repo#*/}"
repo_title="$(tr '_-' '  ' <<<"$repo_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')"
ws_name="$(printf 'GH%04d %s' "$((10#$num))" "$repo_title")"

payload="$(jq -n \
  --arg repo "https://github.com/${repo}" \
  --arg name "$ws_name" \
  --arg msg "Work on GitHub issue ${repo}#${num}: ${title}
${issue_url}

Read the issue (gh issue view ${num} --repo ${repo} --comments) and implement it.

When you open the PR, use our PR template: https://github.com/elviskahoro/oss-hq/blob/main/prompts/conductor/create-pr.md" \
  '{repositoryUrl: $repo, name: $name, message: $msg}')"

# Retry on retryable errors (e.g. RATE_LIMITED), up to 4 attempts.
for attempt in 1 2 3 4; do
  resp="$(curl -sS -X POST https://api.conductor.build/v0/workspaces \
    -H "Authorization: Bearer ${CONDUCTOR_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload")"
  link="$(jq -r '.deepLink // empty' <<<"$resp")"
  [ -n "$link" ] && break
  retryable="$(jq -r '.retryable // false' <<<"$resp" 2>/dev/null || echo false)"
  if [ "$retryable" = "true" ] && [ "$attempt" -lt 4 ]; then
    wait_s="$(jq -r '(.userMessage // "") | capture("after (?<n>[0-9]+) second").n // "2"' <<<"$resp" 2>/dev/null || echo 2)"
    echo "Retryable error, retrying in ${wait_s}s (attempt ${attempt}/4)..." >&2
    sleep "$wait_s"
    continue
  fi
  break
done

if [ -z "$link" ]; then
  echo "Conductor API error: $resp" >&2
  # Brief pause so the error is readable, then exit back to gh-dash.
  sleep 4
  exit 1
fi

echo "Created workspace for ${repo}#${num}"
# Conductor steals focus when a deep link makes it launch, so launch it hidden
# first, wait for it to be running, then send the link.
if ! pgrep -xq Conductor; then
  open -g -j -a Conductor
  for _ in $(seq 1 60); do
    pgrep -xq Conductor && break
    sleep 0.5
  done
  sleep 5
fi
open -g "$link"
