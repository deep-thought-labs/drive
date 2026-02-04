#!/bin/bash

###############################################################################
# Cosmos (Tendermint) RPC Endpoint Validation Script
#
# Copyright 2025, Deep Thought Labs. https://deep-thought.computer
# This file is part of the Infinite Drive ecosystem (Project 42).
#
# Usage: ./validate-cosmos-rpc-endpoint.sh <URL>
# Example: ./validate-cosmos-rpc-endpoint.sh https://rpc.example.com:26657
#
# Validates Cosmos/Tendermint RPC endpoints only (e.g. Hermes rpc_addr).
# Not for EVM or gRPC; use the other tools in tools/ for those.
###############################################################################

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

URL="${1:-}"
TIMEOUT=10
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
PROTOCOL=""
HOST=""
PORT=""
PATH_PART=""
CHAIN_ID=""
LATEST_BLOCK=""
CATCHING_UP=""

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

validate_usage() {
    if [ -z "$URL" ]; then
        echo -e "${RED}Error: URL parameter is required${NC}"
        echo "Usage: $0 <RPC_URL>"
        echo "Example: $0 https://rpc.example.com:26657"
        exit 1
    fi
}

normalize_url() {
    print_header "1. URL Normalization and Validation"
    ORIGINAL_URL="$URL"

    if [[ ! "$URL" =~ ^https?:// ]]; then
        print_info "URL without protocol detected, attempting to normalize..."
        if [[ "$URL" =~ ^([a-zA-Z0-9.-]+)(:([0-9]+))?(/.*)?$ ]]; then
            HOST="${BASH_REMATCH[1]}"
            PORT="${BASH_REMATCH[3]:-}"
            PATH_PART="${BASH_REMATCH[4]:-}"
            [ -z "$PATH_PART" ] && PATH_PART=""
            if [ -z "$PORT" ]; then
                print_info "No port specified, detecting protocol (server will handle redirection)..."
                if command -v curl >/dev/null 2>&1; then
                    if curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 3 "https://$HOST$PATH_PART" >/dev/null 2>&1; then
                        PROTOCOL="https"
                        URL="https://$HOST$PATH_PART"
                        print_success "HTTPS works, using: $URL (no explicit port)"
                    else
                        print_info "HTTPS not available, trying HTTP..."
                        if curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 3 "http://$HOST$PATH_PART" >/dev/null 2>&1; then
                            PROTOCOL="http"
                            URL="http://$HOST$PATH_PART"
                            print_success "HTTP works, using: $URL (no explicit port)"
                        else
                            PROTOCOL="https"
                            URL="https://$HOST$PATH_PART"
                            print_warning "Could not auto-detect, using HTTPS as default: $URL (no explicit port)"
                        fi
                    fi
                else
                    PROTOCOL="https"
                    URL="https://$HOST$PATH_PART"
                    print_info "Using HTTPS as default: $URL (no explicit port)"
                fi
            else
                if [ "$PORT" = "443" ]; then
                    PROTOCOL="https"
                    URL="https://$HOST:$PORT$PATH_PART"
                elif [ "$PORT" = "80" ]; then
                    PROTOCOL="http"
                    URL="http://$HOST:$PORT$PATH_PART"
                else
                    if command -v curl >/dev/null 2>&1; then
                        if curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 3 "https://$HOST:$PORT$PATH_PART" >/dev/null 2>&1; then
                            PROTOCOL="https"
                            URL="https://$HOST:$PORT$PATH_PART"
                            print_success "HTTPS works on port $PORT, using: $URL"
                        else
                            PROTOCOL="http"
                            URL="http://$HOST:$PORT$PATH_PART"
                            print_info "Using HTTP on port $PORT: $URL"
                        fi
                    else
                        PROTOCOL="https"
                        URL="https://$HOST:$PORT$PATH_PART"
                        print_info "Using HTTPS on port $PORT: $URL"
                    fi
                fi
            fi
        else
            print_error "Invalid hostname format: $ORIGINAL_URL"
            exit 1
        fi
    else
        if [[ "$URL" =~ ^(https?)://([^:/]+)(:([0-9]+))?(/.*)?$ ]]; then
            PROTOCOL="${BASH_REMATCH[1]}"
            HOST="${BASH_REMATCH[2]}"
            PORT="${BASH_REMATCH[4]:-}"
            PATH_PART="${BASH_REMATCH[5]:-}"
            [ -z "$PATH_PART" ] && PATH_PART=""
            if [ -n "$PORT" ]; then
                URL="${PROTOCOL}://${HOST}:${PORT}${PATH_PART}"
            else
                URL="${PROTOCOL}://${HOST}${PATH_PART}"
                print_info "No port specified (server will handle redirection)"
            fi
        else
            print_error "Invalid URL format: $ORIGINAL_URL"
            exit 1
        fi
    fi

    [[ "$PATH_PART" != */ ]] && [ -n "$PATH_PART" ] && PATH_PART="${PATH_PART}/"
    [ -n "$PORT" ] && URL="${PROTOCOL}://${HOST}:${PORT}${PATH_PART}" || URL="${PROTOCOL}://${HOST}${PATH_PART}"

    [ -z "$PROTOCOL" ] || [ -z "$HOST" ] && print_error "Error normalizing URL" && exit 1
    print_success "URL normalized: $URL"
    print_info "Protocol: $PROTOCOL | Host: $HOST"
    if [ -n "$PORT" ]; then
        print_info "Port: $PORT"
    else
        print_info "Port: (not specified - server will handle redirection)"
    fi
}

test_dns_resolution() {
    print_header "2. DNS Resolution"
    IP=""
    command -v getent >/dev/null 2>&1 && IP=$(getent hosts "$HOST" 2>/dev/null | awk '{print $1}' | head -n1)
    [ -z "$IP" ] && command -v host >/dev/null 2>&1 && IP=$(host "$HOST" 2>/dev/null | grep -E 'has address|has IPv4' | awk '{print $NF}' | head -n1)
    [ -z "$IP" ] && command -v dig >/dev/null 2>&1 && IP=$(dig +short "$HOST" A 2>/dev/null | head -n1)
    [ -z "$IP" ] && command -v nslookup >/dev/null 2>&1 && IP=$(nslookup "$HOST" 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -n1)

    if [ -n "$IP" ]; then
        print_success "DNS resolved: $HOST -> $IP"
    elif host "$HOST" >/dev/null 2>&1 || nslookup "$HOST" >/dev/null 2>&1; then
        print_success "DNS resolved: $HOST"
    else
        print_error "Could not resolve DNS for: $HOST"
        exit 1
    fi
}

test_network_connectivity() {
    print_header "3. Network Connectivity"
    if [ -z "$PORT" ]; then
        print_info "Port not specified, skipping port connectivity test"
        print_info "Connectivity will be validated via HTTP/HTTPS response (/status)"
        return 0
    fi
    if command -v nc >/dev/null 2>&1; then
        if timeout "$TIMEOUT" nc -z "$HOST" "$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST"
        else
            print_error "Port $PORT not accessible on $HOST"
            exit 1
        fi
    elif command -v timeout >/dev/null 2>&1; then
        if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST"
        else
            print_error "Port $PORT not accessible on $HOST"
            exit 1
        fi
    else
        print_warning "Connectivity tools not available, skipping"
    fi
}

test_tendermint_status() {
    print_header "4. Tendermint RPC (/status)"
    if [[ "$URL" == */ ]]; then
        STATUS_URL="${URL}status"
    else
        STATUS_URL="${URL}/status"
    fi
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is required for this check"
        exit 1
    fi

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$STATUS_URL" 2>/dev/null)
    if [ "$RESPONSE" != "200" ]; then
        print_error "GET /status returned HTTP $RESPONSE (expected 200)"
        exit 1
    fi

    BODY=$(curl -s --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$STATUS_URL" 2>/dev/null)
    if ! echo "$BODY" | grep -q '"result"'; then
        print_error "Response does not look like Tendermint RPC (no result field)"
        exit 1
    fi

    print_success "Tendermint /status responds with valid JSON"

    CHAIN_ID=$(echo "$BODY" | grep -o '"network":"[^"]*"' | head -n1 | sed 's/"network":"\(.*\)"/\1/')
    [ -z "$CHAIN_ID" ] && CHAIN_ID=$(echo "$BODY" | sed -n 's/.*"network"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
    LATEST_BLOCK=$(echo "$BODY" | grep -o '"latest_block_height":"[^"]*"' | head -n1 | sed 's/"latest_block_height":"\(.*\)"/\1/')
    [ -z "$LATEST_BLOCK" ] && LATEST_BLOCK=$(echo "$BODY" | sed -n 's/.*"latest_block_height"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
    CATCHING_UP=$(echo "$BODY" | grep -o '"catching_up":[^,}]*' | head -n1 | sed 's/"catching_up"://')

    if [ -n "$CHAIN_ID" ]; then
        print_success "Chain ID: $CHAIN_ID"
    else
        print_warning "Could not extract chain_id from response"
    fi
    if [ -n "$LATEST_BLOCK" ]; then
        print_info "Latest block height: $LATEST_BLOCK"
    fi
    if [ -n "$CATCHING_UP" ]; then
        print_info "Catching up: $CATCHING_UP"
    fi
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

print_summary() {
    print_header "Validation Summary"
    echo -e "Total tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "\n${GREEN}✓ All validations passed. Cosmos RPC endpoint is suitable for use (e.g. Hermes rpc_addr).${NC}\n"
        print_credits
        exit 0
    else
        echo -e "\n${RED}✗ Some validations failed. Review errors above.${NC}\n"
        print_credits
        exit 1
    fi
}

main() {
    print_header "Starting Cosmos (Tendermint) RPC Endpoint Validation"
    print_info "Target URL: $URL"
    print_info "Timeout: ${TIMEOUT}s"
    validate_usage
    normalize_url
    test_dns_resolution
    test_network_connectivity
    test_tendermint_status
    print_summary
}

main "$@"
