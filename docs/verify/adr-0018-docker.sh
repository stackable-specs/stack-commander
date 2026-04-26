#!/usr/bin/env bash
# Verify ADR 0018 — Adopt Docker as the Image Format.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

for f in Dockerfile .dockerignore; do
  if [ -f "$f" ]; then
    check_pass "$f present"
  else
    check_fail "$f present" "missing"
  fi
done

stages="$(grep -cE '^FROM[[:space:]]+' Dockerfile)"
if [ "${stages:-0}" -ge 2 ]; then
  check_pass "Dockerfile is multi-stage" "stages: $stages"
else
  check_fail "Dockerfile is multi-stage" "stages: $stages"
fi

bad_from="$(grep -E '^FROM ' Dockerfile | awk '{print $2}' | grep -v '@sha256:' || true)"
if [ -z "$bad_from" ]; then
  check_pass "every FROM image is digest-pinned"
else
  check_fail "every FROM image is digest-pinned" "$(echo "$bad_from" | tr '\n' ' | ')"
fi

user_line="$(grep -E '^USER[[:space:]]+' Dockerfile | tail -1)"
if [ -n "$user_line" ] && ! echo "$user_line" | grep -Eq 'USER[[:space:]]+(root|0|0:0)$'; then
  check_pass "non-root USER set" "$user_line"
else
  check_fail "non-root USER set" "actual: ${user_line:-<missing>}"
fi

if grep -qE '^ENTRYPOINT \[' Dockerfile; then
  check_pass "ENTRYPOINT uses exec form"
else
  check_fail "ENTRYPOINT uses exec form"
fi

if have_tools docker; then
  run_cmd DB_OUT DB_ERR DB_CODE -- docker build -t typescript-bun-stack:verify .
  if [ "$DB_CODE" -eq 0 ]; then
    check_pass "docker build exits 0"
  else
    check_fail "docker build exits 0" "$(printf '%s\n%s' "$DB_OUT" "$DB_ERR" | tail -c 400 | tr '\n' ' ')"
  fi
else
  check_skip "docker build exits 0" "docker not on PATH"
fi

report_and_exit "ADR 0018 — Docker"
