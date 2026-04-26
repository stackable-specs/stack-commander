# ADR 0012: Adopt prek as the Single Git-Hook Runner

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** quality
- **Related spec:** [`specs/quality/prek.md`](../specs/quality/prek.md)

## Context

Conventional Commits enforcement (ADR 0007), Trunk lint (ADR 0011), language-native eslint/tsc, secret scanning, and the `bun test`/`bun build` gates all want to run as git hooks. Without a single orchestrator the project either splits hook ownership across `husky`, Trunk's own actions, and ad-hoc shell scripts, or skips hooks entirely. The `specs/quality/prek.md` spec also explicitly forbids stacking competing runners (rule 16).

Competing options:

- **prek (this ADR).** Rust binary, drop-in `pre-commit` config compatible, fast cold-start.
- **upstream `pre-commit`.** Same config format, slower install, no compelling reason to prefer it.
- **husky + lint-staged.** Node-centric, fragments configuration across `.husky/`, `package.json`, and the lint runner.
- **lefthook.** Single binary, no compatibility with the existing `.pre-commit-hooks.yaml` repo network.

## Decision

Adopt prek as the single git-hook runner, governed by `specs/quality/prek.md`. prek owns `pre-commit`, `pre-push`, and `commit-msg` stages. Trunk Code Quality (ADR 0011) is invoked as a `local` hook from prek (`trunk check` / `trunk fmt`). Conventional Commits enforcement (ADR 0007) becomes a `commit-msg` prek hook running `commitlint`. Bun-native lint/test/build hooks run via `repo: local` entries (`bun run lint`, `bun test`, `bun run build`).

## Consequences

**Positive**

- One place to read the entire local gate (`prek.toml`); one command (`prek run --all-files`) reproduces it.
- Single hook runner satisfies `prek` rule 16.
- Conventional Commits enforcement runs locally on every commit, not only in CI on PRs.

**Negative**

- Contributors must run `prek install` once after cloning; documented in onboarding.
- prek is younger than upstream pre-commit; if a hook publisher ships an incompatible config, the temporary fall-back is `pre-commit run` against the same config file.
- Implementation: `prek.toml`, `bun run prek:install` script, CI prek job, and weekly `prek auto-update` workflow land as a follow-up.
