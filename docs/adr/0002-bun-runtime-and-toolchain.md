# ADR 0002: Use Bun as the single runtime and package manager

- **Status:** Accepted
- **Date:** 2026-04-24
- **Layer:** platform
- **Extends:** [ADR 0001](0001-typescript-strict-language.md)
- **Related spec:** [`specs/platform/bun.md`](../specs/platform/bun.md)

## Context

With TypeScript fixed as the language, the project needs a runtime and a package manager. The JS ecosystem splinters both: runtimes (Node, Deno, Bun), package managers (npm, pnpm, yarn, bun), test runners (jest, vitest, mocha), and replacements for large parts of the Node standard library. Mixing any two produces slow builds, ambiguous module resolution, duplicated lockfiles, and userland reimplementations of APIs the platform already ships.

Bun is uniquely positioned as an all-in-one: runtime, package manager, test runner, and a growing set of native APIs (`Bun.file`, `Bun.spawn`, `bun:sqlite`, `Bun.password`). The wins are only real if the project commits fully — a codebase that runs on Bun _and_ Node simultaneously pays Bun's compatibility costs without capturing its performance or ergonomics.

Competing options considered:

- **Node + pnpm + vitest.** Mature, broadly known, but requires assembling and maintaining three separate tools and accepting userland equivalents for APIs Bun ships natively.
- **Deno.** Excellent security model, but a narrower package ecosystem and a different module-resolution story than the rest of the stack assumes.
- **Bun with `npm`/`pnpm` fallback.** Splits lockfiles and resolution, which is the exact failure mode this ADR exists to prevent.

## Decision

Bun is the sole runtime, package manager, and test runner. Pin the Bun version in `package.json`'s `"packageManager"` field (or `.bun-version`). Invoke entry points with `bun run` / `bun <file>`, install with `bun install`, test with `bun test`, and commit only `bun.lock` (or `bun.lockb`). Prefer Bun-native APIs (`Bun.file`, `Bun.write`, `Bun.spawn`, `Bun.$`, `bun:sqlite`, `Bun.password`, `Bun.hash`) over Node-stdlib or userland equivalents; fall back to `node:*` modules only when Bun has no equivalent. Read env vars via `process.env` so code stays portable for tooling.

## Consequences

**Positive**

- One toolchain: no version skew between installer, runner, and test framework.
- Dependency graph stays lean — no `dotenv`, `bcrypt`, `better-sqlite3`, `vitest`, or similar, because the platform provides them.
- Cold-start and install times drop significantly versus Node + pnpm + vitest.
- Lockfile conflicts disappear; `bun.lock` is the single source of truth.

**Negative**

- Contributors must install Bun; the "just use Node" muscle memory doesn't work.
- Some third-party libraries still assume Node-only APIs or ship broken types for Bun; those cases need `node:*` fallbacks or patches.
- Bun's API surface is still evolving, so pinning the version exactly is non-negotiable — minor upgrades can ship behavior changes.
- Tooling that expects a `node_modules` layout or `npm` lifecycle scripts may need adapters.

**Neutral**

- Higher layers (interface, practices) assume `bun test` semantics and `bun run` script invocation; swapping the platform later would touch CI, docs, and test config.
