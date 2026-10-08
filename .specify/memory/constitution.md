# gourmand Constitution

> **Version:** 1.2.0
> **Ratified:** 2026-03-11
> **Amended:** 2026-10-02
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.21.0
> **Profile:** Container Image

This file holds what is specific to the gourmand image. The fleet rules and
the Container Image profile apply at the inherited version and are checked
against this repo's files by `constitution.yml`. They are not restated here.

## Purpose

Pre-built container image for [gourmand](https://gitlab.com/mattdm/gourmand),
an AI-slop detector for codebases. Eliminates compiling gourmand from Rust
source in every CI pipeline run. Published to `quay.io/crunchtools/gourmand`
and `ghcr.io/crunchtools/gourmand`; the fleet's Gourmand gate runs from this
image.

## Upstream Pin

- **Source:** `https://gitlab.com/mattdm/gourmand.git` (moved from Codeberg on
  2026-08-20; the Codeberg URL 404s).
- **Pin:** an upstream release tag (currently `v0.16.5`), installed with
  `cargo install --tag`. Never a floating branch.
- **Breaking upstream changes** (such as the v0.16 move to the `check`
  subcommand and stricter config parsing) ship as a new image tag that
  adopters pin to and cut over one repo at a time, not as a silent change to
  what they already run (RT #1482).

## Build Stages

| Stage | Image | Role |
|-------|-------|------|
| Builder | `quay.io/hummingbird/rust:latest-builder` | `cargo install` from the pinned tag; must satisfy upstream's minimum rustc |
| Runtime | `quay.io/hummingbird/rust:latest` | carries only the `gourmand` binary at `/usr/local/bin/gourmand` |

`ENTRYPOINT ["gourmand"]`, default `CMD ["--help"]`.

## History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-09 | Initial constitution |
| 1.1.0 | 2026-03-11 | Fixed to pass factory validation |
| 1.1.1 | 2026-09-25 | Gatehouse review, triage and pre-commit gates |
| 1.2.0 | 2026-10-02 | Manifest under constitution v1.18.0: fleet and profile restatement removed; build stages and upstream pin corrected to the Containerfile |
