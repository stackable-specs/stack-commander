#!/usr/bin/env bash
set -euo pipefail

if git rev-parse --verify HEAD >/dev/null 2>&1; then
	exec trunk fmt --all --ci --no-fix
fi

echo "trunk-fmt: no HEAD commit yet; falling back to local format check" >&2
bun run format
