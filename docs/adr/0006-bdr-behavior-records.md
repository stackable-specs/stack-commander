# ADR 0006: Adopt BDR for Behavior Decision Records

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** practices
- **Related spec:** [`specs/practices/bdr.md`](../specs/practices/bdr.md)

## Context

ADRs (per ADR 0005) capture _how_ the system is built. They don't record _what the CLI must do for users_ — the externally observable contracts the tool agrees to uphold. Without a separate record of behavioral promises, intent is reverse-engineered from code and tests, scope creep is silent, and integration tests have no canonical input.

Competing options:

- **Capture behavior in test code only.** Tests describe what's verified, not what's promised; tests change as a side effect of refactors and behavior drift goes unnoticed.
- **Free-form Gherkin `.feature` files.** Useful but unbounded; no review mechanism distinct from code.
- **BDR (this ADR).** Each capability gets one record with acceptance criteria a black-box observer can confirm and Given / When / Then scenarios that drop into integration tests.

## Decision

Adopt BDRs alongside ADRs, governed by `specs/practices/bdr.md`. BDRs live under `docs/bdr/`, are numbered `NNN-<kebab-title>.md`, and follow the spec's required sections (Behavior / Context / Acceptance Criteria / Verification scenarios). New behavioral promises land as BDRs before the implementing PR opens; integration tests reference them by id.

## Consequences

**Positive**

- Behavioral contracts become first-class artifacts, reviewable independent of implementation.
- BDR Given / When / Then scenarios feed integration tests directly (per ADR 0009).
- The split between ADRs (architecture) and BDRs (behavior) keeps each document tight.

**Negative**

- Two indices to maintain (`docs/adr/`, `docs/bdr/`).
- Contributors must learn the ADR / BDR distinction; the spec's Purpose paragraph is the onboarding text.
- Implementation: `docs/bdr/` is empty today; first BDR lands when the first user-facing capability is committed.
