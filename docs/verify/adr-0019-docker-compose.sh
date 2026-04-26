#!/usr/bin/env bash
# Verify ADR 0019 — Adopt Docker Compose for Local Dev and Single-Host Topology.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

for f in compose.yaml compose.override.yaml .env.example; do
	if [ -f "$f" ]; then
		check_pass "$f present"
	else
		check_fail "$f present" "missing"
	fi
done

if grep -Eq '^version:' compose.yaml 2>/dev/null; then
	check_fail "compose.yaml omits deprecated top-level version key"
else
	check_pass "compose.yaml omits deprecated top-level version key"
fi

if grep -Eq '^name:' compose.yaml 2>/dev/null; then
	check_pass "compose.yaml sets an explicit project name"
else
	check_fail "compose.yaml sets an explicit project name"
fi

if grep -q 'profiles:' compose.yaml 2>/dev/null; then
	check_pass "compose.yaml uses profiles for optional services"
else
	check_fail "compose.yaml uses profiles for optional services"
fi

if grep -q '^secrets:' compose.yaml 2>/dev/null &&
	grep -q 'openobserve_token' compose.yaml 2>/dev/null; then
	check_pass "compose.yaml declares secrets explicitly"
else
	check_fail "compose.yaml declares secrets explicitly"
fi

if have_tools docker; then
	run_cmd CFG_OUT CFG_ERR CFG_CODE -- docker compose -f compose.yaml -f compose.override.yaml config --quiet
	if [ "$CFG_CODE" -eq 0 ]; then
		check_pass "docker compose config validates"
	else
		check_fail "docker compose config validates" "$(printf '%s\n%s' "$CFG_OUT" "$CFG_ERR" | tail -c 400 | tr '\n' ' ')"
	fi
else
	check_skip "docker compose config validates" "docker not on PATH"
fi

report_and_exit "ADR 0019 — Docker Compose"
