#!/usr/bin/env bash
# PreToolUse hook: block `git push` on protected branches (main/master/release/*).
# Allows push on agent/* and feature/* and any other branch.
# Use ALLOW_PROTECTED_PUSH=1 in the command env to override for a single call.

set -u

input=$(cat)
cmd=$(printf '%s' "${input}" | jq -r '.tool_input.command // empty')

# Only inspect git push commands.
if ! printf '%s' "${cmd}" | grep -Eq '(^|[^a-zA-Z_-])git[[:space:]]+push([[:space:]]|$)'; then
  echo '{}'
  exit 0
fi

# Explicit override.
if printf '%s' "${cmd}" | grep -q 'ALLOW_PROTECTED_PUSH=1'; then
  echo '{}'
  exit 0
fi

# Resolve current branch from the same cwd the Bash tool will use.
cwd=$(printf '%s' "${input}" | jq -r '.cwd // .tool_input.cwd // empty')
[[ -z ${cwd} ]] && cwd=${PWD}
branch=$(git -C "${cwd}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

case "${branch}" in
main | master | release/* | releases/*)
  msg="Refusing to git push on protected branch '${branch}'. Ask the user to push, or prefix the command with ALLOW_PROTECTED_PUSH=1 after explicit confirmation."
  jq -n --arg m "${msg}" '{continue: false, stopReason: $m}'
  exit 1
  ;;
*) ;;
esac

echo '{}'
