# ADR 0005: Adopt MADR for Architectural Decision Records

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** practices
- **Related spec:** [`specs/practices/madr.md`](../specs/practices/madr.md)

## Context

ADRs 0001-0004 already exist with a Nygard-leaning shape (Status / Context / Decision / Consequences). MADR refines that with a fixed section layout, numbered files, PR-reviewed lifecycle, and an index. Without a pinned format the log drifts into ad-hoc notes; cross-spec citations like `(refs: ADR-NNN)` stop resolving cleanly.

Competing options:

- **Stay with the current Nygard-leaning format.** Works, but doesn't carry the Considered Options / Decision Outcome split MADR uses.
- **Switch to ARDoc / Y-statements / Lightweight ADRs.** Less structure, bigger drift surface.
- **Adopt MADR (this ADR).** Structured, tooling-supported, matches the spec library.

## Decision

Adopt the MADR conventions documented in `specs/practices/madr.md`: ADRs live under `docs/adr/`, are numbered `NNNN-short-title.md`, follow the Status / Context / Decision / Consequences sections (with Considered Options / Decision Outcome added as MADR-rich variants when there are 3+ alternatives), and are introduced via PR. ADRs 0001-0004 retain their current shape; new ADRs from this one onward conform.

## Consequences

**Positive**

- The ADR log is reviewable through the same PR mechanism as the code.
- `(refs: ADR-NNNN)` citations in specs resolve to documents that exist and conform.
- New contributors can scan Status / Context / Decision / Consequences in seconds.

**Negative**

- A small format drift between the older 4 ADRs and the newer ones; documented as a follow-up to retrofit when convenient.
- An ADR index file (`docs/adr/README.md`) needs maintenance per MADR rule 18.
