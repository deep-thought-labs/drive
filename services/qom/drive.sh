#!/bin/bash
# Docker Compose Wrapper Script
# Automatically configures volume permissions for the container user (ubuntu, UID 1000)
# Works with or without sudo
# Supports all docker-compose commands including 'exec' for running commands inside containers

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Ensure persistent-data directory exists and has correct permissions
# The container runs as user 'ubuntu' (UID 1000), so we need to ensure the directory
# is accessible to UID 1000. We do this by:
# 1. Setting permissions to allow group/others write (775 or 777)
# 2. Or changing ownership to UID 1000 if we have sudo rights
# Note: Container always runs as UID 1000:1000 (set in Dockerfile), so we configure for that
if [ -d "persistent-data" ]; then
    # Try to fix permissions - give write access to group and others
    # This allows the container user (UID 1000) to write even if owned by different user
    if [ -w "persistent-data" ] || [ -n "$SUDO_USER" ]; then
        # Option 1: Make it writable by group and others (works for most cases)
        chmod -R 775 "persistent-data" 2>/dev/null || chmod -R 777 "persistent-data" 2>/dev/null || true
        
        # Option 2: If we have sudo, change ownership to UID 1000 (container user)
        if [ -n "$SUDO_USER" ]; then
            chown -R 1000:1000 "persistent-data" 2>/dev/null || true
        fi
    fi
else
    # Create the directory with correct permissions
    mkdir -p "persistent-data"
    # Set permissions to allow container user (UID 1000) to write
    chmod 775 "persistent-data" 2>/dev/null || chmod 777 "persistent-data" 2>/dev/null || true
    # If we have sudo, set ownership to UID 1000
    if [ -n "$SUDO_USER" ]; then
        chown -R 1000:1000 "persistent-data" 2>/dev/null || true
    fi
fi

# Check if this is an 'up' command with -d flag (detached mode)
SHOW_LOGS=false
if [ "$1" = "up" ]; then
    # Check if -d or --detach flag is present
    for arg in "$@"; do
        if [ "$arg" = "-d" ] || [ "$arg" = "--detach" ]; then
            SHOW_LOGS=true
            break
        fi
    done
fi

# Execute docker-compose with all passed arguments
# If sudo was used to run this script, we need to use sudo for docker-compose too
if [ -n "$SUDO_USER" ]; then
    # Running with sudo, so use sudo for docker-compose
    sudo -E $DOCKER_COMPOSE_CMD "$@"
    EXIT_CODE=$?
else
    # Running without sudo, execute normally
    # If Docker requires sudo, the user will see Docker's permission error
    # Documentation explains how to use sudo ./drive.sh or configure Docker
    $DOCKER_COMPOSE_CMD "$@"
    EXIT_CODE=$?
fi

# If 'up -d' was executed successfully, show logs automatically
if [ "$SHOW_LOGS" = true ] && [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "📋 Container started in detached mode. Showing logs..."
    echo "   (Press Ctrl+C to stop viewing logs - container will continue running)"
    echo ""
    # Wait a moment for container to start and generate initial logs
    sleep 2
    # Show logs and follow them (with trap to handle Ctrl+C gracefully)
    trap 'echo ""; echo "ℹ️  Logs view stopped. Container continues running."; echo "   To view logs again: ./drive.sh logs -f"; exit 0' INT
    if [ -n "$SUDO_USER" ]; then
        sudo -E $DOCKER_COMPOSE_CMD logs -f
    else
        $DOCKER_COMPOSE_CMD logs -f
    fi
fi
