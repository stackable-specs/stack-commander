#!/usr/bin/env bash
# Verify ADR 0016 — Adopt Dependency Management Policy.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq

cd "$STACK_ROOT"

for f in package.json bun.lock .npmrc .github/CODEOWNERS renovate.json; do
  if [ -f "$f" ]; then
    check_pass "$f present"
  else
    check_fail "$f present" "missing"
  fi
done

if grep -q '^registry=https://registry.npmjs.org/' .npmrc 2>/dev/null; then
  check_pass ".npmrc pins the npm registry"
else
  check_fail ".npmrc pins the npm registry"
fi

loose="$(jq -r '
  [(.dependencies // {}), (.devDependencies // {})]
  | add
  | to_entries[]
  | select(.value | test("^[0-9]+\\.[0-9]+\\.[0-9]+") | not)
  | "\(.key)=\(.value)"
' package.json)"
if [ -z "$loose" ]; then
  check_pass "all declared dependencies are exact-pinned"
else
  check_fail "all declared dependencies are exact-pinned" "$(echo "$loose" | head -3 | tr '\n' ' | ')"
fi

if grep -q '/package.json' .github/CODEOWNERS 2>/dev/null &&
   grep -q '/bun.lock' .github/CODEOWNERS 2>/dev/null; then
  check_pass "CODEOWNERS gates dependency surface"
else
  check_fail "CODEOWNERS gates dependency surface"
fi

report_and_exit "ADR 0016 — Dependency Management"
