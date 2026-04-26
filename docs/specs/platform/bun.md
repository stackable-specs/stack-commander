---
id: bun
layer: platform
extends:
  - typescript
---

# Bun

## Purpose

Bun is an all-in-one runtime: it replaces Node.js, npm/pnpm/yarn, and the jest/vitest test runner with a single toolchain, and ships native replacements for large parts of the Node standard library. Projects that target Bun only capture its performance and ergonomics wins when they commit fully — mixing Node runtimes, competing package managers, or userland reimplementations of APIs the platform already provides produces slower programs, ambiguous resolution, and dependency bloat. This spec pins Bun as the single runtime and package manager, and names the built-in APIs that replace third-party equivalents, so "runs on Bun" is a real constraint rather than a coincidence.

## References

- **external** `https://bun.sh/docs` — Bun documentation
- **external** `https://bun.sh/docs/install/lockfile` — Bun lockfile format
- **external** `https://bun.sh/docs/cli/test` — `bun test` runner
- **external** `https://bun.sh/docs/api/file-io` — Bun file I/O APIs
- **external** `https://bun.sh/docs/api/spawn` — `Bun.spawn` subprocess API
- **external** `https://github.com/oven-sh/bun` — Bun source repository

## Rules

1. Pin the Bun version in `package.json` under `"packageManager"` (e.g. `"bun@1.2.0"`) or commit a `.bun-version` file; CI and deployment images must install the pinned version.
2. Invoke application and script entry points with `bun run <script>` or `bun <file>`; do not run them through `node`, `ts-node`, `tsx`, `deno`, or `nodemon`.
3. Manage dependencies with `bun install`; do not run `npm install`, `pnpm install`, or `yarn install` against the project.
4. Commit `bun.lock` (or `bun.lockb` on older projects) and do not commit `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock` alongside it.
5. Declare executable scripts under `"scripts"` in `package.json` and invoke them via `bun run <name>`; do not document `npm run` / `pnpm run` / `yarn` invocations in the same project's README.
6. Run unit tests with `bun test` and configure test discovery in `bunfig.toml`; do not add `jest`, `vitest`, `mocha`, or `ava` as dependencies.
7. Read and write files with `Bun.file()` and `Bun.write()` for new code paths; reserve `node:fs` for APIs Bun has not yet implemented or for libraries that accept only `fs`-style streams.
8. Spawn subprocesses with `Bun.spawn` or `Bun.$` (the shell API); do not import `node:child_process` for new code.
9. Access SQLite through `bun:sqlite`; do not add `better-sqlite3`, `sqlite3`, or `sql.js` as dependencies.
10. Hash and verify passwords with `Bun.password`; do not add `bcrypt`, `argon2`, or equivalent userspace dependencies.
11. Hash bytes with `Bun.hash` for non-cryptographic digests and `crypto.subtle` for cryptographic digests; do not pull in third-party hashing libraries for operations Bun already provides.
12. Load environment variables through Bun's automatic `.env` resolution; do not add `dotenv` or equivalent loader dependencies.
13. Read environment variables at runtime through `process.env` so code stays portable to other runtimes for testing and tooling.
14. Do not ship Node-only polyfills (userland `buffer`, `util`, or `events` shims) in code paths that only run on Bun.
