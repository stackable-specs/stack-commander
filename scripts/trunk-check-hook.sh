#!/usr/bin/env bash
set -euo pipefail

if git rev-parse --verify HEAD >/dev/null 2>&1; then
	exec trunk check --all --ci --no-fix
fi

echo "trunk-check: no HEAD commit yet; falling back to local lint checks" >&2
bun run lint
bun run format
