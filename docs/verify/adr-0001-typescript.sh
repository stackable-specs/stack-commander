#!/usr/bin/env bash
# Verify ADR 0001 — TypeScript strict language.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bunx

cd "$STACK_ROOT"

ts_version="$(jq -r '.devDependencies.typescript // empty' package.json)"
if [ -z "$ts_version" ]; then
	check_fail "typescript pinned exactly in devDependencies" "missing devDependencies.typescript"
elif echo "$ts_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$'; then
	check_pass "typescript pinned exactly in devDependencies" "devDependencies.typescript = \"$ts_version\""
else
	check_fail "typescript pinned exactly in devDependencies" "devDependencies.typescript = \"$ts_version\" (not an exact version)"
fi

for flag in strict noUncheckedIndexedAccess noImplicitOverride noFallthroughCasesInSwitch noEmit; do
	value="$(jq -r ".compilerOptions.${flag} // empty" tsconfig.json)"
	if [ "$value" = "true" ]; then
		check_pass "tsconfig.compilerOptions.${flag} === true" "actual: true"
	else
		check_fail "tsconfig.compilerOptions.${flag} === true" "actual: ${value:-<missing>}"
	fi
done

run_cmd TSC_OUT TSC_ERR TSC_CODE -- bunx tsc --noEmit
if [ "$TSC_CODE" -eq 0 ]; then
	check_pass "tsc --noEmit exits 0"
else
	detail="$(printf '%s\n%s' "$TSC_OUT" "$TSC_ERR" | head -c 400 | tr '\n' ' ')"
	check_fail "tsc --noEmit exits 0" "$detail"
fi

# Any explicit `any`: `: any`, `<any>`, `as any` — ignoring word-character neighbours on the `any` tail.
any_hits="$(grep_src_ts '(: *any([^A-Za-z0-9_]|$))|<any>|(as +any([^A-Za-z0-9_]|$))')"
if [ -z "$any_hits" ]; then
	check_pass 'no explicit `any` in src/**/*.ts'
else
	check_fail 'no explicit `any` in src/**/*.ts' "$(echo "$any_hits" | head -3 | tr '\n' ' | ')"
fi

require_hits="$(grep_src_ts '\brequire *\(')"
if [ -z "$require_hits" ]; then
	check_pass "no CommonJS require() in src/**/*.ts"
else
	check_fail "no CommonJS require() in src/**/*.ts" "$(echo "$require_hits" | head -3 | tr '\n' ' | ')"
fi

module_exports_hits="$(grep_src_ts '\bmodule\.exports\b')"
if [ -z "$module_exports_hits" ]; then
	check_pass "no module.exports in src/**/*.ts"
else
	check_fail "no module.exports in src/**/*.ts" "$(echo "$module_exports_hits" | head -3 | tr '\n' ' | ')"
fi

if [ -f "$STACK_ROOT/eslint.config.js" ]; then
	check_pass "eslint.config.js present"
else
	check_fail "eslint.config.js present" "file not found"
fi

if grep -q 'recommendedTypeChecked' "$STACK_ROOT/eslint.config.js" 2>/dev/null; then
	check_pass "eslint flat config uses typescript-eslint recommendedTypeChecked"
else
	check_fail "eslint flat config uses typescript-eslint recommendedTypeChecked"
fi

run_cmd LINT_OUT LINT_ERR LINT_CODE -- bunx eslint .
if [ "$LINT_CODE" -eq 0 ]; then
	check_pass "eslint . exits 0"
else
	detail="$(printf '%s\n%s' "$LINT_OUT" "$LINT_ERR" | head -c 400 | tr '\n' ' ')"
	check_fail "eslint . exits 0" "$detail"
fi

run_cmd FMT_OUT FMT_ERR FMT_CODE -- bunx prettier --check .
if [ "$FMT_CODE" -eq 0 ]; then
	check_pass "prettier --check . exits 0"
else
	detail="$(printf '%s\n%s' "$FMT_OUT" "$FMT_ERR" | head -c 400 | tr '\n' ' ')"
	check_fail "prettier --check . exits 0" "$detail"
fi

report_and_exit "ADR 0001 — TypeScript strict language"
