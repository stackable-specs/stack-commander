# ADR 0015: Produce an SBOM for Every Released Artifact

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** security
- **Related spec:** [`specs/security/sbom.md`](../specs/security/sbom.md)

## Context

When a CVE is disclosed in a transitive dependency the team ships, the question "which of our artifacts are exposed?" needs an answer in seconds, not in a frantic cross-repo hunt. Without a Software Bill of Materials, the answer is approximate at best; with one, it is a query.

Competing options:

- **CycloneDX or SPDX in JSON, generated during build (this ADR).** Standard format every scanner consumes; signed inside an in-toto / SLSA attestation; distributed alongside the artifact.
- **Internal CSV or wiki list.** Not machine-readable, drifts immediately.
- **Skip SBOMs.** Depend on after-the-fact `bun pm ls` style introspection during incident response.

## Decision

Produce an SBOM (CycloneDX) for every released artifact, generated during the build, distributed alongside the artifact (release asset for binary releases, OCI referrer for container images per ADR 0018). The SBOM is built by `@cyclonedx/bun` (or an equivalent Bun-aware generator) running over the locked `bun.lock` so the inventory matches what shipped. Vulnerability-driven Renovate updates (per ADR 0017) consume the SBOM to surface affected artifacts.

## Consequences

**Positive**

- Vulnerability triage on a disclosed CVE collapses to a query against the SBOM corpus.
- License compliance and supply-chain attestation become tractable.
- Pairs cleanly with the chosen registry / artifact distribution path.

**Negative**

- Build pipelines must integrate an SBOM generator and (eventually) a signer.
- SBOMs must be retained for as long as the artifact is supported, growing the artifact-storage footprint.
- Implementation: SBOM generation script + CI `sbom` step + release-asset upload land as a follow-up.
