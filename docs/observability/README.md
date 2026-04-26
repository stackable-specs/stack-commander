# Observability conventions (ADR-0020 / ADR-0021)

This stack emits telemetry per [`docs/specs/observability/opentelemetry.md`](../specs/observability/opentelemetry.md) and stores it in OpenObserve per [`docs/specs/observability/openobserve.md`](../specs/observability/openobserve.md).

## Organization and stream naming

| Layer         | Convention               | Example                                |
| ------------- | ------------------------ | -------------------------------------- |
| Org           | `<environment>`          | `production`, `staging`, `local`, `ci` |
| Trace stream  | `default`                | `local / default`                      |
| Log stream    | `<service-name>-logs`    | `local / typescript-bun-cli-logs`      |
| Metric stream | `<service-name>-metrics` | `local / typescript-bun-cli-metrics`   |
| Debug data    | `<environment>-debug`    | `local-debug`                          |

## Retention defaults

| Signal  | Org                 | Retention |
| ------- | ------------------- | --------- |
| traces  | `production`        | 7 days    |
| logs    | `production`        | 30 days   |
| metrics | `production`        | 90 days   |
| any     | `staging` / `local` | 7 days    |
| any     | `*-debug`           | 24 hours  |

## Required resource attributes

Every emitted signal carries:

- `service.name` from `OTEL_SERVICE_NAME`
- `service.version` from `OTEL_RESOURCE_ATTRIBUTES`
- `deployment.environment` from `OTEL_RESOURCE_ATTRIBUTES`

## Secret handling

OpenObserve credentials are injected through `OTEL_EXPORTER_OTLP_HEADERS_FILE` and read from a mounted secret file. Credentials are never committed to `compose.yaml`, `.env`, or source files.
