#!/usr/bin/env bash
# Verify ADR 0003 — Commander.js CLI interface.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq

cd "$STACK_ROOT"

commander_version="$(jq -r '.dependencies.commander // empty' package.json)"
if [ -z "$commander_version" ]; then
	check_fail "commander pinned exactly in dependencies" "missing dependencies.commander"
elif echo "$commander_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$'; then
	check_pass "commander pinned exactly in dependencies" "dependencies.commander = \"$commander_version\""
else
	check_fail "commander pinned exactly in dependencies" "dependencies.commander = \"$commander_version\" (not exact)"
fi

CLI="src/cli.ts"
if [ ! -f "$STACK_ROOT/$CLI" ]; then
	check_fail "src/cli.ts exists" "missing"
	report_and_exit "ADR 0003 — Commander.js CLI interface"
fi

cli_text="$(cat "$STACK_ROOT/$CLI")"

if echo "$cli_text" | grep -Eq "import *\\{[^}]*\\bCommand\\b[^}]*\\} *from *['\"]commander['\"]"; then
	check_pass "src/cli.ts imports { Command } from 'commander'"
else
	check_fail "src/cli.ts imports { Command } from 'commander'"
fi

if echo "$cli_text" | grep -Eq 'new +Command *\('; then
	check_pass 'src/cli.ts constructs a top-level `new Command()`'
else
	check_fail 'src/cli.ts constructs a top-level `new Command()`'
fi

if echo "$cli_text" | grep -Eq '\.version *\('; then
	check_pass 'src/cli.ts calls `.version(`'
else
	check_fail 'src/cli.ts calls `.version(`'
fi

if echo "$cli_text" | grep -Eq 'pkg\.version|packageJson\.version|package\.json.*version'; then
	check_pass "src/cli.ts reads version from package.json (not a hardcoded string)"
else
	check_fail "src/cli.ts reads version from package.json (not a hardcoded string)"
fi

if echo "$cli_text" | grep -Eq '\.showHelpAfterError *\('; then
	check_pass 'src/cli.ts calls `.showHelpAfterError(`'
else
	check_fail 'src/cli.ts calls `.showHelpAfterError(`'
fi

exit_hits="$(grep_src_ts '\bprocess\.exit *\(')"
if [ -z "$exit_hits" ]; then
	check_pass "no process.exit() in src/** (use command.error or let parseAsync exit)"
else
	check_fail "no process.exit() in src/** (use command.error or let parseAsync exit)" "$(echo "$exit_hits" | head -3 | tr '\n' ' | ')"
fi

exit_override_hits="$(grep_src_ts '\bexitOverride *\(')"
if [ -n "$exit_override_hits" ]; then
	sites="$(echo "$exit_override_hits" | awk -F: '{print $1":"$2}' | tr '\n' ',' | sed 's/,$//')"
	check_pass "exitOverride() wired somewhere in src/ so tests can capture exits in-process" "$sites"
else
	check_fail "exitOverride() wired somewhere in src/ so tests can capture exits in-process" "0 sites"
fi

configure_output_hits="$(grep_src_ts '\bconfigureOutput *\(')"
if [ -n "$configure_output_hits" ]; then
	sites="$(echo "$configure_output_hits" | awk -F: '{print $1":"$2}' | tr '\n' ',' | sed 's/,$//')"
	check_pass "configureOutput() wired somewhere in src/ so tests can capture stdout/stderr" "$sites"
else
	check_fail "configureOutput() wired somewhere in src/ so tests can capture stdout/stderr" "0 sites"
fi

spawn_hits="$(grep_test_ts 'Bun\.spawn|child_process|execSync')"
if [ -z "$spawn_hits" ]; then
	check_pass "tests do not spawn subprocesses for parsing/handler coverage"
else
	check_fail "tests do not spawn subprocesses for parsing/handler coverage" "$(echo "$spawn_hits" | head -3 | tr '\n' ' | ')"
fi

check_comment_adjacent() {
	local label="$1"
	local hits="$2"
	if [ -z "$hits" ]; then
		check_pass "no $label call sites"
		return
	fi
	while IFS= read -r hit; do
		local file line context has_comment
		file="$(echo "$hit" | awk -F: '{print $1}')"
		line="$(echo "$hit" | awk -F: '{print $2}')"
		context="$(awk -v L="$line" 'NR>=L-2 && NR<=L {print}' "$STACK_ROOT/$file")"
		if echo "$context" | grep -Eq '//|/\*'; then
			check_pass "$label at $file:$line has a justifying comment"
		else
			check_fail "$label at $file:$line has a justifying comment" "no // or /* within 2 lines above"
		fi
	done <<EOF
$hits
EOF
}

allow_unknown_hits="$(grep_src_ts '\.allowUnknownOption *\( *true *\)')"
check_comment_adjacent "allowUnknownOption(true)" "$allow_unknown_hits"

allow_excess_hits="$(grep_src_ts '\.allowExcessArguments *\( *true *\)')"
check_comment_adjacent "allowExcessArguments(true)" "$allow_excess_hits"

report_and_exit "ADR 0003 — Commander.js CLI interface"
