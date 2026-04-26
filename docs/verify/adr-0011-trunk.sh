#!/usr/bin/env bash
# Verify ADR 0011 — Adopt Trunk Code Quality as the Lint Runner.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if [ -f .trunk/trunk.yaml ]; then
	check_pass ".trunk/trunk.yaml present"
else
	check_fail ".trunk/trunk.yaml present" "missing"
	report_and_exit "ADR 0011 — Trunk"
fi

cli_v="$(awk '/^[[:space:]]+version:/ && prev ~ /cli:/ {gsub(/"/, "", $2); print $2; exit} {prev=$0}' .trunk/trunk.yaml)"
if echo "$cli_v" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
	check_pass "trunk cli.version pinned" "$cli_v"
else
	check_fail "trunk cli.version pinned" "actual: ${cli_v:-<missing>}"
fi

bad_lint="$(awk '
  /^lint:/ {in_lint=1; next}
  in_lint && /^[a-z]/ {in_lint=0}
  in_lint && /^[[:space:]]+enabled:/ {in_enabled=1; next}
  in_enabled && /^[[:space:]]+[a-z]+:/ {in_enabled=0}
  in_enabled && /^[[:space:]]+- / {
    line=$0
    sub(/^[[:space:]]+-[[:space:]]+/, "", line)
    if (line !~ /@/) print line
  }
' .trunk/trunk.yaml)"
if [ -z "$bad_lint" ]; then
	check_pass "every lint.enabled tool has an explicit @version"
else
	check_fail "every lint.enabled tool has an explicit @version" "$bad_lint"
fi

if grep -q 'gitleaks@' .trunk/trunk.yaml && grep -q 'markdownlint@' .trunk/trunk.yaml; then
	check_pass "Trunk enables secret scanning and markdown linting"
else
	check_fail "Trunk enables secret scanning and markdown linting"
fi

if have_tools trunk; then
	run_cmd TR_OUT TR_ERR TR_CODE -- trunk config print
	if [ "$TR_CODE" -eq 0 ]; then
		check_pass "trunk config parses"
	else
		check_fail "trunk config parses" "$(printf '%s\n%s' "$TR_OUT" "$TR_ERR" | tail -c 300 | tr '\n' ' ')"
	fi
else
	check_skip "trunk config parses" "trunk CLI not on PATH"
fi

report_and_exit "ADR 0011 — Trunk"
