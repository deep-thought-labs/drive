###############################################################################
# Shared endpoint validation helpers
#
# Copyright 2025, Deep Thought Labs. https://deep-thought.computer
# This file is part of the Infinite Drive ecosystem (Project 42).
#
# Source this file from validation scripts. Expects:
#   - HOST (set before calling test_dns_resolution)
#   - PASSED_TESTS, FAILED_TESTS, TOTAL_TESTS (for print_success/print_error)
#   - Optional: RED, GREEN, YELLOW, BLUE, NC (if not set, we define them)
#
# Common practices centralised here:
#   - url_has_scheme: did the user pass a protocol (https:// or http://)?
#   - protocol_default_port: default port for a protocol (443/80)
#   - step_timer_start / step_timer_elapsed: step timing for consistent UX
#   - print_incomplete_validation_hint: warning when a step was skipped (no protocol/port)
###############################################################################

# Colors (allow override by caller)
RED="${RED:-\033[0;31m}"
GREEN="${GREEN:-\033[0;32m}"
YELLOW="${YELLOW:-\033[1;33m}"
BLUE="${BLUE:-\033[0;34m}"
NC="${NC:-\033[0m}"

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_TESTS++)) || true
    ((TOTAL_TESTS++)) || true
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_TESTS++)) || true
    ((TOTAL_TESTS++)) || true
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Return 0 if URL has a scheme (https:// or http://), 1 otherwise. Use to set USER_SPECIFIED_PROTOCOL.
url_has_scheme() {
    local url="${1:-}"
    [[ "$url" =~ ^https?:// ]] && return 0 || return 1
}

# Echo the default port for the given protocol (https -> 443, http -> 80). Used when user specified
# protocol but no port, so the probe uses the protocol default without imposing other ports.
protocol_default_port() {
    local protocol="${1:-}"
    [ "$protocol" = "https" ] && echo 443 || echo 80
}

# Step timing: call step_timer_start at the start of a step, step_timer_elapsed N [suffix] at the end.
# Uses global ENDPOINT_STEP_START (set by step_timer_start). Optional suffix appended to the message.
ENDPOINT_STEP_START=0
step_timer_start() {
    ENDPOINT_STEP_START=$(date +%s 2>/dev/null || echo 0)
}
step_timer_elapsed() {
    local step_num="${1:-0}"
    local suffix="${2:-}"
    local end now elapsed
    now=$(date +%s 2>/dev/null || echo 0)
    end=$((now - ${ENDPOINT_STEP_START:-0}))
    elapsed=$end
    [ "$elapsed" -gt 0 ] 2>/dev/null && print_info "Step ${step_num} completed in ${elapsed}s${suffix}"
}

# Print standard warning when a step was skipped because no protocol or port was specified.
# step_desc: short description (e.g. "the gRPC service check (step 5)")
# host: hostname for examples (default: $HOST)
# port_examples: optional (e.g. "host:443 or host:9090"); if empty, uses "e.g. host:443"
# intro_line: optional; if set, printed first (e.g. "This run did not perform the full gRPC validation (step 5). For complete validation including chain info, re-run with:"); then bullet lines. If unset, prints the summary-style block (this validation did not include all steps...; To run the full validation...).
print_incomplete_validation_hint() {
    local step_desc="${1:-a step}"
    local host="${2:-$HOST}"
    local port_examples="${3:-e.g. ${host}:443}"
    local intro_line="${4:-}"
    if [ -n "$intro_line" ]; then
        print_warning "$intro_line"
        print_warning "  — protocol at the start:  https://${host}  or  http://${host}"
        print_warning "  — or a port at the end:  ${port_examples}"
    else
        print_warning "This validation did not include all steps: ${step_desc} was skipped because no protocol or port was specified."
        print_warning "To run the full validation, use the endpoint with a protocol (e.g. https://${host} or http://${host}) or with a port (e.g. ${port_examples})."
    fi
}

# Resolve host to an IP. Sets RESOLVED_IP (empty on failure). Returns 0 if resolved, 1 otherwise.
# Usage: resolve_dns "hostname" -> RESOLVED_IP and return code
resolve_dns() {
    local host="$1"
    RESOLVED_IP=""
    command -v getent >/dev/null 2>&1 && RESOLVED_IP=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -n1)
    [ -n "$RESOLVED_IP" ] && return 0
    command -v host >/dev/null 2>&1 && RESOLVED_IP=$(host "$host" 2>/dev/null | grep -E 'has address|has IPv4 address' | awk '{print $NF}' | head -n1)
    [ -n "$RESOLVED_IP" ] && return 0
    command -v dig >/dev/null 2>&1 && RESOLVED_IP=$(dig +short "$host" A 2>/dev/null | head -n1)
    [ -n "$RESOLVED_IP" ] && return 0
    command -v nslookup >/dev/null 2>&1 && RESOLVED_IP=$(nslookup "$host" 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -n1)
    [ -n "$RESOLVED_IP" ] && return 0
    return 1
}

# Run DNS resolution test using global HOST. On failure exits 1 unless no DNS tools (then warning and return).
test_dns_resolution() {
    print_header "2. DNS Resolution"
    if ! command -v nslookup >/dev/null 2>&1 && ! command -v host >/dev/null 2>&1 && ! command -v dig >/dev/null 2>&1 && ! command -v getent >/dev/null 2>&1; then
        print_warning "DNS tools not available, skipping test"
        return 0
    fi
    if resolve_dns "$HOST"; then
        if [ -n "$RESOLVED_IP" ]; then
            print_success "DNS resolved: $HOST -> $RESOLVED_IP"
        else
            print_success "DNS resolved: $HOST"
        fi
        return 0
    fi
    if host "$HOST" >/dev/null 2>&1 || nslookup "$HOST" >/dev/null 2>&1 || dig "$HOST" >/dev/null 2>&1; then
        print_success "DNS resolved: $HOST (IP not extracted)"
        return 0
    fi
    print_error "Could not resolve DNS for: $HOST"
    exit 1
}

print_credits() {
    echo -e "\n${BLUE}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  Authorship & rights${NC}"
    echo -e "${BLUE}  Copyright 2025, Deep Thought Labs.${NC}"
    echo -e "${BLUE}  This tool is part of the Infinite Drive ecosystem (Project 42).${NC}"
    echo -e "${BLUE}  Infinite Drive: https://infinitedrive.xyz  |  Docs: https://docs.infinitedrive.xyz${NC}"
    echo -e "${BLUE}  Deep Thought Labs: https://deep-thought.computer${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}\n"
}
