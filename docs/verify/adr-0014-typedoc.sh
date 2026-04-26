#!/usr/bin/env bash
# Verify ADR 0014 — Adopt TypeDoc for API Reference Documentation.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

typedoc_version="$(jq -r '.devDependencies.typedoc // empty' package.json)"
if echo "$typedoc_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+'; then
  check_pass "typedoc pinned exactly in devDependencies" "$typedoc_version"
else
  check_fail "typedoc pinned exactly in devDependencies" "actual: ${typedoc_version:-<missing>}"
fi

for f in typedoc.json tsdoc.json; do
  if [ -f "$f" ]; then
    check_pass "$f present"
  else
    check_fail "$f present" "missing"
  fi
done

if jq -e '.scripts.docs and .scripts["docs:check"]' package.json >/dev/null 2>&1; then
  check_pass "package.json defines docs and docs:check scripts"
else
  check_fail "package.json defines docs and docs:check scripts"
fi

if grep -q 'bun run docs:check' .github/workflows/ci.yml 2>/dev/null ||
   grep -q 'typedoc --emit none' .github/workflows/ci.yml 2>/dev/null; then
  check_pass "CI runs the docs:check gate"
else
  check_fail "CI runs the docs:check gate"
fi

run_cmd TD_OUT TD_ERR TD_CODE -- bun run docs:check
if [ "$TD_CODE" -eq 0 ]; then
  check_pass "bun run docs:check exits 0"
else
  check_fail "bun run docs:check exits 0" "$(printf '%s\n%s' "$TD_OUT" "$TD_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0014 — TypeDoc"
