#!/usr/bin/env bash
# Verify ADR 0020 — Adopt OpenTelemetry for Application Instrumentation.

# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_tools jq bun

cd "$STACK_ROOT"

for pkg in \
	'@opentelemetry/api' \
	'@opentelemetry/api-logs' \
	'@opentelemetry/sdk-node' \
	'@opentelemetry/sdk-logs' \
	'@opentelemetry/sdk-metrics' \
	'@opentelemetry/exporter-trace-otlp-http' \
	'@opentelemetry/exporter-metrics-otlp-http' \
	'@opentelemetry/exporter-logs-otlp-http'; do
	version="$(jq -r --arg pkg "$pkg" '.dependencies[$pkg] // empty' package.json)"
	if echo "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+'; then
		check_pass "$pkg pinned exactly" "$version"
	else
		check_fail "$pkg pinned exactly" "actual: ${version:-<missing>}"
	fi
done

if [ -f src/observability.ts ]; then
	check_pass "src/observability.ts present"
else
	check_fail "src/observability.ts present" "missing"
	report_and_exit "ADR 0020 — OpenTelemetry"
fi

for needle in 'NodeSDK' 'OTLPTraceExporter' 'OTLPMetricExporter' 'OTLPLogExporter' 'BatchLogRecordProcessor' 'SpanStatusCode.ERROR'; do
	if grep -q "$needle" src/observability.ts 2>/dev/null; then
		check_pass "observability module references $needle"
	else
		check_fail "observability module references $needle"
	fi
done

if grep -q 'OTEL_EXPORTER_OTLP_PROTOCOL' compose.yaml .env.example 2>/dev/null &&
	grep -q 'OTEL_SERVICE_NAME' compose.yaml .env.example 2>/dev/null &&
	grep -q 'OTEL_ENABLED' compose.yaml .env.example 2>/dev/null; then
	check_pass "standard OTEL_* env vars surfaced in local config"
else
	check_fail "standard OTEL_* env vars surfaced in local config"
fi

if grep -q 'initializeObservability' src/cli.ts 2>/dev/null &&
	grep -q 'shutdownObservability' src/cli.ts 2>/dev/null; then
	check_pass "CLI initializes and shuts down telemetry once per process"
else
	check_fail "CLI initializes and shuts down telemetry once per process"
fi

run_cmd TC_OUT TC_ERR TC_CODE -- bun run typecheck
if [ "$TC_CODE" -eq 0 ]; then
	check_pass "typecheck passes with observability module enabled"
else
	check_fail "typecheck passes with observability module enabled" "$(printf '%s\n%s' "$TC_OUT" "$TC_ERR" | tail -c 400 | tr '\n' ' ')"
fi

report_and_exit "ADR 0020 — OpenTelemetry"
