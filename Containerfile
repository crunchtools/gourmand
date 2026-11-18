# Single source of truth for the upstream gourmand version. CI parses this line.
ARG UPSTREAM_VERSION=0.16.5

FROM quay.io/hummingbird/rust:latest-builder AS builder

# Upstream moved from Codeberg to GitLab on 2026-08-20 (commit 234c1e1c,
# "Migrate project hosting from Codeberg to GitLab"). The Codeberg URL now
# 404s, which cargo reports as a confusing authentication failure.
#
# Pinned to upstream's v0.16.5 tag. This replaces rev 916a1317 (2026-03-09),
# which reported itself as v0.1.0 and sat ~4,000 commits behind. Two reasons
# the move was worth the migration cost (RT #1482):
#
#   1. v0.1.0 silently zeroed every threshold when a project had a
#      gourmand.toml with no [thresholds] table. Every adopter worked around
#      it by restating the built-in defaults verbatim. v0.16.5 fixes the
#      merge (Thresholds::default() now returns the real defaults), so those
#      blocks are deleted rather than maintained.
#   2. The check surface grew from 35 to 89.
#
# BREAKING for adopters, which is why this ships as a pinned tag rather than
# as :latest. v0.16.5 is subcommand-based -- `gourmand --full` is gone in
# favour of `gourmand check --full` -- and it hard-errors on the old
# [thresholds] field names and on exceptions missing a `classification`.
# Adopters cut over one repo at a time via gatehouse v0.6.0; see RT #1482.
#
# Upstream requires rustc >= 1.95; the builder image above ships 1.98.1.
#
# patches/ carries fixes the fleet needs before upstream has them. Each one is
# written against the pinned tag, so bumping UPSTREAM_VERSION fails here until
# the patch is rebased or dropped -- loudly, never by building without it. The
# tests a patch adds run before the install, so a red patch never ships; they
# build as --lib with -j 2 because gourmand-checks' lib and lib-test rustc
# processes running side by side are enough to get a builder OOM-killed.
#
#   0001: honour `pattern` on [[exceptions]] entries. v0.16.5 drops the key
#         silently, so an exception written for one finding suppressed every
#         finding of that check in the file.
ARG UPSTREAM_VERSION
WORKDIR /build
COPY patches/ patches/
RUN git clone --quiet --depth 1 --branch "v${UPSTREAM_VERSION}" \
        https://gitlab.com/mattdm/gourmand.git gourmand \
    && git -C gourmand apply --verbose ../patches/*.patch \
    && CARGO_PROFILE_TEST_DEBUG=0 cargo test --locked --lib -j 2 \
        --manifest-path gourmand/Cargo.toml -p gourmand-core -p gourmand-checks -- \
        pattern_scoped \
    && cargo install --locked --path gourmand/crates/gourmand

FROM quay.io/hummingbird/rust:latest

ARG UPSTREAM_VERSION
LABEL com.crunchtools.gourmand.upstream="${UPSTREAM_VERSION}"
LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.source=https://github.com/crunchtools/gourmand
LABEL org.opencontainers.image.description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

COPY --from=builder /usr/local/cargo/bin/gourmand /usr/local/bin/gourmand

ENTRYPOINT ["gourmand"]
CMD ["--help"]
