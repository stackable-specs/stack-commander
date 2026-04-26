#!/usr/bin/env bash
# Verify ADR 0015 — Produce an SBOM for Every Released Artifact.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq

cd "$STACK_ROOT"

cdxgen_version="$(jq -r '.devDependencies["@cyclonedx/cdxgen"] // empty' package.json)"
if echo "$cdxgen_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+'; then
	check_pass "@cyclonedx/cdxgen pinned exactly" "$cdxgen_version"
else
	check_fail "@cyclonedx/cdxgen pinned exactly" "actual: ${cdxgen_version:-<missing>}"
fi

if jq -e '.scripts.sbom' package.json >/dev/null 2>&1; then
	check_pass "package.json defines sbom script"
else
	check_fail "package.json defines sbom script"
fi

if grep -q 'anchore/sbom-action' .github/workflows/ci.yml 2>/dev/null; then
	check_pass "CI emits an SBOM"
else
	check_fail "CI emits an SBOM"
fi

if grep -q 'upload-artifact' .github/workflows/ci.yml 2>/dev/null &&
	grep -q 'sbom-' .github/workflows/ci.yml 2>/dev/null; then
	check_pass "CI uploads SBOM as an artifact"
else
	check_fail "CI uploads SBOM as an artifact"
fi

report_and_exit "ADR 0015 — SBOM"
