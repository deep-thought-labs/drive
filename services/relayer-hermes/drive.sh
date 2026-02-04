#!/bin/bash
# Docker Compose Wrapper Script for Relayer (Hermes)
# Supports all docker-compose commands. No port allocation (this service does not expose ports).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "❌ Error: docker-compose or 'docker compose' not found"
    exit 1
fi

cd "$SCRIPT_DIR"

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in $SCRIPT_DIR"
    exit 1
fi

# Ensure persistent-data exists so the mount works; Hermes expects config.toml and keys/ inside
if [ ! -d "persistent-data" ]; then
    mkdir -p "persistent-data"
    chmod 775 "persistent-data" 2>/dev/null || true
    echo "📁 Created persistent-data/ — add config.toml and keys before starting the relayer."
fi

if [ -n "$SUDO_USER" ]; then
    sudo -E $DOCKER_COMPOSE_CMD "$@"
else
    $DOCKER_COMPOSE_CMD "$@"
fi
