# ADR 0004: Adopt Red-Green-Refactor TDD as the development practice

- **Status:** Accepted
- **Date:** 2026-04-24
- **Layer:** practices
- **Related spec:** [`specs/practices/tdd.md`](../specs/practices/tdd.md)

## Context

The value of test-driven development depends entirely on the order of operations: a failing test first, minimum production code to make it pass, refactor under green. Skipping the red step, batching many failing tests ahead of implementation, or refactoring while red silently converts "TDD" into "tests written later." The diff looks similar, but the regression safety, design pressure, and executable-specification properties that justify TDD are lost — tests end up codifying whatever the implementation happens to do rather than constraining it.

Competing practices considered:

- **Test-after / post-hoc tests.** Common and easy, but tests tend to mirror implementation details and miss the design-pressure benefit; coverage becomes a lagging metric rather than a gate.
- **Property-based / example-driven without cycle discipline.** Useful techniques, but without the red-green-refactor ordering they're orthogonal to the problem this ADR addresses.
- **No prescribed workflow.** Each contributor chooses; reviews cannot verify discipline from the commit history, and practice drifts.

## Decision

Every change to observable behavior follows the red-green-refactor cycle:

1. Write one failing test. Run it and confirm it fails for the right reason (assertion or missing implementation — not a syntax, import, or setup error).
2. Write the minimum production code to pass it. Do not add code no failing test requires.
3. Run the full suite. Refactor only while green. Do not change observable behavior during a refactor.

Keep each cycle under ~10 minutes; exceed the budget and revert to the last green commit, then split the problem. Commit only at green. Never skip, disable, or comment out failing tests to reach green; quarantined tests require a tracking issue or removal date in a comment at the skip site. Every bug fix starts with a failing test that reproduces the bug. Name tests for behavior and expected outcome, not the function under test.

## Consequences

**Positive**

- Commit history reflects the cycle: green-only commits, small steps, bug fixes preceded by a reproducing test. A reviewer can verify the workflow was actually followed.
- Production code is constrained by tests rather than the reverse, so tests catch regressions during future refactors.
- The ~10-minute cycle budget acts as an early warning — when a cycle stalls, the problem is too big, not the developer.
- Bugs become harder to reintroduce because every fix ships with a test that fails without it.

**Negative**

- Higher up-front cost per change; contributors used to test-after workflows will feel slower initially.
- Requires a fast feedback loop — `bun test` startup and test runtime must stay low enough that running the full suite between steps is cheap. If the suite slows down, discipline erodes.
- Exploratory spikes and prototypes need an explicit carve-out or a separate, clearly marked workflow; strict TDD is not a good fit for learning-oriented experiments.

**Neutral**

- Depends on the platform layer's `bun test` (ADR 0002) being fast and reliable.
- The quality layer inherits the "commit only at green" and "no skipped tests without tracking" constraints as CI gates.
