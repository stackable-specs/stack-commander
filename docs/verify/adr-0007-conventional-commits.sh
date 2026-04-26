#!/usr/bin/env bash
# Verify ADR 0007 — Adopt Conventional Commits.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if [ -f .commitlintrc.yaml ]; then
	check_pass ".commitlintrc.yaml present"
else
	check_fail ".commitlintrc.yaml present" "missing"
fi

if grep -q 'config-conventional' .commitlintrc.yaml 2>/dev/null; then
	check_pass ".commitlintrc.yaml extends @commitlint/config-conventional"
else
	check_fail ".commitlintrc.yaml extends @commitlint/config-conventional"
fi

if grep -Eq 'commitlint' prek.toml .github/workflows/ci.yml 2>/dev/null; then
	check_pass "local hooks and CI reference commitlint"
else
	check_fail "local hooks and CI reference commitlint"
fi

header_limit="$(awk '/header-max-length/ {gsub(/[][]|,/, " "); print $4; exit}' .commitlintrc.yaml)"
if [ "$header_limit" = "72" ]; then
	check_pass "subject length capped at 72 chars"
else
	check_fail "subject length capped at 72 chars" "actual: ${header_limit:-<missing>}"
fi

missing=""
for type in feat fix docs style refactor perf test build ci chore revert; do
	if ! grep -Eq "^[[:space:]]+-[[:space:]]*(-[[:space:]]+)?${type}$" .commitlintrc.yaml; then
		missing="${missing:+$missing, }$type"
	fi
done
if [ -z "$missing" ]; then
	check_pass "allowed Conventional Commit types enumerated"
else
	check_fail "allowed Conventional Commit types enumerated" "missing: $missing"
fi

if [ -d .git ] && have_tools git; then
	bad=""
	count=0
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		count=$((count + 1))
		if ! echo "$line" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: .+'; then
			bad="${bad:+$bad | }$line"
		fi
	done <<EOF
$(git log -n 20 --pretty=%s 2>/dev/null)
EOF
	if [ "$count" -eq 0 ]; then
		check_skip "recent commits parse as Conventional Commits" "no git history"
	elif [ -z "$bad" ]; then
		check_pass "last $count commits parse as Conventional Commits"
	else
		check_fail "last $count commits parse as Conventional Commits" "$bad"
	fi
else
	check_skip "recent commits parse as Conventional Commits" "not a git repo"
fi

report_and_exit "ADR 0007 — Conventional Commits"
