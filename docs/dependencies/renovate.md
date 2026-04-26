# Renovate operating model (ADR-0017)

This document describes how Renovate runs against this repository and who owns it.

## Deployment

| Question               | Answer                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------- |
| Cloud or self-hosted?  | Mend Cloud GitHub App                                                                                     |
| Configuration file     | `renovate.json` at the repo root                                                                          |
| Schema validation      | `renovate-config-validator --strict renovate.json` in CI                                                  |
| Dashboard              | A single GitHub issue titled `Renovate dependency dashboard`                                              |
| Allowlisted registries | `https://registry.npmjs.org/` plus the container registries referenced by `Dockerfile` and `compose.yaml` |

## Schedule and PR caps

| Knob                  | Value                                    |
| --------------------- | ---------------------------------------- |
| `timezone`            | `America/New_York`                       |
| Routine `schedule`    | `after 8am and before 6pm every weekday` |
| `prConcurrentLimit`   | `10`                                     |
| `prHourlyLimit`       | `2`                                      |
| `lockFileMaintenance` | enabled, `before 5am on monday`          |

## Security PRs

Security PRs are always-on, unbatched, labeled `security` and `dependencies`, and created immediately. They are never auto-merged.

## Ownership

Changes to `renovate.json` require CODEOWNERS review. Failed Renovate runs are triaged through the dependency dashboard issue and assigned to the dependency-policy owner in `.github/CODEOWNERS`.
