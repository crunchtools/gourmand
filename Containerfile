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
RUN cargo install --git https://gitlab.com/mattdm/gourmand.git \
    --tag v0.16.5

FROM quay.io/hummingbird/rust:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.source=https://github.com/crunchtools/gourmand
LABEL org.opencontainers.image.description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

COPY --from=builder /usr/local/cargo/bin/gourmand /usr/local/bin/gourmand

ENTRYPOINT ["gourmand"]
CMD ["--help"]
