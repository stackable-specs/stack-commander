# ADR 0001: Use TypeScript with strict compiler configuration

- **Status:** Accepted
- **Date:** 2026-04-24
- **Layer:** language
- **Related spec:** [`specs/language/typescript.md`](../specs/language/typescript.md)

## Context

The project needs a single language-level contract that keeps the compiler load-bearing. TypeScript only pays for itself when its type system is treated as a gate: once `any`, non-null assertions, loose assertions, or disabled strict flags enter the codebase, `tsc` silently degrades into an advisory check and the project becomes "JavaScript with extra ceremony." Pinning the compiler version, module system, and a core set of idiomatic patterns keeps refactors safe and makes CI failures meaningful.

Competing options considered:

- **Plain JavaScript + JSDoc types.** Lower ceremony, but no enforced gate — types drift from runtime behavior.
- **TypeScript with `strict: false` / selective flags.** Lets teams opt out per-file, which in practice metastasizes until the type system is decorative.
- **Flow / other gradual typing.** Smaller ecosystem, weaker tooling, no meaningful advantage for this stack.

## Decision

Adopt TypeScript as the language layer with `"strict": true` plus `noUncheckedIndexedAccess`, `noImplicitOverride`, and `noFallthroughCasesInSwitch` enabled in every `tsconfig.json`. Pin the compiler version exactly (no `^`/`~`), run `tsc --noEmit` as a CI gate, and forbid escape hatches (`any`, `!`, ad-hoc `as` casts) except at validated system boundaries. ES modules, Prettier, and `@typescript-eslint` recommended-type-checked are mandatory.

## Consequences

**Positive**

- `tsc` becomes a trustworthy gate — green means the type contract holds.
- Refactors across package boundaries are safe because exported signatures carry explicit return types and no `any` leaks out.
- Style and idiom (naming, `const`-default, no `enum`, discriminated-union exhaustiveness) are single-sourced, so reviews focus on behavior rather than bikeshedding.

**Negative**

- Onboarding cost for contributors unfamiliar with strict TypeScript; every `unknown` must be narrowed rather than cast.
- Compiler upgrades are deliberate work (dedicated PR) instead of drift via `^`, so security/performance improvements arrive slightly later.
- Some third-party libraries with weak types require schema validators (e.g. Zod) at the boundary rather than a quick `as Foo`.

**Neutral**

- All higher layers (platform, interface, practices) inherit TypeScript's vocabulary and tooling assumptions.
