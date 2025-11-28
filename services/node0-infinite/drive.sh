#!/bin/bash
# Docker Compose Wrapper Script
# Automatically configures PUID and PGID for proper volume permissions
# Works with or without sudo
# Supports all docker-compose commands including 'exec' for running commands inside containers

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect user ID and group ID (works with or without sudo)
# ${SUDO_UID:-$(id -u)} means: use SUDO_UID if it exists (when using sudo), otherwise use $(id -u)
export PUID=${SUDO_UID:-$(id -u)}
export PGID=${SUDO_GID:-$(id -g)}

# Check if docker-compose or docker compose is available
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "❌ Error: docker-compose or 'docker compose' not found"
    exit 1
fi

# Change to the script directory (where docker-compose.yml is located)
cd "$SCRIPT_DIR"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in $SCRIPT_DIR"
    exit 1
fi

# Show what UID/GID will be used (helpful for debugging)
if [ "${DEBUG:-0}" = "1" ]; then
    echo "ℹ️  Using UID: $PUID, GID: $PGID"
fi

# Execute docker-compose with all passed arguments
# Pass PUID and PGID as environment variables
# If sudo was used to run this script, we need to use sudo for docker-compose too
if [ -n "$SUDO_USER" ]; then
    # Running with sudo, so use sudo for docker-compose
    # -E preserves environment variables (PUID, PGID)
    sudo -E $DOCKER_COMPOSE_CMD "$@"
else
    # Running without sudo, execute normally
    # PUID and PGID are already exported, so they'll be available to docker-compose
    # If Docker requires sudo, the user will see Docker's permission error
    # Documentation explains how to use sudo ./drive.sh or configure Docker
    $DOCKER_COMPOSE_CMD "$@"
fi

