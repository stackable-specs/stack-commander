# ADR 0008: Adopt Unit Testing Discipline

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** quality
- **Related spec:** [`specs/quality/unit-testing.md`](../specs/quality/unit-testing.md)

## Context

Unit tests are the cheapest, fastest place to catch regressions and the only tier developers run on every save. When the suite is slow, flaky, order-dependent, or asserts on internal call counts, contributors stop running it and the safety net evaporates. ADR 0004 committed the project to red-green-refactor TDD; that's only meaningful if the inner loop has unit tests with the right shape.

Competing options:

- **Bun's built-in `bun test` runner with strict markers and AAA shape.**
- **Vitest.** Excellent ergonomics; another runtime to install + a slower cold start than `bun test` for a Bun-first stack.
- **Jest.** Mature; heavier config, slower under Bun, less direct integration with Bun's TS pipeline.

## Decision

Adopt the unit-testing discipline pinned by `specs/quality/unit-testing.md` using `bun test` as the runner: per-test in-memory substitutes, AAA shape, observable-behavior assertions, deterministic execution, CI gating with a coverage floor. Test files live alongside source as `*.test.ts` (matching ADR 0001 / 0004 convention); each module under `src/` carries a colocated `*.test.ts`.

## Consequences

**Positive**

- A passing unit suite is a real signal — not just an attestation that tests didn't crash.
- `bun test` runs in milliseconds against in-memory substitutes, so the inner-loop cost stays under a second.
- Coverage gating turns a percentage threshold into a CI failure rather than an advisory metric.

**Negative**

- Implementation-detail mocking is forbidden; refactoring habits must adapt.
- Must resist the drift toward "unit tests" that touch real I/O — those belong in integration (per ADR 0009).
- Implementation: `bun test --coverage` invocation in CI + a documented threshold (e.g. 80%) land as a follow-up.
