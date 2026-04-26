#!/usr/bin/env bash
# Verify ADR 0005 — Adopt MADR for Architectural Decision Records.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if [ -d docs/adr ]; then
  check_pass "docs/adr/ exists"
else
  check_fail "docs/adr/ exists" "directory not found"
  report_and_exit "ADR 0005 — MADR"
fi

if [ -f docs/adr/README.md ]; then
  check_pass "docs/adr/README.md index present"
else
  check_fail "docs/adr/README.md index present" "missing"
fi

bad_names=""
for f in docs/adr/*.md; do
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  if ! echo "$base" | grep -Eq '^[0-9]{4}-[a-z0-9-]+\.md$'; then
    bad_names="${bad_names:+$bad_names, }$base"
  fi
done
if [ -z "$bad_names" ]; then
  check_pass "ADR filenames match NNN-<kebab>.md"
else
  check_fail "ADR filenames match NNN-<kebab>.md" "violations: $bad_names"
fi

bad_struct=""
for f in docs/adr/*.md; do
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  num="${base%%-*}"
  if ! grep -Eq "^# ADR[- ]?${num}: " "$f"; then
    bad_struct="${bad_struct:+$bad_struct, }$base(no-title)"
    continue
  fi
  if ! grep -Eq '^## (Status|Context|Decision|Consequences)' "$f"; then
    bad_struct="${bad_struct:+$bad_struct, }$base(no-madr-sections)"
  fi
done
if [ -z "$bad_struct" ]; then
  check_pass "every ADR has MADR-style title and sections"
else
  check_fail "every ADR has MADR-style title and sections" "$bad_struct"
fi

missing_in_index=""
for f in docs/adr/*.md; do
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  if ! grep -q "$base" docs/adr/README.md 2>/dev/null; then
    missing_in_index="${missing_in_index:+$missing_in_index, }$base"
  fi
done
if [ -z "$missing_in_index" ]; then
  check_pass "ADR index references every ADR file"
else
  check_fail "ADR index references every ADR file" "missing: $missing_in_index"
fi

report_and_exit "ADR 0005 — MADR"
