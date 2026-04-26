# ADR 0021: Adopt OpenObserve as the OTLP Backend

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** observability
- **Related spec:** [`specs/observability/openobserve.md`](../specs/observability/openobserve.md)

## Context

ADR 0020 commits the CLI to OpenTelemetry as the emission surface. That choice is only operational once the OTLP traffic has somewhere to land that can store it, query it, alert on it, and correlate logs / traces / metrics by trace ID. Without a chosen backend, we ship spans into the void — or every developer points their local stack at a different store.

Competing options:

- **OpenObserve (this ADR).** Single OTLP-native binary, SQL-queryable, self-hostable.
- **Grafana Cloud / Loki + Tempo + Mimir.** Three-store architecture; correlation requires an extra UI layer; heavier ops.
- **Datadog / New Relic / Honeycomb.** Hosted, polished, expensive; locks the stack to a vendor.
- **OpenTelemetry Collector → file.** Useful for local debug; not a queryable store.

## Decision

Adopt OpenObserve as the OTLP backend, governed by `specs/observability/openobserve.md`. The local Compose topology (per ADR 0019) gains an `openobserve` service whose `5080` HTTP port is the OTLP HTTP endpoint the CLI exports to via `OTEL_EXPORTER_OTLP_ENDPOINT`. OpenObserve credentials are injected via `OTEL_EXPORTER_OTLP_HEADERS` from the environment / a Compose secret (no inline credentials in `compose.yaml`). Org and stream naming follow the convention documented in `docs/observability/README.md` so non-production telemetry stays segregated from production.

## Consequences

**Positive**

- Developers can `make up` and immediately see the same telemetry shape they will see in production at the configured port.
- Trace ↔ log ↔ metric correlation by trace ID works out of the box because all three signal types land in the same store.
- VRL pipelines do ingest-time enrichment server-side, keeping CLI code free of telemetry-shape concerns.

**Negative**

- Another container in the dev Compose topology — adds memory pressure and a dependency on OpenObserve's release cadence for security patches (handled by ADR 0017).
- An OpenObserve outage drops new ingest. Per `opentelemetry` rule 17 and `openobserve` rule 16, the application must not crash; we accept silent telemetry loss bounded by the SDK's batch buffer until the store recovers.
- Implementation: `openobserve` service in `compose.yaml`, `secrets/openobserve_token` mounted as a Compose secret, `docs/observability/README.md` org/stream naming + retention conventions land as a follow-up.
