#!/usr/bin/env bash
# Verify ADR 0009 — Adopt Integration Testing Discipline.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

if [ -d tests/integration ]; then
  check_pass "tests/integration/ present"
else
  check_fail "tests/integration/ present" "missing"
  report_and_exit "ADR 0009 — Integration Testing"
fi

count="$(find tests/integration -type f -name '*.test.ts' 2>/dev/null | wc -l | tr -d ' ')"
if [ "${count:-0}" -gt 0 ]; then
  check_pass "at least one integration test file exists" "found $count"
else
  check_fail "at least one integration test file exists" "none found"
fi

if jq -e '.scripts["test:integration"]' package.json >/dev/null 2>&1; then
  check_pass "package.json defines test:integration script"
else
  check_fail "package.json defines test:integration script"
fi

if grep -q 'bun run test:integration' .github/workflows/ci.yml 2>/dev/null; then
  check_pass "CI runs integration tests"
else
  check_fail "CI runs integration tests"
fi

run_cmd IT_OUT IT_ERR IT_CODE -- bun run test:integration
if [ "$IT_CODE" -eq 0 ]; then
  check_pass "bun run test:integration exits 0"
else
  check_fail "bun run test:integration exits 0" "$(printf '%s\n%s' "$IT_OUT" "$IT_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0009 — Integration Testing"
