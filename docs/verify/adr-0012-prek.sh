#!/usr/bin/env bash
# Verify ADR 0012 — Adopt prek as the Single Git-Hook Runner.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if [ -f prek.toml ]; then
	check_pass "prek.toml present"
else
	check_fail "prek.toml present" "missing"
	report_and_exit "ADR 0012 — prek"
fi

for needle in 'gitleaks' 'commitlint' 'trunk-check' 'trunk-fmt' 'pre-push' 'commit-msg'; do
	if grep -q "$needle" prek.toml; then
		check_pass "prek.toml references $needle"
	else
		check_fail "prek.toml references $needle"
	fi
done

if grep -Eq 'trunk-(check-pre-push|fmt-pre-commit)' .trunk/trunk.yaml 2>/dev/null; then
	check_fail "Trunk hook actions disabled in favor of prek"
else
	check_pass "Trunk hook actions disabled in favor of prek"
fi

if [ -x scripts/install-prek.sh ]; then
	check_pass "scripts/install-prek.sh present and executable"
else
	check_fail "scripts/install-prek.sh present and executable"
fi

if [ -f .github/workflows/prek-autoupdate.yml ]; then
	check_pass "prek auto-update workflow present"
else
	check_fail "prek auto-update workflow present"
fi

if grep -q 'name: prek run --all-files' .github/workflows/ci.yml 2>/dev/null &&
	grep -q 'cargo install --locked --git https://github.com/j178/prek --tag v0.3.10 prek' .github/workflows/ci.yml 2>/dev/null; then
	check_pass "CI runs prek"
else
	check_fail "CI runs prek"
fi

report_and_exit "ADR 0012 — prek"
