# ADR 0014: Adopt TypeDoc for API Reference Documentation

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** presentation
- **Related spec:** [`specs/presentation/typedoc.md`](../specs/presentation/typedoc.md)

## Context

The CLI's exported types and any library code it surfaces (e.g. for embedding the CLI in another tool) need reference documentation that consumers can read without spelunking the source. Without a chosen generator and a CI gate, "the docs" become whatever a contributor last hand-edited in a wiki — drifting past the released version and treating every top-level export as public surface so internal refactors silently become breaking changes.

Competing options:

- **TypeDoc (this ADR).** Type-hint-aware, single-binary CLI, treats `export` declarations as the public surface declaration.
- **Docusaurus + manual docs.** Excellent for narrative docs, overkill for API reference; manual sync diverges from source.
- **Hand-maintained README.** Drifts immediately on every refactor.

## Decision

Adopt TypeDoc as the API reference generator for typescript-bun, governed by `specs/presentation/typedoc.md`. The public surface is whatever the package's entry point re-exports (per `package.json` `exports`); internal modules are kept out by underscore-prefix convention or `@internal` JSDoc tags. A `bun run docs` script generates the reference; a `bun run docs:check` target gates the CI build and is part of the local PR-mirror gate.

## Consequences

**Positive**

- API reference is generated from the same source that ships, so it cannot drift past the released code.
- `@internal` + `package.json` `exports` turns "public API" from accident into declaration — refactors of internals stop being accidental breaking changes.
- A docs build failure is a CI signal, not a quiet warning.

**Negative**

- TypeDoc handles API reference well but is not a narrative-docs tool — long-form guides, tutorials, and architecture writeups still need a sibling format (e.g. plain markdown in `docs/`).
- Contributors must keep `@internal` accurate.
- Implementation: `typedoc.json`, `bun run docs` / `docs:check` scripts, and CI `docs` job land as a follow-up.
