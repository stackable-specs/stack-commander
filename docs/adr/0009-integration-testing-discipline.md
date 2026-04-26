# ADR 0009: Adopt Integration Testing Discipline

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** quality
- **Related spec:** [`specs/quality/integration-testing.md`](../specs/quality/integration-testing.md)

## Context

Unit tests (ADR 0008) verify a function in isolation. They do not catch schema drift, broken migrations, contract mismatches between the CLI and external services it talks to, or driver issues. Without a real-dependency tier, those bugs ship. With a tier that "integration tests" by stitching mocks together, they still ship.

Competing options:

- **Real dependencies via `testcontainers` (this ADR).** Postgres, NATS, brokers booted as throwaway containers per test run.
- **All-mocks "integration."** Fast but blind to the failure modes that motivate the tier.
- **Shared, long-lived staging environment.** Prone to cross-test pollution and ordering bugs.
- **Skip integration tests on PRs, run nightly.** Defects land before they're caught.

## Decision

Adopt the integration-testing discipline pinned by `specs/quality/integration-testing.md` using `testcontainers` (per the parent spec's recommendation; the testcontainers refinement in `specs/quality/testcontainers.md` may be adopted later). Integration tests live under `tests/integration/` (or `*.integration.test.ts`) and run on every PR with full container boot; state isolation is per-test via fresh containers or transactional rollback.

## Consequences

**Positive**

- The suite catches schema drift, migration bugs, and contract mismatches before merge.
- BDR Given / When / Then scenarios drop in directly as integration tests.
- Real serialization paths and real driver behavior get exercised.

**Negative**

- CI requires Docker-capable runners and longer wall-clock budgets.
- Writing integration tests is more work than unit tests; the team must internalize when each applies.
- Implementation: `tests/integration/`, the `bun test --preload` setup that boots testcontainers, and CI integration job land as a follow-up.
