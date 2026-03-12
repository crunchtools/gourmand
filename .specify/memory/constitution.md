# gourmand Constitution

> **Version:** 1.1.0
> **Ratified:** 2026-03-11
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.1.0
> **Profile:** Container Image

## Purpose

Pre-built container image for [gourmand](https://codeberg.org/mattdm/gourmand), an AI-slop detector for codebases. Eliminates the need to compile gourmand from Rust source in every CI pipeline run.

## License

AGPL-3.0-or-later

## Versioning

Follow Semantic Versioning 2.0.0. MAJOR/MINOR/PATCH.

## Base Image

Hummingbird (`quay.io/hummingbird/base:latest`) — lightweight container base for static binaries.

## Registry

| Registry | Image |
|----------|-------|
| Quay.io | `quay.io/crunchtools/gourmand` |
| GHCR | `ghcr.io/crunchtools/gourmand` |

## Containerfile Conventions

- Uses `Containerfile` (not Dockerfile)
- Multi-stage build:
  1. **Builder stage:** `rust:slim` — compiles gourmand from source via `cargo install`
  2. **Runtime stage:** Hummingbird — copies only the static binary
- LABEL with version and description metadata
- ENTRYPOINT set to `gourmand` binary

## Testing

- **Build test**: CI builds the container image on every push to main
- **Weekly rebuild**: Picks up base image and dependency updates every Monday 6 AM UTC

## Quality Gates

1. Build — CI builds the Containerfile successfully
2. Weekly rebuild — cron job picks up base image updates

## Usage

```bash
# Run gourmand against current directory
podman run --rm -v .:/workspace:Z quay.io/crunchtools/gourmand --full /workspace

# In GitLab CI
gourmand:
  stage: test
  image: quay.io/crunchtools/gourmand
  script:
    - gourmand --full .
```
