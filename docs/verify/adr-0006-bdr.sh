#!/usr/bin/env bash
# Verify ADR 0006 — Adopt BDR for Behavior Decision Records.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if [ -d docs/bdr ]; then
  check_pass "docs/bdr/ exists"
else
  check_fail "docs/bdr/ exists" "directory not found"
  report_and_exit "ADR 0006 — BDR"
fi

for f in docs/bdr/README.md docs/bdr/000-template.md; do
  if [ -f "$f" ]; then
    check_pass "$(basename "$f") present"
  else
    check_fail "$(basename "$f") present" "missing"
  fi
done

bad=""
for f in docs/bdr/*.md; do
  [ -e "$f" ] || break
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  case "$base" in
    [0-9][0-9][0-9]-*.md) ;;
    *) bad="${bad:+$bad, }$base" ;;
  esac
done
if [ -z "$bad" ]; then
  check_pass "BDR filenames match NNN-<kebab>.md"
else
  check_fail "BDR filenames match NNN-<kebab>.md" "violations: $bad"
fi

if [ -f docs/bdr/001-greeting-command-renders-message.md ]; then
  bdr="docs/bdr/001-greeting-command-renders-message.md"
  if grep -Eq '^# BDR-001: ' "$bdr" &&
     grep -Eq '^## Status' "$bdr" &&
     grep -Eq '^## Behavior' "$bdr" &&
     grep -Eq '^## Acceptance Criteria' "$bdr" &&
     grep -Eq '^## Verification' "$bdr"; then
    check_pass "BDR-001 has required sections"
  else
    check_fail "BDR-001 has required sections"
  fi
else
  check_fail "BDR-001 present" "missing"
fi

report_and_exit "ADR 0006 — BDR"
