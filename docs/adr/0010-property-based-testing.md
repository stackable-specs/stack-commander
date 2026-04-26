# ADR 0010: Adopt Property-Based Testing for Invariants

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** quality
- **Related spec:** [`specs/quality/property-based-testing.md`](../specs/quality/property-based-testing.md)

## Context

Example-based tests verify the `(input, output)` pairs the developer thought of; everything else stays untested. For functions with non-trivial input domains — parsers, serializers, command-line arg handlers, state machines — the inputs that break in production are usually the ones nobody wrote a test for. The CLI's argument parsing and any string-shaping helpers are exactly the shape PBT was built for.

Competing options:

- **`fast-check` (TS) (this ADR).** Counterexample search + shrinking; the canonical TS PBT framework.
- **Custom `for (const _ of Array(100))` loops with random inputs.** No shrinking, no reproducibility.
- **Skip PBT.** Example tests only; edge cases stay untested.

## Decision

Adopt `fast-check` for property-based testing on functions with non-trivial input domains, governed by `specs/quality/property-based-testing.md`. Properties are framed as invariants over a domain; counterexamples are pinned as regression tests; shrinking is allowed to do its work. Property tests share the unit-test runner (`bun test`) and either co-locate as `*.property.test.ts` or live under `tests/property/`.

## Consequences

**Positive**

- Edge cases example tests skip get exercised — boundary conditions, fuzz-like inputs, round-trip identities.
- A PBT failure produces a small, reproducible counterexample.

**Negative**

- Writing genuine properties (predicates over a domain) is harder than writing example tests; misuse degrades the technique to a noisy random loop.
- PBT runs are non-deterministic by default; CI must seed and budget runs explicitly.
- Implementation: add `fast-check` to dev dependencies and stand up a first property test as a follow-up.
