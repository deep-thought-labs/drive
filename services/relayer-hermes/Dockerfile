# Hermes IBC relayer — no build: use official Linux binary from GitHub releases.
# See https://github.com/informalsystems/hermes/releases
# Note: Docker Hub image informaldev/hermes exists but is outdated (4+ years); we use the official binary instead.

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget tar && \
    rm -rf /var/lib/apt/lists/*

# Download official Hermes Linux binary from GitHub releases (no compilation)
ARG HERMES_VERSION=1.13.3
RUN set -eux; \
    ARCH="x86_64"; \
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
