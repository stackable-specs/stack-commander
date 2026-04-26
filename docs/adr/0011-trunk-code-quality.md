# ADR 0011: Adopt Trunk Code Quality as the Lint Runner

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** quality
- **Related spec:** [`specs/quality/trunk-code-quality.md`](../specs/quality/trunk-code-quality.md)

## Context

A repo accumulates a different config format, installed version, and invocation style for every linter, formatter, and scanner. "Lint the repo" then resolves differently on each developer's machine, in each CI job, and between contributors — turning lint passes into noise. The stack already runs `eslint` and `prettier` directly; adding shellcheck, yamllint, hadolint, gitleaks, and more on top of that without a unifier is a config-explosion problem.

Competing options:

- **Trunk Code Quality (this ADR).** One CLI, pinned tool versions, multi-language coverage, single CI gate.
- **Per-tool configs invoked individually.** Fragments versions and configs.
- **MegaLinter.** Heavier container-based runs.
- **pre-commit / prek as runner only.** Strong for hooks, weaker for unifying multi-language tool versions.

## Decision

Adopt Trunk Code Quality as the unified lint/format runner, governed by `specs/quality/trunk-code-quality.md`. `.trunk/trunk.yaml` pins the CLI version and every linter version; `trunk check` is the gate; bypasses (`--no-verify`, ad-hoc suppressions) are treated as defects. ESLint and Prettier (already in the stack) are invoked through Trunk; their per-tool configs remain authoritative for their domain.

## Consequences

**Positive**

- Every contributor and CI runner resolves the same tool versions.
- Adding a new language or tool is a `trunk.yaml` edit, not a CI rewrite.
- Trunk runs ESLint with type info, gitleaks for secrets, and shellcheck for any shell scripts in one pass.

**Negative**

- Introduces a vendor dependency on Trunk's distribution and CLI.
- Contributors used to invoking tools directly must adopt `trunk` as the entry point.
- Implementation: `.trunk/trunk.yaml` + `make lint` / Bun script wiring + CI job land as a follow-up.
