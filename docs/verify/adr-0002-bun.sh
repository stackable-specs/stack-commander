#!/usr/bin/env bash
# Verify ADR 0002 — Bun runtime and toolchain.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

pkg_manager="$(jq -r '.packageManager // empty' package.json)"
pm_pinned=0
case "$pkg_manager" in
  bun@[0-9]*.[0-9]*.[0-9]*) pm_pinned=1 ;;
esac
bun_version_file=0
[ -f "$STACK_ROOT/.bun-version" ] && bun_version_file=1

if [ "$pm_pinned" -eq 1 ] || [ "$bun_version_file" -eq 1 ]; then
  if [ "$pm_pinned" -eq 1 ]; then
    check_pass "bun version pinned (packageManager or .bun-version)" "packageManager = \"$pkg_manager\""
  else
    check_pass "bun version pinned (packageManager or .bun-version)" ".bun-version present"
  fi
else
  check_fail "bun version pinned (packageManager or .bun-version)" "neither packageManager \"bun@x.y.z\" nor .bun-version found"
fi

if [ -f "$STACK_ROOT/bun.lock" ] || [ -f "$STACK_ROOT/bun.lockb" ]; then
  check_pass "bun.lock (or bun.lockb) committed"
else
  check_fail "bun.lock (or bun.lockb) committed" "no Bun lockfile at repo root"
fi

for name in package-lock.json pnpm-lock.yaml yarn.lock; do
  if [ -f "$STACK_ROOT/$name" ]; then
    check_fail "no $name at repo root" "found"
  else
    check_pass "no $name at repo root"
  fi
done

banned_list="jest vitest mocha ava ts-node tsx nodemon dotenv bcrypt argon2 better-sqlite3 sqlite3 sql.js"
installed="$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' package.json)"
banned_found=""
for dep in $banned_list; do
  if echo "$installed" | grep -qx "$dep"; then
    banned_found="${banned_found:+$banned_found, }$dep"
  fi
done
if [ -z "$banned_found" ]; then
  check_pass "no banned runtime/toolchain dependencies"
else
  check_fail "no banned runtime/toolchain dependencies" "found: $banned_found"
fi

child_process_hits="$(grep_src_ts "from +['\"]node:child_process['\"]|require\\(['\"]node:child_process['\"]\\)")"
if [ -z "$child_process_hits" ]; then
  check_pass "no node:child_process imports in src/ (use Bun.spawn / Bun.\$)"
else
  check_fail "no node:child_process imports in src/ (use Bun.spawn / Bun.\$)" "$(echo "$child_process_hits" | head -3 | tr '\n' ' | ')"
fi

run_cmd BV_OUT BV_ERR BV_CODE -- bun --version
if [ "$BV_CODE" -eq 0 ]; then
  check_pass "bun binary available on PATH" "$BV_OUT"
else
  check_fail "bun binary available on PATH" "$BV_ERR"
fi

run_cmd BT_OUT BT_ERR BT_CODE -- bun test
if [ "$BT_CODE" -eq 0 ]; then
  check_pass "bun test exits 0"
else
  detail="$(printf '%s\n%s' "$BT_OUT" "$BT_ERR" | tail -c 400 | tr '\n' ' ')"
  check_fail "bun test exits 0" "$detail"
fi

report_and_exit "ADR 0002 — Bun runtime and toolchain"
