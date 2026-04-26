#!/usr/bin/env bash
# Verify ADR 0013 — Adopt Smoke Testing as a Pipeline Gate.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

if [ -d tests/smoke ]; then
  check_pass "tests/smoke/ present"
else
  check_fail "tests/smoke/ present" "missing"
  report_and_exit "ADR 0013 — Smoke Testing"
fi

count="$(find tests/smoke -type f -name '*.test.ts' 2>/dev/null | wc -l | tr -d ' ')"
if [ "${count:-0}" -gt 0 ]; then
  check_pass "at least one smoke test file exists" "found $count"
else
  check_fail "at least one smoke test file exists" "none found"
fi

if jq -e '.scripts["test:smoke"]' package.json >/dev/null 2>&1; then
  check_pass "package.json defines test:smoke script"
else
  check_fail "package.json defines test:smoke script"
fi

if grep -q 'name: Smoke tests' .github/workflows/ci.yml 2>/dev/null; then
  check_pass "CI defines a smoke job"
else
  check_fail "CI defines a smoke job"
fi

if [ -f .github/workflows/smoke-postdeploy.yml ]; then
  check_pass "post-deploy smoke workflow present"
else
  check_fail "post-deploy smoke workflow present"
fi

run_cmd SM_OUT SM_ERR SM_CODE -- bun run test:smoke
if [ "$SM_CODE" -eq 0 ]; then
  check_pass "bun run test:smoke exits 0"
else
  check_fail "bun run test:smoke exits 0" "$(printf '%s\n%s' "$SM_OUT" "$SM_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0013 — Smoke Testing"
