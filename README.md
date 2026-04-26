# typescript-bun stack

Reference CLI stack for Bun + TypeScript, with architecture decisions in [docs/adr/](docs/adr/README.md) and behavior contracts in [docs/bdr/](docs/bdr/README.md).

## Setup

1. `bun install --frozen-lockfile`
2. `bun run prek:install`
3. `bun run test`
4. `bun run build`

## Common commands

- `bun run cli -- greet --name Ada`
- `bun run typecheck`
- `bun run lint`
- `bun run docs`
- `bun run test:integration`
- `bun run test:smoke`
- `docker compose up openobserve`

## Dependency policy

This stack resolves packages from the public npm registry (`https://registry.npmjs.org/`) and commits `bun.lock`. Dependency changes to `package.json` and `bun.lock` are CODEOWNERS-gated.

## Observability

Telemetry is opt-in. Set `OTEL_ENABLED=true`, `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`, and an OTLP endpoint such as the bundled OpenObserve service described in [docs/observability/README.md](docs/observability/README.md).
