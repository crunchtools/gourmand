# gourmand Constitution

> **Version:** 1.0.0
> **Ratified:** 2026-03-09
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.1.0
> **Profile:** Container Image

## Purpose

Pre-built container image for [gourmand](https://codeberg.org/mattdm/gourmand), an AI-slop detector for codebases. Eliminates the need to compile gourmand from Rust source in every CI pipeline run.

## Base Image

Hummingbird (`quay.io/hummingbird/base:latest`) — lightweight container base for static binaries.

## Registry

| Registry | Image |
|----------|-------|
| Quay.io | `quay.io/crunchtools/gourmand` |
| GHCR | `ghcr.io/crunchtools/gourmand` |

## Build Strategy

Multi-stage build:
1. **Builder stage:** `rust:slim` — compiles gourmand from source via `cargo install`
2. **Runtime stage:** Hummingbird — copies only the static binary

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

## Rebuild Schedule

Weekly Monday 6 AM UTC via GHA cron, plus on every push to main.
