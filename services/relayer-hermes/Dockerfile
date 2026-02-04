# Hermes IBC relayer — no build: use official Linux binary from GitHub releases.
# See https://github.com/informalsystems/hermes/releases
# Note: Docker Hub image informaldev/hermes exists but is outdated (4+ years); we use the official binary instead.

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget tar && \
    rm -rf /var/lib/apt/lists/*

# Download official Hermes Linux binary from GitHub releases (no compilation).
# TARGETARCH is set by Docker when building (e.g. linux/amd64 -> amd64, linux/arm64 -> arm64).
# Hermes uses x86_64 / aarch64 in tarball names; we map amd64->x86_64, arm64->aarch64 for Apple Silicon.
ARG HERMES_VERSION=1.13.3
ARG TARGETARCH
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64)   ARCH="x86_64" ;; \
        arm64)   ARCH="aarch64" ;; \
        *)       echo "Unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    SUFFIX="${ARCH}-unknown-linux-gnu"; \
    URL="https://github.com/informalsystems/hermes/releases/download/v${HERMES_VERSION}/hermes-v${HERMES_VERSION}-${SUFFIX}.tar.gz"; \
    wget -q -O /tmp/hermes.tar.gz "$URL"; \
    tar -xzf /tmp/hermes.tar.gz -C /tmp; \
    if [ -f /tmp/hermes ]; then mv /tmp/hermes /usr/local/bin/hermes; \
    else mv /tmp/hermes-v${HERMES_VERSION}-${SUFFIX}/hermes /usr/local/bin/hermes; fi; \
    chmod +x /usr/local/bin/hermes; \
    rm -rf /tmp/hermes.tar.gz /tmp/hermes-v*

# Hermes reads config from $HOME/.hermes (config.toml and keys/)
ENV HOME=/root
RUN mkdir -p /root/.hermes/keys

VOLUME /root/.hermes

ENTRYPOINT ["hermes"]
CMD ["start"]
