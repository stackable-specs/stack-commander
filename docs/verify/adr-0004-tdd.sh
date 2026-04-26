#!/usr/bin/env bash
# Verify ADR 0004 — Red-Green-Refactor TDD.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools bun

cd "$STACK_ROOT"

test_count="$(list_test_ts | grep -c .)"
if [ "$test_count" -gt 0 ]; then
  check_pass "at least one *.test.ts file under src/" "found $test_count"
else
  check_fail "at least one *.test.ts file under src/" "none found"
fi

run_cmd BT_OUT BT_ERR BT_CODE -- bun test
if [ "$BT_CODE" -eq 0 ]; then
  check_pass "bun test exits 0 (no red or missing tests)"
else
  detail="$(printf '%s\n%s' "$BT_OUT" "$BT_ERR" | tail -c 400 | tr '\n' ' ')"
  check_fail "bun test exits 0 (no red or missing tests)" "$detail"
fi

skip_hits="$(grep_test_ts '(test|it|describe)\.skip *\(|\bxit *\(|\bxdescribe *\(')"
if [ -z "$skip_hits" ]; then
  check_pass "no skipped tests"
else
  while IFS= read -r hit; do
    file="$(echo "$hit" | awk -F: '{print $1}')"
    line="$(echo "$hit" | awk -F: '{print $2}')"
    text="$(echo "$hit" | cut -d: -f3-)"
    context="$(awk -v L="$line" 'NR>=L-3 && NR<L {print}' "$STACK_ROOT/$file")"
    if echo "$context" | grep -Eiq 'TODO|FIXME|issue[:/ #-]|https?://|remove[- ]by'; then
      check_pass "skipped test at $file:$line references an issue or removal date" "$text"
    else
      check_fail "skipped test at $file:$line references an issue or removal date" "$text"
    fi
  done <<EOF
$skip_hits
EOF
fi

only_hits="$(grep_test_ts '(test|it|describe)\.only *\(|\bfit *\(|\bfdescribe *\(')"
if [ -z "$only_hits" ]; then
  check_pass "no .only / fit / fdescribe in committed tests"
else
  check_fail "no .only / fit / fdescribe in committed tests" "$(echo "$only_hits" | head -3 | tr '\n' ' | ')"
fi

missing=""
while IFS= read -r src_file; do
  [ -z "$src_file" ] && continue
  colocated="${src_file%.ts}.test.ts"
  if [ ! -f "$colocated" ]; then
    rel="${src_file#$STACK_ROOT/}"
    missing="${missing:+$missing, }$rel"
  fi
done <<EOF
$(list_source_ts)
EOF
if [ -z "$missing" ]; then
  check_pass "every source module under src/ has a colocated *.test.ts"
else
  check_fail "every source module under src/ has a colocated *.test.ts" "missing: $missing"
fi

report_and_exit "ADR 0004 — Red-Green-Refactor TDD"
