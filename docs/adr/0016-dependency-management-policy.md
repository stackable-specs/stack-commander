# ADR 0016: Adopt Dependency Management Policy

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** security
- **Related spec:** [`specs/security/dependency-management.md`](../specs/security/dependency-management.md)

## Context

Every third-party dependency is code the team ships but did not write, run with the same privileges as first-party code. Without policy, "it built green" hides the failure modes that matter: a floating range pulls in a malicious patch overnight, missing lockfile means CI/prod drift, an unpinned base image rebases onto a vulnerable layer, a typosquat lands unreviewed, and an abandoned transitive sits four levels deep with no maintainer to take a CVE report.

Competing options:

- **Adopt the policy in `specs/security/dependency-management.md` (this ADR).** Committed `package.json` + `bun.lock`, exact pinning where possible, registry allowlist, CODEOWNERS on dep changes, Renovate (ADR 0017), license allowlist, abandoned-dep retirement.
- **Looser: lockfile only, no review or update automation.**
- **Looser still: range-based versions, install-from-public-registry at build time.**

## Decision

Adopt the dependency-management policy in `specs/security/dependency-management.md`. Bun's lockfile (`bun.lock`) is committed and authoritative; `bun install --frozen-lockfile` is the build-time invocation; direct deps in `package.json` use exact versions (or narrow `~` for tooling that requires it); the npm registry allowlist is documented; CODEOWNERS gates changes to `package.json` / `bun.lock`. Renovate (per ADR 0017) drives the update flow.

## Consequences

**Positive**

- The dependency graph the team ships is intentional, reproducible, reviewable, and auditable.
- Dependency confusion and unpinned base-image drift are closed by the registry allowlist and digest pinning (per ADR 0018).
- Supply-chain controls compose cleanly with SBOM (ADR 0015) and vulnerability scanning.

**Negative**

- Dependency updates become a steady stream of PRs that must pass full CI; ignoring them undoes the policy.
- CODEOWNERS and license allowlist add friction to adding a new direct dependency — by design.
- Implementation: `.github/CODEOWNERS`, license-check tooling, `bun install --frozen-lockfile` invocation discipline land as a follow-up.
