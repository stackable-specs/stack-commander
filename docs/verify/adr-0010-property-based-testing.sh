#!/usr/bin/env bash
# Verify ADR 0010 — Adopt Property-Based Testing for Invariants.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

fc_version="$(jq -r '.devDependencies["fast-check"] // empty' package.json)"
if echo "$fc_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+'; then
	check_pass "fast-check pinned exactly in devDependencies" "$fc_version"
else
	check_fail "fast-check pinned exactly in devDependencies" "actual: ${fc_version:-<missing>}"
fi

if [ -d tests/property ]; then
	check_pass "tests/property/ present"
else
	check_fail "tests/property/ present" "missing"
	report_and_exit "ADR 0010 — Property-Based Testing"
fi

if grep -R 'fc\.property\|fc\.asyncProperty' tests/property >/dev/null 2>&1; then
	check_pass "property tests use fast-check properties"
else
	check_fail "property tests use fast-check properties"
fi

if grep -R 'numRuns:\|examples:' tests/property >/dev/null 2>&1; then
	check_pass "property tests configure runs or examples"
else
	check_fail "property tests configure runs or examples"
fi

run_cmd PT_OUT PT_ERR PT_CODE -- bun test tests/property
if [ "$PT_CODE" -eq 0 ]; then
	check_pass "property test suite exits 0"
else
	check_fail "property test suite exits 0" "$(printf '%s\n%s' "$PT_OUT" "$PT_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0010 — Property-Based Testing"
