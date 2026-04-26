#!/usr/bin/env bash
# Run every ADR verifier; exit nonzero if any fails.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="
adr-0001-typescript.sh
adr-0002-bun.sh
adr-0003-commander.sh
adr-0004-tdd.sh
adr-0005-madr.sh
adr-0006-bdr.sh
adr-0007-conventional-commits.sh
adr-0008-unit-testing.sh
adr-0009-integration-testing.sh
adr-0010-property-based-testing.sh
adr-0011-trunk.sh
adr-0012-prek.sh
adr-0013-smoke-testing.sh
adr-0014-typedoc.sh
adr-0015-sbom.sh
adr-0016-dependency-management.sh
adr-0017-renovate.sh
adr-0018-docker.sh
adr-0019-docker-compose.sh
adr-0020-opentelemetry.sh
adr-0021-openobserve.sh
"

failed=0
total=0
for s in $SCRIPTS; do
  total=$((total + 1))
  bash "$SCRIPT_DIR/$s" || failed=$((failed + 1))
done

echo
if [ "$failed" -eq 0 ]; then
  echo "all $total ADR verifiers passed"
  exit 0
else
  echo "$failed of $total ADR verifiers failed"
  exit 1
fi
