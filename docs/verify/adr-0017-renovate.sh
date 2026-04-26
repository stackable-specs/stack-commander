#!/usr/bin/env bash
# Verify ADR 0017 — Adopt the Renovate Configuration Spec.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq

cd "$STACK_ROOT"

if [ -f renovate.json ]; then
	check_pass "renovate.json present"
else
	check_fail "renovate.json present" "missing"
	report_and_exit "ADR 0017 — Renovate"
fi

schema="$(jq -r '."$schema" // empty' renovate.json)"
if [ "$schema" = "https://docs.renovatebot.com/renovate-schema.json" ]; then
	check_pass "schema reference pinned"
else
	check_fail "schema reference pinned" "actual: ${schema:-<missing>}"
fi

for key in timezone prConcurrentLimit prHourlyLimit; do
	value="$(jq -r ".${key} // empty" renovate.json)"
	if [ -n "$value" ]; then
		check_pass "${key} set" "$value"
	else
		check_fail "${key} set" "missing"
	fi
done

if jq -e '.dependencyDashboard == true and .lockFileMaintenance.enabled == true and .vulnerabilityAlerts.enabled == true' renovate.json >/dev/null 2>&1; then
	check_pass "dashboard, lockfile maintenance, and vulnerability alerts enabled"
else
	check_fail "dashboard, lockfile maintenance, and vulnerability alerts enabled"
fi

if grep -q 'renovate-config-validator' .github/workflows/ci.yml 2>/dev/null; then
	check_pass "CI validates renovate.json"
else
	check_fail "CI validates renovate.json"
fi

if [ -f docs/dependencies/renovate.md ]; then
	check_pass "Renovate operating model documented"
else
	check_fail "Renovate operating model documented"
fi

if have_tools npx; then
	run_cmd RV_OUT RV_ERR RV_CODE -- npx --yes --package renovate -- renovate-config-validator --strict renovate.json
	if [ "$RV_CODE" -eq 0 ]; then
		check_pass "renovate-config-validator --strict exits 0"
	else
		check_fail "renovate-config-validator --strict exits 0" "$(printf '%s\n%s' "$RV_OUT" "$RV_ERR" | tail -c 400 | tr '\n' ' ')"
	fi
else
	check_skip "renovate-config-validator --strict exits 0" "npx not on PATH"
fi

report_and_exit "ADR 0017 — Renovate"
