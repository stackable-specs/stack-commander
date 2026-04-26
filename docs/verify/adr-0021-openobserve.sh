#!/usr/bin/env bash
# Verify ADR 0021 — Adopt OpenObserve as the OTLP Backend.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$STACK_ROOT"

if grep -Eq '^  openobserve:' compose.yaml 2>/dev/null; then
	check_pass "compose.yaml declares openobserve service"
else
	check_fail "compose.yaml declares openobserve service"
	report_and_exit "ADR 0021 — OpenObserve"
fi

if grep -q 'openobserve/openobserve@sha256:' compose.yaml 2>/dev/null; then
	check_pass "OpenObserve image is digest-pinned"
else
	check_fail "OpenObserve image is digest-pinned"
fi

if grep -q 'OTEL_EXPORTER_OTLP_ENDPOINT: http://openobserve:5080' compose.yaml 2>/dev/null; then
	check_pass "CLI OTLP endpoint targets the openobserve service"
else
	check_fail "CLI OTLP endpoint targets the openobserve service"
fi

if grep -q 'OTEL_EXPORTER_OTLP_HEADERS_FILE' compose.yaml 2>/dev/null &&
	grep -q 'openobserve_token' compose.yaml 2>/dev/null; then
	check_pass "OpenObserve credentials are injected via secret file"
else
	check_fail "OpenObserve credentials are injected via secret file"
fi

if [ -f docs/observability/README.md ]; then
	check_pass "docs/observability/README.md present"
else
	check_fail "docs/observability/README.md present" "missing"
fi

if grep -qi 'retention' docs/observability/README.md 2>/dev/null &&
	grep -qi 'org' docs/observability/README.md 2>/dev/null &&
	grep -qi 'stream' docs/observability/README.md 2>/dev/null; then
	check_pass "observability docs cover naming and retention"
else
	check_fail "observability docs cover naming and retention"
fi

if have_tools docker; then
	run_cmd CFG_OUT CFG_ERR CFG_CODE -- docker compose -f compose.yaml -f compose.override.yaml config --quiet
	if [ "$CFG_CODE" -eq 0 ]; then
		check_pass "compose config remains valid with OpenObserve service"
	else
		check_fail "compose config remains valid with OpenObserve service" "$(printf '%s\n%s' "$CFG_OUT" "$CFG_ERR" | tail -c 400 | tr '\n' ' ')"
	fi
else
	check_skip "compose config remains valid with OpenObserve service" "docker not on PATH"
fi

report_and_exit "ADR 0021 — OpenObserve"
