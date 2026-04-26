# ADR 0018: Adopt Docker as the Image Format

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** delivery
- **Related spec:** [`specs/delivery/docker.md`](../specs/delivery/docker.md)

## Context

The CLI ships in two flavors: a `bun build --compile` standalone binary for direct distribution, and a Docker image for users who run the CLI in a containerized pipeline (CI/CD, Kubernetes Jobs, OCI-native tooling). Without a pinned image format and authoring policy, contributors produce ad-hoc Dockerfiles whose builds drift, ship workloads as root, leak credentials in `ENV`, and bundle build-time tooling into the runtime layer.

Competing options:

- **Docker (OCI) authored per `specs/delivery/docker.md` (this ADR).**
- **Buildpacks (Paketo, Heroku).** Opinionated builders; less control over the final layer set.
- **Skip the container path entirely.** Some users genuinely need an OCI artifact; this is closing a real distribution channel.

## Decision

Adopt Docker (OCI) images as the container distribution format, governed by `specs/delivery/docker.md`. Dockerfiles pin base images by digest (`bun` runtime image), use multi-stage builds to keep build tooling out of the runtime layer, run the CLI as a non-root user, inject secrets via build secrets / runtime mounts (never `ENV`/`ARG`), and gate publication on vulnerability scan + SBOM (ADR 0015).

## Consequences

**Positive**

- A single artifact format runs in CI, on developer machines via `docker run`, and on any container platform without rebuild.
- Digest-pinned bases plus the locked `bun.lock` (per ADR 0016) yield byte-reproducible images for a given commit.
- SBOM and vulnerability gates wire into CI naturally.

**Negative**

- Contributors must learn multi-stage Dockerfile authoring and the rules around secrets and non-root users.
- Registry storage and image-lifecycle hygiene become operational responsibilities the project inherits.
- Implementation: `Dockerfile`, `.dockerignore`, CI `build-image` job with Trivy + SBOM steps land as a follow-up.
