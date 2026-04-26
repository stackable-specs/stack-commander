# ADR 0017: Adopt the Renovate Configuration Spec

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** security
- **Related spec:** [`specs/security/renovate.md`](../specs/security/renovate.md)

## Context

ADR 0016 committed the project to a dependency-management policy and named Renovate as the automation. What's missing is a _spec_ for Renovate itself: schedule and PR-concurrency caps, dependency-dashboard discipline, security-vs-routine PR separation, automerge guardrails, and a documented operating model.

Competing options:

- **Adopt `specs/security/renovate.md` and harden `renovate.json` to match (this ADR).**
- **Replace Renovate with Dependabot.** Loses lockfile-maintenance, multi-manager coverage, and the package-rules expressiveness.
- **Self-host Renovate in CI on a cron.** More operational surface; deferred until a concrete reason emerges.
- **Leave Renovate unconfigured.** Routine update noise, no security-PR escalation.

## Decision

Adopt `specs/security/renovate.md`. The materialization plan:

1. **`renovate.json`** at the repo root — explicit `timezone` + workday `schedule`, `prConcurrentLimit: 10` / `prHourlyLimit: 2`, `dependencyDashboard: true`, `lockFileMaintenance` weekly, `vulnerabilityAlerts` unbatched + always-on with `prCreation: immediate` + `security` label, scoped automerge for dev-only patch / pin / digest / lockfile-maintenance, grouping rules for the npm runtime and bun toolchain.
2. **CI validation** — a `renovate-config-validator --strict` step in CI on every PR that touches `renovate.json`.
3. **Operating model doc** — `docs/dependencies/renovate.md` covers cloud-vs-self-hosted, ownership, on-call path, registry allowlist.
4. **Verifier** under `verify/` checking the committed shape rule by rule.

## Consequences

**Positive**

- Routine update noise is bounded by `prHourlyLimit` and a workday schedule; security PRs land outside that gate with elevated priority.
- Misconfigurations land as failing CI runs, not as silent drift.
- Operating-model doc clarifies who is paged when Renovate fails.

**Negative**

- Config gains complexity. Preset version-pinning is a documented carve-out — Renovate-managed presets (`config:recommended`, `config:best-practices`) are stable upstream and are not pinned.
- CISA-KEV / EPSS escalation isn't wired at the Renovate layer yet (Renovate's `osvVulnerabilityAlerts` covers OSV CVEs but not the KEV/EPSS feeds); recorded as a follow-up.
- Implementation: `renovate.json`, the CI validator job, and `docs/dependencies/renovate.md` land as a follow-up.
