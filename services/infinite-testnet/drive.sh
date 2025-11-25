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
    echo "📋 Container started in detached mode. Waiting for initialization..."
    echo "   (This may take a moment while the container downloads and configures the binary)"
    echo ""
    
    # Wait for container to actually start and begin processing
    # Get container name from docker-compose.yml or from docker compose ps
    CONTAINER_NAME=$(grep "container_name:" docker-compose.yml 2>/dev/null | awk '{print $2}' | tr -d '"' | tr -d "'" || echo "")
    if [ -z "$CONTAINER_NAME" ]; then
        # Try to get container name from docker compose ps (service name)
        SERVICE_NAME=$(grep "^[[:space:]]*[a-zA-Z0-9_-]*:" docker-compose.yml 2>/dev/null | head -1 | awk -F: '{print $1}' | xargs || echo "")
        if [ -n "$SERVICE_NAME" ]; then
            # Use service name to get container name
            if [ -n "$SUDO_USER" ]; then
                CONTAINER_NAME=$(sudo -E $DOCKER_COMPOSE_CMD ps -q "$SERVICE_NAME" 2>/dev/null | xargs -I {} docker inspect --format '{{.Name}}' {} 2>/dev/null | sed 's|^/||' | head -1 || echo "")
            else
                CONTAINER_NAME=$($DOCKER_COMPOSE_CMD ps -q "$SERVICE_NAME" 2>/dev/null | xargs -I {} docker inspect --format '{{.Name}}' {} 2>/dev/null | sed 's|^/||' | head -1 || echo "")
            fi
        fi
    fi
    
    # Wait for container to be running and generating logs (up to 15 seconds)
    MAX_WAIT=15
    WAIT_COUNT=0
    CONTAINER_READY=false
    
    while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
        # Check if container is running
        if [ -n "$CONTAINER_NAME" ]; then
            if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
                # Container is running, check if it has started generating logs
                if [ -n "$SUDO_USER" ]; then
                    LOG_COUNT=$(sudo -E $DOCKER_COMPOSE_CMD logs --tail=1 2>/dev/null | wc -l)
                else
                    LOG_COUNT=$($DOCKER_COMPOSE_CMD logs --tail=1 2>/dev/null | wc -l)
                fi
                if [ "$LOG_COUNT" -gt 0 ]; then
                    CONTAINER_READY=true
                    break
                fi
            fi
        else
            # If we can't find container name, just check if any container from this compose is running
            if [ -n "$SUDO_USER" ]; then
                if sudo -E $DOCKER_COMPOSE_CMD ps 2>/dev/null | grep -q "Up"; then
                    CONTAINER_READY=true
                    break
                fi
            else
                if $DOCKER_COMPOSE_CMD ps 2>/dev/null | grep -q "Up"; then
                    CONTAINER_READY=true
                    break
                fi
            fi
        fi
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))
    done
    
    # Give entrypoint a moment to start generating logs
    if [ "$CONTAINER_READY" = true ]; then
        sleep 1
    fi
    
    echo "📋 Showing container logs from the beginning..."
    echo "   (Press Ctrl+C to stop viewing logs - container will continue running)"
    echo ""
    
    # Show logs from the beginning and follow them (with trap to handle Ctrl+C gracefully)
    trap 'echo ""; echo "ℹ️  Logs view stopped. Container continues running."; echo "   To view logs again: ./drive.sh logs -f"; exit 0' INT
    if [ -n "$SUDO_USER" ]; then
        sudo -E $DOCKER_COMPOSE_CMD logs -f --tail=0
    else
        $DOCKER_COMPOSE_CMD logs -f --tail=0
    fi
fi

