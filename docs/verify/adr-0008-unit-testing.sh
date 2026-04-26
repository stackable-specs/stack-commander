#!/usr/bin/env bash
# Verify ADR 0008 — Adopt Unit Testing Discipline.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

if jq -e '.scripts.test and .scripts["test:ci"]' package.json >/dev/null 2>&1; then
	check_pass "package.json defines test and test:ci scripts"
else
	check_fail "package.json defines test and test:ci scripts"
fi

count="$(find src -type f -name '*.test.ts' 2>/dev/null | wc -l | tr -d ' ')"
if [ "${count:-0}" -gt 0 ]; then
	check_pass "colocated unit test files exist under src/" "found $count"
else
	check_fail "colocated unit test files exist under src/" "none found"
fi

if grep -R "describe('" src/*.test.ts src/commands/*.test.ts >/dev/null 2>&1; then
	check_pass "unit tests use behavior-oriented descriptions"
else
	check_fail "unit tests use behavior-oriented descriptions"
fi

run_cmd TEST_OUT TEST_ERR TEST_CODE -- bun run test:ci
if [ "$TEST_CODE" -eq 0 ]; then
	check_pass "bun run test:ci exits 0"
else
	check_fail "bun run test:ci exits 0" "$(printf '%s\n%s' "$TEST_OUT" "$TEST_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0008 — Unit Testing"
