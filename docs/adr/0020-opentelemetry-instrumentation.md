# ADR 0020: Adopt OpenTelemetry for Application Instrumentation

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** observability
- **Related spec:** [`specs/observability/opentelemetry.md`](../specs/observability/opentelemetry.md)

## Context

The CLI emits useful telemetry: command invocation events, latency for long-running subcommands, errors with stack context, and (when applicable) outbound HTTP calls. Without a vendor-neutral instrumentation surface, those signals become ad-hoc `console.log` calls and per-vendor SDK code: a switch of backend or a sibling tool both require a global rewrite. We need a single instrumentation contract — span shape, attribute names, propagation — that any OTLP-compatible backend can consume.

Competing options:

- **OpenTelemetry SDK providers and instrumentation libraries (this ADR).**
- **Vendor-specific SDK (Datadog, New Relic, Honeycomb, Sentry tracing).** Locks the codebase to a single backend.
- **Roll our own tracer over `console.log` and structured JSON.** Reinvents context propagation and semantic conventions; no auto-instrumentation; can't satisfy ADR 0021.
- **Skip telemetry from the CLI.** Loses the operational signal real users care about.

## Decision

Adopt OpenTelemetry as the application instrumentation surface, governed by `specs/observability/opentelemetry.md`. A single `src/observability.ts` module initializes the `TracerProvider`, `MeterProvider`, and `LoggerProvider` exactly once at process startup using a `Resource` keyed on `service.name`, `service.version`, and `deployment.environment` from the standard `OTEL_*` env vars. Instrumentation libraries (`@opentelemetry/instrumentation-http` for outbound HTTP, `@opentelemetry/instrumentation-bunyan` or equivalent if a logger bridge is needed) cover common surfaces when the CLI grows beyond its current manual command span. Telemetry is opt-in via `OTEL_ENABLED` so unit tests don't open exporters.

## Consequences

**Positive**

- Backend choice is a config change, not a code change; ADR 0021 (OpenObserve) consumes this without further code edits.
- Every outbound HTTP call gets a span with `http.*` semantic-convention attributes for free.
- Resource attributes (service name, version, environment) come from a single source — env vars — per `opentelemetry` rule 4.

**Negative**

- Adds a non-trivial dependency surface (`@opentelemetry/api`, provider SDK packages, OTLP HTTP exporters, and future instrumentation packages) that must move in lockstep on upgrades — Renovate's `opentelemetry` group rule (per ADR 0017) handles this.
- Requires a running OTLP collector / backend; the spec rule "do not crash on exporter failure" means silent telemetry loss if the backend disappears.
- Implementation: `src/observability.ts`, OTel deps in `package.json`, opt-in toggle, and `OTEL_*` env-var injection land as a follow-up.
