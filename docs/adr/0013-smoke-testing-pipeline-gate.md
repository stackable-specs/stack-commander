# ADR 0013: Adopt Smoke Testing as a Pipeline Gate

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** practices
- **Related spec:** [`specs/practices/smoke-testing.md`](../specs/practices/smoke-testing.md)

## Context

Unit (ADR 0008), integration (ADR 0009), and property (ADR 0010) tests verify code in isolation and against wired dependencies. None of them prove that the **shipped CLI** actually starts and runs against the user's interpretation of its CLI surface — bad packaging, missing entry-point in `package.json`/`bun build`, broken shebang, missing runtime dep — all land on the first user instead of the build.

Competing options:

- **Smoke suite executing the built CLI binary (this ADR).** A handful of high-signal invocations: `cli --version`, `cli --help`, `cli <subcommand> --help`, and one happy-path scenario per critical command.
- **Skip smoke testing.** Misses packaging defects entirely.
- **Reuse integration tests as smoke tests.** Violates the spec's narrow + fast + separate-suite rule.

## Decision

Adopt smoke testing as a pipeline gate, governed by `specs/practices/smoke-testing.md`. A separate `tests/smoke/` target tagged with the `smoke` marker runs the built CLI binary (output of `bun build --compile` or `bun run build`) against the business-critical paths agreed with the maintainers. The suite is held to a ≤ 5-minute hard cap; flaky tests are quarantined the same business day. CI runs smoke after the binary is built and before any release-publish stage.

## Consequences

**Positive**

- Packaging and start-up defects are caught in the same PR that introduces them, not by a user.
- The suite is deliberately small — adding a smoke test requires justifying the wall-clock cost, which keeps it from drifting into a regression suite.
- Surface-level changes (CLI flag rename, exit-code change) get caught.

**Negative**

- Requires a CI runner that can execute the built binary (already a dependency of `bun build`).
- Implementation: `tests/smoke/`, `make smoke` / `bun run smoke`, CI smoke job depending on the build step land as a follow-up.
