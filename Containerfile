FROM quay.io/hummingbird/rust:latest-builder AS builder

# Upstream moved from Codeberg to GitLab on 2026-08-20 (commit 234c1e1c,
# "Migrate project hosting from Codeberg to GitLab"). The Codeberg URL now
# 404s, which cargo reports as a confusing authentication failure.
#
# Pinned to the exact commit the published image was built from on
# 2026-03-15, NOT to upstream's latest. This binary is the Code Quality
# gate for all 22 repos that consume gatehouse's reusable workflow, and
# upstream has since made a breaking CLI change: as of v0.16.5 `--full` is
# gone in favour of subcommands, so a newer build would fail every one of
# those repos with "unexpected argument '--full' found".
#
# Restoring a reproducible build and changing the gate's behaviour are two
# different jobs. This is the first one. Moving to v0.16.5+ also means
# updating `gourmand --full` in gatehouse's workflow and re-validating
# thresholds fleet-wide -- see RT #1462.
RUN cargo install --git https://gitlab.com/mattdm/gourmand.git \
    --rev 916a13170c449f3bb64dcae46c4164197f8dd59d

FROM quay.io/hummingbird/rust:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.source=https://github.com/crunchtools/gourmand
LABEL org.opencontainers.image.description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

COPY --from=builder /usr/local/cargo/bin/gourmand /usr/local/bin/gourmand

ENTRYPOINT ["gourmand"]
CMD ["--help"]
