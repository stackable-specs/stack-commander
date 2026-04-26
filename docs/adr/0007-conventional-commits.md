# ADR 0007: Adopt Conventional Commits

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** practices
- **Related spec:** [`specs/practices/conventional-commits.md`](../specs/practices/conventional-commits.md)

## Context

Release-notes generators, SemVer-bumping bots, changelog renderers, scope-filtered CI, and `git bisect` all make better decisions when commits carry structured metadata. Free-form commits like `Fixed bug` or `wip` leave those tools unable to distinguish a feature from a chore, a breaking change from a refactor, or a user-visible change from internal work.

Competing options:

- **Conventional Commits 1.0 (this ADR).**
- **Angular convention.** Predecessor; stricter scope rules and narrower vocabulary.
- **Gitmoji.** Emoji prefix; less tooling support.
- **Free-form.** Forces humans to re-read every diff at release time.

## Decision

Adopt Conventional Commits, governed by `specs/practices/conventional-commits.md`. Every commit on the default branch must parse; `feat:` means user-visible behavior; breaking changes carry `!` and a `BREAKING CHANGE:` footer. Enforce with `commitlint`/`@commitlint/config-conventional` as a `commit-msg` prek hook (per ADR 0012) and as a CI gate on every PR.

## Consequences

**Positive**

- Release-please (or equivalent) can compute SemVer bumps and changelogs without a human re-reading the diff.
- `git log --grep=^feat` filters the user-visible slice of history.
- Scope tags route notifications to the right reviewers.

**Negative**

- Contributors must learn the type vocabulary and breaking-change conventions.
- The `commit-msg` gate adds a small failure mode at PR time.
- Implementation: `.commitlintrc.json`/`.commitlintrc.yaml` and CI commitlint job land as a follow-up.
