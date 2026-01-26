#!/bin/bash
# Docker Compose Wrapper Script
# Automatically configures volume permissions for the container user (ubuntu, UID 1000)
# Works with or without sudo
# Supports all docker-compose commands including 'exec' for running commands inside containers

# Don't use set -e here - we need to handle errors manually to show logs even if docker compose has warnings
# set -e

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

# Function to get the service name from docker-compose.yml
# Returns the first service name found in the file
get_service_name() {
    # Try to use docker compose config if available (most reliable)
    if $DOCKER_COMPOSE_CMD config --services 2>/dev/null | head -1; then
        return 0
    fi
    
    # Fallback: parse docker-compose.yml directly
    # Look for the first service definition after "services:"
    # Pattern: services: followed by service name on next line
    if command -v awk > /dev/null 2>&1; then
        awk '/^services:/ {getline; if ($0 ~ /^[[:space:]]*[a-zA-Z0-9_-]+:[[:space:]]*$/) {gsub(/[[:space:]:]/, "", $0); print $0; exit}}' docker-compose.yml 2>/dev/null
    else
        # Simple grep fallback (less reliable but works in most cases)
        grep -A 1 "^services:" docker-compose.yml 2>/dev/null | grep -E "^[[:space:]]*[a-zA-Z0-9_-]+:" | head -1 | sed 's/[[:space:]:]//g' 2>/dev/null
    fi
}

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

# Detect if user is calling a node-* command directly (without exec and service name)
# If so, automatically prepend 'exec' and service name
# Only do this if the first argument is NOT 'exec' (user hasn't already specified it)
if [ -n "$1" ] && [ "$1" != "exec" ] && echo "$1" | grep -qE "^node-"; then
    # User is calling a node-* command directly (e.g., ./drive.sh node-init)
    # Get service name from docker-compose.yml
    SERVICE_NAME=$(get_service_name)
    
    if [ -z "$SERVICE_NAME" ]; then
        echo "❌ Error: Could not determine service name from docker-compose.yml"
        echo "   Please use: ./drive.sh exec <service-name> $@"
        exit 1
    fi
    
    # Rebuild arguments: exec, service-name, then all original arguments
    ORIGINAL_ARGS=("$@")
    NEW_ARGS=("exec" "$SERVICE_NAME")
    for arg in "${ORIGINAL_ARGS[@]}"; do
        NEW_ARGS+=("$arg")
    done
    set -- "${NEW_ARGS[@]}"
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

# Check if this is an 'exec' command that requires interactive mode
# Automatically add -it flag for commands that need user input
if [ "$1" = "exec" ]; then
    # Commands that ALWAYS require interactive mode
    ALWAYS_INTERACTIVE_COMMANDS="node-ui"
    
    # Commands that require interactive mode for certain operations
    # These commands may work without -it in some cases, but typically need it
    INTERACTIVE_COMMANDS="node-init|node-keys"
    
    # Commands that require interactive mode only with specific flags
    # node-logs requires -it only when using -f or --follow
    CONDITIONAL_INTERACTIVE="node-update-genesis|node-clean-data"
    
    # Check if any interactive command is being executed
    NEEDS_INTERACTIVE=false
    HAS_IT_FLAG=false
    
    # Check if -it, -i, or --interactive flag is already present
    for arg in "$@"; do
        if [ "$arg" = "-it" ] || [ "$arg" = "-i" ] || [ "$arg" = "--interactive" ] || [ "$arg" = "-ti" ]; then
            HAS_IT_FLAG=true
            break
        fi
    done
    
    # If -it flag is not present, check if we need to add it
    if [ "$HAS_IT_FLAG" = false ]; then
        # Check each argument for interactive commands
        for arg in "$@"; do
            # Check for always interactive commands
            if echo "$arg" | grep -qE "^($ALWAYS_INTERACTIVE_COMMANDS)$"; then
                NEEDS_INTERACTIVE=true
                break
            fi
            
            # Check for interactive commands (node-init, node-keys)
            if echo "$arg" | grep -qE "^($INTERACTIVE_COMMANDS)$"; then
                NEEDS_INTERACTIVE=true
                break
            fi
            
            # Check for conditional interactive commands
            # node-logs with -f or --follow
            if echo "$arg" | grep -qE "^node-logs$"; then
                # Check if next argument is -f or --follow
                for next_arg in "$@"; do
                    if [ "$next_arg" = "-f" ] || [ "$next_arg" = "--follow" ]; then
                        NEEDS_INTERACTIVE=true
                        break 2
                    fi
                done
            fi
            
            # Check for node-update-genesis and node-clean-data
            if echo "$arg" | grep -qE "^($CONDITIONAL_INTERACTIVE)$"; then
                # These commands may prompt for confirmation, so add -it
                NEEDS_INTERACTIVE=true
                break
            fi
            
            # Check for node-keys subcommands that require interactivity
            # node-keys create, add, delete, reset-password require interactivity
            if echo "$arg" | grep -qE "^node-keys$"; then
                for next_arg in "$@"; do
                    if [ "$next_arg" = "create" ] || [ "$next_arg" = "add" ] || \
                       [ "$next_arg" = "delete" ] || [ "$next_arg" = "reset-password" ]; then
                        NEEDS_INTERACTIVE=true
                        break 2
                    fi
                done
            fi
            
            # Check for node-init with --recover flag
            if echo "$arg" | grep -qE "^node-init$"; then
                for next_arg in "$@"; do
                    if [ "$next_arg" = "--recover" ] || [ "$next_arg" = "-r" ]; then
                        NEEDS_INTERACTIVE=true
                        break 2
                    fi
                done
                # node-init without arguments also needs interactivity (asks for moniker)
                NEEDS_INTERACTIVE=true
                break
            fi
        done
        
        # If interactive mode is needed, insert -it after 'exec'
        if [ "$NEEDS_INTERACTIVE" = true ]; then
            # Rebuild arguments with -it inserted after 'exec'
            # Save all original arguments to an array
            ORIGINAL_ARGS=("$@")
            # Create new array starting with 'exec' and '-it'
            NEW_ARGS=("exec" "-it")
            # Add all remaining arguments (skip index 0 which is 'exec')
            i=1
            while [ $i -lt ${#ORIGINAL_ARGS[@]} ]; do
                NEW_ARGS+=("${ORIGINAL_ARGS[$i]}")
                i=$((i + 1))
            done
            # Replace current arguments with new array
            set -- "${NEW_ARGS[@]}"
        fi
    fi
fi

# Execute docker-compose with all passed arguments
# If sudo was used to run this script, we need to use sudo for docker-compose too
EXIT_CODE=0
if [ -n "$SUDO_USER" ]; then
    # Running with sudo, so use sudo for docker-compose
    sudo -E $DOCKER_COMPOSE_CMD "$@" || EXIT_CODE=$?
else
    # Running without sudo, execute normally
    # If Docker requires sudo, the user will see Docker's permission error
    # Documentation explains how to use sudo ./drive.sh or configure Docker
    $DOCKER_COMPOSE_CMD "$@" || EXIT_CODE=$?
fi

# If 'up -d' was executed, show logs automatically (even if exit code is non-zero)
# This ensures logs are shown even if docker compose reports warnings
if [ "$SHOW_LOGS" = true ]; then
    echo ""
    echo "📋 Container started in detached mode. Waiting for initialization..."
    echo "   (This may take a moment while the container downloads and configures the binary)"
    echo ""
    
    # Wait for container to actually start and begin processing
    # Simple approach: wait for container to be running and generating logs
    MAX_WAIT=20
    WAIT_COUNT=0
    CONTAINER_READY=false
    
    echo -n "   Waiting for container to initialize"
    while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
        # Check if any container from this compose is running
        if [ -n "$SUDO_USER" ]; then
            if sudo -E $DOCKER_COMPOSE_CMD ps 2>/dev/null | grep -q "Up"; then
                # Container is running, check if it has started generating logs
                LOG_COUNT=$(sudo -E $DOCKER_COMPOSE_CMD logs --tail=5 2>/dev/null | wc -l)
                if [ "$LOG_COUNT" -gt 0 ]; then
                    CONTAINER_READY=true
                    break
                fi
            fi
        else
            if $DOCKER_COMPOSE_CMD ps 2>/dev/null | grep -q "Up"; then
                # Container is running, check if it has started generating logs
                LOG_COUNT=$($DOCKER_COMPOSE_CMD logs --tail=5 2>/dev/null | wc -l)
                if [ "$LOG_COUNT" -gt 0 ]; then
                    CONTAINER_READY=true
                    break
                fi
            fi
        fi
        echo -n "."
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))
    done
    echo ""
    
    if [ "$CONTAINER_READY" = false ]; then
        echo "   ⚠️  Container may still be starting. Showing logs anyway..."
    fi
    
    echo "📋 Showing container logs from the beginning..."
    echo "   (Press Ctrl+C to stop viewing logs - container will continue running)"
    echo ""
    
    # Show logs from the beginning and follow them (with trap to handle Ctrl+C gracefully)
    # Use a function for cleanup to ensure it's called even if the script is interrupted
    cleanup_logs() {
        echo ""
        echo "ℹ️  Logs view stopped. Container continues running."
        echo "   To view logs again: ./drive.sh logs -f"
        exit 0
    }
    
    # Set trap for INT (Ctrl+C) and TERM signals
    trap cleanup_logs INT TERM
    
    # Show logs - this will block until Ctrl+C is pressed
    # Use || true to prevent script from exiting if logs command fails
    if [ -n "$SUDO_USER" ]; then
        sudo -E $DOCKER_COMPOSE_CMD logs -f --tail=0 || cleanup_logs
    else
        $DOCKER_COMPOSE_CMD logs -f --tail=0 || cleanup_logs
    fi
    
    # If we get here, logs command exited normally (shouldn't happen with -f, but handle it)
    cleanup_logs
fi
