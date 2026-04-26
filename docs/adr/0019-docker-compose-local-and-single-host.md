# ADR 0019: Adopt Docker Compose for Local Dev and Single-Host Topology

- **Status:** Accepted
- **Date:** 2026-04-26
- **Layer:** delivery
- **Related spec:** [`specs/delivery/docker-compose.md`](../specs/delivery/docker-compose.md)

## Context

The CLI itself runs as a single binary, but its integration tests (per ADR 0009) and any local-dev scenarios that talk to a downstream service (database, broker, OpenObserve per ADR 0021) need a way to stand up sibling containers with the same images, network, and dependency wiring everywhere. Without a pinned format, each developer scripts container startup their own way, CI integration tests stand up dependencies through ad-hoc shell, and "works on my machine" becomes the dominant failure mode.

Competing options:

- **Docker Compose authored per `specs/delivery/docker-compose.md` (this ADR).**
- **Kubernetes (kind, minikube, k3s) for local dev.** Heavier, slower iteration loop.
- **Per-developer shell scripts orchestrating `docker run`.** No shared topology contract.
- **`testcontainers` only, no Compose file.** Works for tests but leaves local dev unsupported.

## Decision

Adopt Docker Compose as the multi-container orchestration format for local development, CI integration tests, and single-host deployments where applicable, governed by `specs/delivery/docker-compose.md`. Compose files use the modern `compose.yaml` schema (no `version:` key), pin every `image:` to a digest or specific tag, declare `depends_on` with `condition: service_healthy` (or `service_started` when the upstream image is distroless), source secrets from a secret store rather than inline `environment:` blocks, and layer environments via override files rather than parallel forks.

## Consequences

**Positive**

- Developers get a one-command local topology that matches CI integration tests and single-host deployments.
- Integration tests (ADR 0009) can target the same Compose file the developer used locally, reducing parity bugs.
- A Compose file is reviewable as configuration, not buried in shell scripts.

**Negative**

- Compose is not a substitute for an orchestrator — production at scale still needs Kubernetes or a managed platform; the spec is explicit that Compose is for local + small single-host.
- Contributors must internalize the "don't bind-mount source in production / don't bake secrets in YAML" rules.
- Implementation: `compose.yaml`, `compose.override.yaml`, `.env.example`, and `secrets/*` discipline land as a follow-up.
