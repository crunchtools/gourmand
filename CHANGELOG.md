# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

Nothing yet.

## [1.0.0] - 2026-09-19

First tagged release. Entries accrue from 2026-09-19 forward (RT #1484).

### Changed

- **BREAKING:** Upstream gourmand moved from rev `916a1317` (2026-03-09,
  self-reported `v0.1.0`) to the **v0.16.5** tag, ~4,000 commits ahead
  (RT #1482). Consumers must migrate; see below.
- The upstream CLI is now subcommand-based. `gourmand --full <path>` is gone
  in favour of **`gourmand check --full <path>`**.
- Check surface grew from **35 to 89** checks.

### Fixed

- Upstream no longer zeroes every threshold when a project has a
  `gourmand.toml` with no `[thresholds]` table. In `v0.1.0` that silently set
  every threshold to `0`; adopters worked around it by restating the built-in
  defaults verbatim. Those workaround blocks should now be **deleted** —
  `Thresholds::default()` returns the real defaults.

### Migration

This image is published as a pinned tag. `:latest` still serves the previous
build so adopters can cut over one repo at a time via gatehouse `v0.6.0`.

Per consuming repo:

1. Delete the `[thresholds]` block from `gourmand.toml`. Upstream **hard-errors**
   on the old field names (20 were renamed in v0.14.x).
2. Add a `classification` to every `[[exceptions]]` entry — one of
   `gourmand_bug`, `by_design`, `accepted_bad_taste`, `fix_planned`. Required
   at runtime.
3. Add a `[[check_overrides]]` entry, with `classification`, for every check
   disabled in `[checks]`.
4. Bump `uses: crunchtools/gatehouse/.github/workflows/gourmand.yml@v0.5.0`
   to `@v0.6.0`.

Bare check slugs (`random_scripts`) still resolve to compound IDs
(`CH009-random_scripts`) automatically — no edits needed to `check =` fields.

Note: `gourmand upgrade` and `gourmand migrate-check-names --apply` both
hard-stop on the `[thresholds]` error and instruct you to run the command you
just ran. Remove the block by hand first; `upgrade --apply` works after that
(and requires a clean git tree).

### Requirements

- Upstream requires **rustc >= 1.95**. `quay.io/hummingbird/rust:latest-builder`
  ships 1.98.1.
