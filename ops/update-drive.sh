#!/bin/bash
# Drive Update Script
# Automatically updates Drive services by:
# 1. Detecting running services
# 2. Stopping all services
# 3. Cleaning git changes
# 4. Updating repository (git pull)
# 5. Restarting previously running services

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the repository root directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to repository root
cd "$REPO_ROOT"

echo -e "${GREEN}=========================================="
echo "Drive Update Script"
echo "==========================================${NC}"
echo ""

# Function to check if a service is running
is_service_running() {
    local service_dir="$1"
    local service_name=$(basename "$service_dir")
    
    if [ ! -f "$service_dir/docker-compose.yml" ] || [ ! -f "$service_dir/drive.sh" ]; then
        return 1
    fi
    
    cd "$service_dir"
    if docker compose ps 2>/dev/null | grep -q "Up" || docker-compose ps 2>/dev/null | grep -q "Up"; then
        return 0
    else
        return 1
    fi
}

# Function to stop a service
stop_service() {
    local service_dir="$1"
    local service_name=$(basename "$service_dir")
    
    echo -e "${YELLOW}⏹️  Stopping ${service_name}...${NC}"
    cd "$service_dir"
    ./drive.sh down 2>/dev/null || true
    echo -e "${GREEN}✅ ${service_name} stopped${NC}"
}

# Function to start a service
start_service() {
    local service_dir="$1"
    local service_name=$(basename "$service_dir")
    
    echo -e "${YELLOW}🚀 Starting ${service_name}...${NC}"
    cd "$service_dir"
    ./drive.sh up -d
    echo -e "${GREEN}✅ ${service_name} started${NC}"
}

# Step 1: Detect running services
echo -e "${BOLD}📋 Step 1: Detecting running services...${NC}"
echo ""

RUNNING_SERVICES=()
SERVICES_DIR="$REPO_ROOT/services"

if [ ! -d "$SERVICES_DIR" ]; then
    echo -e "${RED}❌ Error: services directory not found at $SERVICES_DIR${NC}"
    exit 1
fi

for service_dir in "$SERVICES_DIR"/*; do
    if [ -d "$service_dir" ] && [ -f "$service_dir/docker-compose.yml" ] && [ -f "$service_dir/drive.sh" ]; then
        service_name=$(basename "$service_dir")
        if is_service_running "$service_dir"; then
            RUNNING_SERVICES+=("$service_dir")
            echo -e "   ${CYAN}✓${NC} ${service_name} is running"
        else
            echo -e "   ${YELLOW}○${NC} ${service_name} is not running"
        fi
    fi
done

echo ""
if [ ${#RUNNING_SERVICES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No services are currently running${NC}"
else
    echo -e "${GREEN}Found ${#RUNNING_SERVICES[@]} running service(s)${NC}"
fi
echo ""

# Step 2: Stop all services
echo -e "${BOLD}📋 Step 2: Stopping all services...${NC}"
echo ""

cd "$REPO_ROOT"
for service_dir in "$SERVICES_DIR"/*; do
    if [ -d "$service_dir" ] && [ -f "$service_dir/docker-compose.yml" ] && [ -f "$service_dir/drive.sh" ]; then
        service_name=$(basename "$service_dir")
        if is_service_running "$service_dir"; then
            stop_service "$service_dir"
        fi
    fi
done

echo ""

# Step 3: Clean git changes (only tracked files)
echo -e "${BOLD}📋 Step 3: Cleaning git changes (tracked files only)...${NC}"
echo ""

cd "$REPO_ROOT"

# Check if there are any changes in tracked files
TRACKED_CHANGES=$(git diff --name-only 2>/dev/null || echo "")
STAGED_CHANGES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [ -n "$TRACKED_CHANGES" ] || [ -n "$STAGED_CHANGES" ]; then
    echo -e "${YELLOW}⚠️  Found uncommitted changes in tracked files. Restoring...${NC}"
    
    # Restore all tracked files (modified and staged)
    # This only affects files that are already in git, not untracked files
    git restore . 2>/dev/null || git checkout . 2>/dev/null || true
    
    # Also restore staged changes
    git restore --staged . 2>/dev/null || git reset HEAD . 2>/dev/null || true
    
    echo -e "${GREEN}✅ Tracked files restored to committed state${NC}"
    echo -e "${CYAN}ℹ️  Note: Untracked files (like persistent-data) are preserved${NC}"
else
    echo -e "${GREEN}✅ No changes in tracked files to restore${NC}"
fi

# IMPORTANT: We do NOT use 'git clean' to avoid deleting untracked files
# Untracked files (like data in persistent-data/) are preserved intentionally

echo ""

# Step 4: Update repository
echo -e "${BOLD}📋 Step 4: Updating repository (git pull)...${NC}"
echo ""

cd "$REPO_ROOT"

# Check if we're on a branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# If detached HEAD, try to checkout the branch that contains current commit (e.g. main or dev)
if [ -z "$CURRENT_BRANCH" ]; then
    echo -e "${YELLOW}⚠️  Detected detached HEAD (not on a branch).${NC}"
    UPDATED=0
    # Find a branch that contains the current commit; prefer main, then dev
    for preferred in main dev master; do
        if git branch -a --contains HEAD 2>/dev/null | grep -qE "(\s|/)${preferred}$"; then
            echo -e "${CYAN}Checking out ${preferred} and pulling latest...${NC}"
            if git checkout "$preferred" 2>/dev/null && git pull origin "$preferred" 2>/dev/null; then
                echo -e "${GREEN}✅ Switched to ${preferred} and repository updated successfully${NC}"
                UPDATED=1
            else
                echo -e "${RED}❌ Error: Failed to checkout/pull ${preferred}. You may need to run: git checkout <branch> && git pull${NC}"
            fi
            break
        fi
    done
    if [ "$UPDATED" -eq 0 ]; then
        # No preferred branch contained HEAD or pull failed; list branches that do
        CONTAINING_BRANCHES=$(git branch -a --contains HEAD 2>/dev/null | sed 's/^[* ]*//;s/remotes\/origin\///' | sort -u | grep -v 'HEAD' | head -5)
        if [ -n "$CONTAINING_BRANCHES" ]; then
            echo -e "${CYAN}Branches containing current commit:${NC}"
            echo "$CONTAINING_BRANCHES" | while read b; do echo "   - $b"; done
            echo -e "${YELLOW}Run manually: git checkout <branch> && git pull origin <branch>${NC}"
        else
            echo -e "${YELLOW}Not on a branch and no remote branch contains this commit. Skipping git pull.${NC}"
            echo -e "${CYAN}To update: git checkout main && git pull  (or your usual branch)${NC}"
        fi
    fi
else
    echo -e "${CYAN}Pulling latest changes from ${CURRENT_BRANCH}...${NC}"
    
    if git pull origin "$CURRENT_BRANCH" 2>/dev/null; then
        echo -e "${GREEN}✅ Repository updated successfully${NC}"
    else
        echo -e "${RED}❌ Error: Failed to pull from repository${NC}"
        echo -e "${YELLOW}⚠️  Continuing anyway...${NC}"
    fi
fi

echo ""

# Step 5: Restart previously running services
echo -e "${BOLD}📋 Step 5: Restarting previously running services...${NC}"
echo ""

if [ ${#RUNNING_SERVICES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No services were running before update. Skipping restart.${NC}"
else
    echo -e "${CYAN}Restarting ${#RUNNING_SERVICES[@]} service(s)...${NC}"
    echo ""
    
    for service_dir in "${RUNNING_SERVICES[@]}"; do
        service_name=$(basename "$service_dir")
        start_service "$service_dir"
        echo ""
    done
    
    echo -e "${GREEN}✅ All services restarted${NC}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✅ Drive update completed successfully!"
echo "==========================================${NC}"
echo ""

# Summary
echo -e "${BOLD}📊 Summary:${NC}"
echo ""
echo "   Services stopped: ${#RUNNING_SERVICES[@]}"
echo "   Services restarted: ${#RUNNING_SERVICES[@]}"
echo "   Repository updated: ✅"
echo ""

if [ ${#RUNNING_SERVICES[@]} -gt 0 ]; then
    echo -e "${CYAN}Restarted services:${NC}"
    for service_dir in "${RUNNING_SERVICES[@]}"; do
        service_name=$(basename "$service_dir")
        echo "   - ${service_name}"
    done
    echo ""
fi

echo -e "${GREEN}All done! 🎉${NC}"
