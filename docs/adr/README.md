# Architectural Decision Records — typescript-bun stack

This directory holds the Architectural Decision Records for the typescript-bun stack. Format and lifecycle rules are defined in [`docs/specs/practices/madr.md`](../specs/practices/madr.md) (adopted via ADR 0005). ADRs 0001-0004 use the leaner Nygard-style shape that predates ADR 0005; new ADRs from 0005 onward conform to MADR.

## Index

| ADR                                                  | Title                                                       | Layer         | Status   |
| ---------------------------------------------------- | ----------------------------------------------------------- | ------------- | -------- |
| [0001](0001-typescript-strict-language.md)           | Use TypeScript with strict compiler configuration           | language      | Accepted |
| [0002](0002-bun-runtime-and-toolchain.md)            | Adopt Bun as runtime and toolchain                          | platform      | Accepted |
| [0003](0003-commander-js-cli-interface.md)           | Adopt Commander.js for the CLI interface                    | interface     | Accepted |
| [0004](0004-red-green-refactor-tdd.md)               | Adopt the Red-Green-Refactor TDD Cycle                      | practices     | Accepted |
| [0005](0005-madr-architectural-decisions.md)         | Adopt MADR for Architectural Decision Records               | practices     | Accepted |
| [0006](0006-bdr-behavior-records.md)                 | Adopt BDR for Behavior Decision Records                     | practices     | Accepted |
| [0007](0007-conventional-commits.md)                 | Adopt Conventional Commits                                  | practices     | Accepted |
| [0008](0008-unit-testing-discipline.md)              | Adopt Unit Testing Discipline                               | quality       | Accepted |
| [0009](0009-integration-testing-discipline.md)       | Adopt Integration Testing Discipline                        | quality       | Accepted |
| [0010](0010-property-based-testing.md)               | Adopt Property-Based Testing for Invariants                 | quality       | Accepted |
| [0011](0011-trunk-code-quality.md)                   | Adopt Trunk Code Quality as the Lint Runner                 | quality       | Accepted |
| [0012](0012-prek-hook-runner.md)                     | Adopt prek as the Single Git-Hook Runner                    | quality       | Accepted |
| [0013](0013-smoke-testing-pipeline-gate.md)          | Adopt Smoke Testing as a Pipeline Gate                      | practices     | Accepted |
| [0014](0014-typedoc-api-reference.md)                | Adopt TypeDoc for API Reference Documentation               | presentation  | Accepted |
| [0015](0015-sbom-for-released-artifacts.md)          | Produce an SBOM for Every Released Artifact                 | security      | Accepted |
| [0016](0016-dependency-management-policy.md)         | Adopt Dependency Management Policy                          | security      | Accepted |
| [0017](0017-renovate-config.md)                      | Adopt the Renovate Configuration Spec                       | security      | Accepted |
| [0018](0018-docker-image-format.md)                  | Adopt Docker as the Image Format                            | delivery      | Accepted |
| [0019](0019-docker-compose-local-and-single-host.md) | Adopt Docker Compose for Local Dev and Single-Host Topology | delivery      | Accepted |
| [0020](0020-opentelemetry-instrumentation.md)        | Adopt OpenTelemetry for Application Instrumentation         | observability | Accepted |
| [0021](0021-openobserve-otlp-backend.md)             | Adopt OpenObserve as the OTLP Backend                       | observability | Accepted |

## Implementation status

ADRs 0001-0021 now have materialized stack artifacts: BDR docs under `docs/bdr/`, commit/hook policy in `.commitlintrc.yaml` and `prek.toml`, lint/docs/test/release automation in `.github/workflows/`, delivery assets in `Dockerfile` and `compose*.yaml`, and observability wiring in `src/observability.ts` plus `docs/observability/README.md`. Verification coverage is still partial: the shell verifiers in `docs/verify/` currently cover ADRs 0001-0004 and should be extended for the newer ADRs as follow-up Stage 4 work.
