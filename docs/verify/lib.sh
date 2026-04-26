#!/usr/bin/env bash
# Shared helpers for docs/verify/*.sh. Source from other scripts; do not run directly.

# Resolve stack root from this file's location: docs/verify/lib.sh -> stack root is ../..
if [ -z "${STACK_ROOT-}" ]; then
	STACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
	export STACK_ROOT
fi

if [ -t 1 ]; then
	RED=$'\033[31m'
	GREEN=$'\033[32m'
	YELLOW=$'\033[33m'
	DIM=$'\033[2m'
	RESET=$'\033[0m'
else
	RED=""
	GREEN=""
	YELLOW=""
	DIM=""
	RESET=""
fi

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_SKIPPED=0
CHECKS_RESULTS=()

require_tools() {
	local missing=""
	local t
	for t in "$@"; do
		if ! command -v "$t" >/dev/null 2>&1; then
			missing="${missing:+$missing, }$t"
		fi
	done
	if [ -n "$missing" ]; then
		echo "missing required tool(s): $missing" >&2
		echo "install jq with: brew install jq (or your OS package manager)" >&2
		exit 2
	fi
}

have_tools() {
	local t
	for t in "$@"; do
		command -v "$t" >/dev/null 2>&1 || return 1
	done
	return 0
}

_record() {
	local status="$1"
	local name="$2"
	local detail="${3-}"
	local mark
	case "$status" in
	pass)
		mark="${GREEN}PASS${RESET}"
		CHECKS_PASSED=$((CHECKS_PASSED + 1))
		;;
	fail)
		mark="${RED}FAIL${RESET}"
		CHECKS_FAILED=$((CHECKS_FAILED + 1))
		;;
	skip)
		mark="${YELLOW}SKIP${RESET}"
		CHECKS_SKIPPED=$((CHECKS_SKIPPED + 1))
		;;
	esac
	if [ -n "$detail" ]; then
		CHECKS_RESULTS[${#CHECKS_RESULTS[@]}]="${mark}  ${name} ${DIM}— ${detail}${RESET}"
	else
		CHECKS_RESULTS[${#CHECKS_RESULTS[@]}]="${mark}  ${name}"
	fi
}

check_pass() { _record "pass" "$1" "${2-}"; }
check_fail() { _record "fail" "$1" "${2-}"; }
check_skip() { _record "skip" "$1" "${2-}"; }

# check NAME STATUS [DETAIL] — STATUS 0 is pass, nonzero is fail.
check() {
	if [ "$2" -eq 0 ]; then
		_record "pass" "$1" "${3-}"
	else
		_record "fail" "$1" "${3-}"
	fi
}

report_and_exit() {
	local title="$1"
	echo
	echo "== ${title} =="
	local i=0
	local n=${#CHECKS_RESULTS[@]}
	while [ "$i" -lt "$n" ]; do
		echo "  ${CHECKS_RESULTS[$i]}"
		i=$((i + 1))
	done
	local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_SKIPPED))
	if [ "$CHECKS_FAILED" -eq 0 ]; then
		echo "${GREEN}${CHECKS_PASSED}/${total} passed${RESET}${CHECKS_SKIPPED:+ (${YELLOW}${CHECKS_SKIPPED} skipped${RESET})}"
		exit 0
	else
		echo "${RED}${CHECKS_FAILED} of ${total} checks failed${RESET}${CHECKS_SKIPPED:+ (${YELLOW}${CHECKS_SKIPPED} skipped${RESET})}"
		exit 1
	fi
}

# Capture output of a command while recording its exit code.
# Usage: run_cmd VAR_STDOUT VAR_STDERR VAR_CODE -- cmd args...
run_cmd() {
	local out_var="$1"
	local err_var="$2"
	local code_var="$3"
	shift 3
	[ "$1" = "--" ] && shift
	local tmp_out tmp_err code
	tmp_out="$(mktemp)"
	tmp_err="$(mktemp)"
	"$@" >"$tmp_out" 2>"$tmp_err"
	code=$?
	eval "$out_var=\$(cat \"\$tmp_out\")"
	eval "$err_var=\$(cat \"\$tmp_err\")"
	eval "$code_var=$code"
	rm -f "$tmp_out" "$tmp_err"
}

# Return all *.ts files under src/ (excluding *.test.ts) as newline-separated list.
list_source_ts() {
	find "$STACK_ROOT/src" -type f -name '*.ts' ! -name '*.test.ts' 2>/dev/null
}

list_test_ts() {
	find "$STACK_ROOT/src" -type f -name '*.test.ts' 2>/dev/null
}

# Grep across src/**/*.ts with ERE. Returns "file:line:text" lines, or nothing if no matches.
grep_src_ts() {
	local pattern="$1"
	(cd "$STACK_ROOT" && grep -rEn --include='*.ts' "$pattern" src 2>/dev/null) || true
}

grep_test_ts() {
	local pattern="$1"
	(cd "$STACK_ROOT" && grep -rEn --include='*.test.ts' "$pattern" src 2>/dev/null) || true
}
