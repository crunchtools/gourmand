FROM quay.io/hummingbird/rust:latest-builder AS builder

RUN cargo install --git https://codeberg.org/mattdm/gourmand.git

FROM quay.io/hummingbird/base:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.source=https://github.com/crunchtools/gourmand
LABEL org.opencontainers.image.description="Pre-built gourmand binary for AI slop detection in CI pipelines"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

COPY --from=builder /usr/local/cargo/bin/gourmand /usr/local/bin/gourmand

ENTRYPOINT ["gourmand"]
CMD ["--help"]
