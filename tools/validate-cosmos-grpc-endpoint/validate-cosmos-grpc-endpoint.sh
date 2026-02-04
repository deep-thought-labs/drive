#!/bin/bash

###############################################################################
# Cosmos gRPC Endpoint Validation Script
#
# Copyright 2025, Deep Thought Labs. https://deep-thought.computer
# This file is part of the Infinite Drive ecosystem (Project 42).
#
# Usage: ./validate-cosmos-grpc-endpoint.sh <URL_or_host:port>
# Example: ./validate-cosmos-grpc-endpoint.sh https://grpc.example.com:9090
#
# Validates Cosmos gRPC endpoints only (e.g. Hermes grpc_addr).
# Not for Tendermint RPC or EVM; use the other tools in tools/ for those.
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
HOST=""
PORT=""
PROTOCOL=""

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
        echo -e "${RED}Error: URL or host:port is required${NC}"
        echo "Usage: $0 <GRPC_URL_or_host:port>"
        echo "Example: $0 https://grpc.example.com:9090"
        echo "Example: $0 grpc.example.com:9090"
        exit 1
    fi
}

normalize_url() {
    print_header "1. URL / Host:Port Normalization"
    ORIGINAL="$URL"

    if [[ "$URL" =~ ^https?:// ]]; then
        if [[ "$URL" =~ ^(https?)://([^:/]+)(:([0-9]+))? ]]; then
            PROTOCOL="${BASH_REMATCH[1]}"
            HOST="${BASH_REMATCH[2]}"
            PORT="${BASH_REMATCH[4]:-}"
        else
            print_error "Invalid URL format: $ORIGINAL"
            exit 1
        fi
        if [ -z "$PORT" ]; then
            print_info "No port specified (server will handle redirection, e.g. HTTPS on 443)"
        fi
    else
        if [[ "$URL" =~ ^([a-zA-Z0-9.-]+)(:([0-9]+))?$ ]]; then
            HOST="${BASH_REMATCH[1]}"
            PORT="${BASH_REMATCH[3]:-}"
            if [ -z "$PORT" ]; then
                print_info "No port specified, detecting protocol..."
                if command -v curl >/dev/null 2>&1; then
                    if curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 3 "https://$HOST" >/dev/null 2>&1; then
                        PROTOCOL="https"
                        print_success "HTTPS works, using $HOST (no explicit port)"
                    else
                        PROTOCOL="http"
                        print_info "Using HTTP (no explicit port)"
                    fi
                else
                    PROTOCOL="https"
                    print_info "Using HTTPS as default (no explicit port)"
                fi
            else
                [ "$PORT" = "443" ] && PROTOCOL="https" || PROTOCOL="http"
            fi
        else
            print_error "Invalid host:port format: $ORIGINAL"
            exit 1
        fi
    fi

    print_success "Endpoint: $HOST${PORT:+:$PORT}"
    print_info "Host: $HOST"
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

test_grpc_connectivity() {
    print_header "3. gRPC Port Connectivity"
    if [ -z "$PORT" ]; then
        print_info "Port not specified, skipping port connectivity test"
        print_info "gRPC check will use protocol default (e.g. 443 for HTTPS) if applicable"
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
        print_warning "nc or bash /dev/tcp not available, skipping connectivity check"
    fi
}

###############################################################################
# SSL certificate validation (if HTTPS)
###############################################################################

test_ssl_certificate() {
    if [ "$PROTOCOL" != "https" ]; then
        print_header "4. SSL Certificate Validation"
        print_info "Protocol is not HTTPS, skipping SSL validation"
        return 0
    fi
    print_header "4. SSL Certificate Validation"
    if ! command -v openssl >/dev/null 2>&1; then
        print_warning "OpenSSL not available, skipping certificate validation"
        return 0
    fi
    # PORT is never given a default; for this probe only we connect to 443 when PORT is empty (HTTPS default).
    if [ -n "$PORT" ]; then
        CONNECT_STRING="$HOST:$PORT"
    else
        CONNECT_STRING="$HOST:443"
    fi
    SSL_OUTPUT=$(echo | timeout "$TIMEOUT" openssl s_client -connect "$CONNECT_STRING" -servername "$HOST" 2>&1)
    SSL_EXIT_CODE=$?
    if [ "$SSL_EXIT_CODE" -ne 0 ]; then
        if command -v curl >/dev/null 2>&1 && curl -s -o /dev/null -w "%{http_code}" --max-time 3 "https://$HOST${PORT:+:$PORT}" >/dev/null 2>&1; then
            print_warning "Could not validate certificate with OpenSSL, but HTTPS connection works"
        else
            print_error "Could not validate SSL certificate"
        fi
        return 0
    fi
    CERT_INFO=$(echo "$SSL_OUTPUT" | openssl x509 -noout -dates -subject -issuer 2>/dev/null)
    if [ -z "$CERT_INFO" ]; then
        if command -v curl >/dev/null 2>&1 && curl -s -o /dev/null -w "%{http_code}" --max-time 3 "https://$HOST${PORT:+:$PORT}" >/dev/null 2>&1; then
            print_warning "SSL certificate present but could not extract detailed information"
            print_info "HTTPS connection works correctly"
        else
            print_error "Could not validate SSL certificate"
        fi
        return 0
    fi
    print_success "SSL certificate valid and accessible"
    EXPIRY=$(echo "$SSL_OUTPUT" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        EXPIRY_EPOCH=""
        if date -d "$EXPIRY" +%s >/dev/null 2>&1; then
            EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
        elif date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s >/dev/null 2>&1; then
            EXPIRY_EPOCH=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s)
        fi
        if [ -n "$EXPIRY_EPOCH" ]; then
            NOW_EPOCH=$(date +%s)
            DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
            if [ "$DAYS_LEFT" -gt 30 ]; then
                print_success "Certificate valid for $DAYS_LEFT more days"
            elif [ "$DAYS_LEFT" -gt 0 ]; then
                print_warning "Certificate expires in $DAYS_LEFT days"
            else
                print_error "Certificate expired"
            fi
        fi
    fi
}

###############################################################################
# gRPC service list and optional HTTP-based checks (CORS / Security headers)
###############################################################################

test_grpc_services() {
    print_header "5. gRPC Service Check (optional)"
    if ! command -v grpcurl >/dev/null 2>&1; then
        print_warning "grpcurl not installed; skipping gRPC service list"
        return 0
    fi

    # When no port was specified, PORT stays empty (we never assign a default to PORT).
    # For this optional probe only we use a local GRPC_PORT to attempt connection (443 or 9090); the endpoint URL is not changed.
    GRPC_PORT="$PORT"
    if [ -z "$GRPC_PORT" ]; then
        if [ "$PROTOCOL" = "https" ]; then
            GRPC_PORT="443"
            print_info "No port in URL; probe will try gRPC over TLS on 443 for this check only (endpoint remains without port)"
        else
            GRPC_PORT="9090"
            print_info "No port in URL; probe will try gRPC plaintext on 9090 for this check only (endpoint remains without port)"
        fi
    fi

    # Try plaintext first (common for Cosmos gRPC on 9090)
    if grpcurl -plaintext -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | head -n1 | grep -q .; then
        print_success "gRPC server responds (plaintext); services listed"
        grpcurl -plaintext -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | while read -r svc; do
            [ -n "$svc" ] && print_info "  $svc"
        done
        return 0
    fi

    # Try TLS (no client cert)
    if grpcurl -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | head -n1 | grep -q .; then
        print_success "gRPC server responds (TLS); services listed"
        grpcurl -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | while read -r svc; do
            [ -n "$svc" ] && print_info "  $svc"
        done
        return 0
    fi

    if [ -z "$PORT" ]; then
        print_warning "grpcurl could not list services on $HOST:$GRPC_PORT; endpoint may still work for Hermes if served elsewhere"
    else
        print_warning "Port is open but grpcurl could not list services (may be TLS or different protocol); endpoint may still work for Hermes"
    fi
}

###############################################################################
# CORS and Security headers (best-effort: only when endpoint responds to HTTP)
###############################################################################

build_http_check_url() {
    if [ -n "$PORT" ]; then
        echo "${PROTOCOL}://${HOST}:${PORT}"
    else
        echo "${PROTOCOL}://${HOST}"
    fi
}

test_cors_headers() {
    print_header "6. CORS Headers (optional, if HTTP endpoint responds)"
    if ! command -v curl >/dev/null 2>&1; then
        print_warning "curl not available, skipping CORS check"
        return 0
    fi
    CHECK_URL=$(build_http_check_url)
    OPTIONS_RESPONSE=$(curl -s -I -X OPTIONS --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" \
        -H "Origin: https://example.com" \
        -H "Access-Control-Request-Method: POST" \
        -H "Access-Control-Request-Headers: content-type" \
        "$CHECK_URL" 2>/dev/null)
    POST_RESPONSE=$(curl -s -I -X POST --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" \
        -H "Origin: https://example.com" -H "Content-Type: application/json" \
        "$CHECK_URL" 2>/dev/null)
    ALL_HEADERS=$(echo -e "${OPTIONS_RESPONSE}\n${POST_RESPONSE}")
    if ! echo "$ALL_HEADERS" | grep -qi "HTTP/"; then
        print_info "Endpoint does not respond to HTTP OPTIONS/POST (gRPC-only); CORS not applicable"
        return 0
    fi
    CORS_HEADERS=$(echo "$ALL_HEADERS" | grep -i "access-control" || echo "")
    if [ -z "$CORS_HEADERS" ]; then
        print_warning "HTTP endpoint responded but no CORS headers detected"
        return 0
    fi
    print_success "CORS headers detected"
    ACCESS_CONTROL_ORIGIN=$(echo "$ALL_HEADERS" | grep -i "access-control-allow-origin" | head -n1 || echo "")
    if [ -n "$ACCESS_CONTROL_ORIGIN" ]; then
        ORIGIN_VALUE=$(echo "$ACCESS_CONTROL_ORIGIN" | sed 's/.*:[[:space:]]*//' | tr -d '\r\n' | sed 's/[[:space:]]*$//' | head -c 200)
        print_info "  Access-Control-Allow-Origin: $ORIGIN_VALUE"
    fi
    echo "$CORS_HEADERS" | while read -r line; do
        [ -n "$line" ] && print_info "  $line"
    done
}

test_security_headers() {
    print_header "7. Security Headers (optional, if HTTP endpoint responds)"
    if ! command -v curl >/dev/null 2>&1; then
        print_warning "curl not available, skipping security headers check"
        return 0
    fi
    CHECK_URL=$(build_http_check_url)
    HEADERS=$(curl -s -I --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$CHECK_URL" 2>/dev/null)
    if ! echo "$HEADERS" | grep -qi "HTTP/"; then
        print_info "Endpoint does not respond to HTTP (gRPC-only); security headers not applicable"
        return 0
    fi
    SECURITY_HEADERS=("X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Strict-Transport-Security")
    FOUND_HEADERS=0
    for HEADER in "${SECURITY_HEADERS[@]}"; do
        if echo "$HEADERS" | grep -qi "$HEADER"; then
            ((FOUND_HEADERS++)) || true
        fi
    done
    if [ "$FOUND_HEADERS" -gt 0 ]; then
        print_success "Found $FOUND_HEADERS security headers"
    else
        print_warning "No security headers detected (recommended for production if serving HTTP)"
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
        echo -e "\n${GREEN}✓ All validations passed. Cosmos gRPC endpoint is suitable for use (e.g. Hermes grpc_addr).${NC}\n"
        print_credits
        exit 0
    else
        echo -e "\n${RED}✗ Some validations failed. Review errors above.${NC}\n"
        print_credits
        exit 1
    fi
}

main() {
    print_header "Starting Cosmos gRPC Endpoint Validation"
    print_info "Target: $URL"
    print_info "Timeout: ${TIMEOUT}s"
    validate_usage
    normalize_url
    test_dns_resolution
    test_grpc_connectivity
    test_ssl_certificate
    test_grpc_services
    test_cors_headers
    test_security_headers
    print_summary
}

main "$@"
