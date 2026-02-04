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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/endpoint-validation-common.sh
. "${SCRIPT_DIR}/../scripts/endpoint-validation-common.sh"

URL="${1:-}"
TIMEOUT=10
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
HOST=""
PORT=""
PROTOCOL=""
# 1 if user passed URL with scheme (https:// or http://), 0 if only hostname (we may have inferred protocol)
USER_SPECIFIED_PROTOCOL=0

# Endpoint information from gRPC (GetNodeInfo + GetLatestBlock), shown in summary to confirm we reached the right chain
GRPC_CHAIN_ID=""
GRPC_NODE_VERSION=""
GRPC_APP_NAME=""
GRPC_LATEST_HEIGHT=""
GRPC_LATEST_BLOCK_TIME=""
# Set to 1 when step 5 was skipped because user specified no protocol and no port
GRPC_STEP_SKIPPED_NO_PROTOCOL_PORT=0

# Print install instructions for grpcurl (macOS and Ubuntu) when the tool is missing.
print_grpcurl_install_hint() {
    echo -e "${YELLOW}  To install grpcurl:${NC}"
    echo -e "  ${BLUE}macOS (Homebrew):${NC}  brew install grpcurl"
    echo -e "  ${BLUE}Ubuntu / Debian:${NC}  sudo snap install grpcurl"
    echo -e "  ${BLUE}  (if not on stable):${NC} sudo snap install --edge grpcurl"
    echo -e "  ${BLUE}  (or with Go):${NC}   go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest"
    echo -e "  ${BLUE}  (then add to PATH):${NC} export PATH=\"\$PATH:\$HOME/go/bin\""
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
    url_has_scheme "$ORIGINAL" && USER_SPECIFIED_PROTOCOL=1 || USER_SPECIFIED_PROTOCOL=0

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

test_grpc_connectivity() {
    print_header "3. gRPC Port Connectivity"
    if [ -z "$PORT" ]; then
        print_info "Port not specified, skipping port connectivity test"
        print_info "gRPC check will use protocol default (e.g. 443 for HTTPS) if applicable"
        return 0
    fi

    # Prefer grpcurl when available: it validates real gRPC (HTTP/2) and is what Hermes uses.
    # Raw TCP (nc) can fail on some networks/firewalls even when gRPC works.
    if command -v grpcurl >/dev/null 2>&1; then
        if grpcurl -plaintext -connect-timeout "$TIMEOUT" "$HOST:$PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC reachable on $HOST:$PORT (plaintext; grpcurl list OK)"
            return 0
        fi
        if grpcurl -connect-timeout "$TIMEOUT" "$HOST:$PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC reachable on $HOST:$PORT (TLS; grpcurl list OK)"
            return 0
        fi
        if grpcurl -insecure -connect-timeout "$TIMEOUT" "$HOST:$PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC reachable on $HOST:$PORT (TLS, -insecure; grpcurl list OK)"
            print_warning "Certificate verification was skipped (-insecure); ensure the endpoint is trusted"
            return 0
        fi
        print_error "grpcurl could not reach gRPC on $HOST:$PORT (plaintext or TLS)"
        exit 1
    fi

    # Fallback: raw TCP when grpcurl is not installed (nc or bash /dev/tcp).
    if command -v nc >/dev/null 2>&1; then
        if timeout "$TIMEOUT" nc -z "$HOST" "$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST (TCP; install grpcurl for real gRPC check)"
        else
            print_error "Port $PORT not accessible on $HOST"
            print_info "TCP probe may fail where gRPC works; install grpcurl for a proper gRPC check:"
            print_grpcurl_install_hint
            exit 1
        fi
    elif command -v timeout >/dev/null 2>&1; then
        if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST (TCP; install grpcurl for real gRPC check)"
        else
            print_error "Port $PORT not accessible on $HOST"
            print_info "Install grpcurl for a proper gRPC check:"
            print_grpcurl_install_hint
            exit 1
        fi
    else
        print_warning "grpcurl, nc, and bash /dev/tcp not available; skipping connectivity check"
        print_info "Install grpcurl to validate gRPC endpoints:"
        print_grpcurl_install_hint
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
    step_timer_start
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
        step_timer_elapsed 4
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
        step_timer_elapsed 4
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
    step_timer_elapsed 4
}

###############################################################################
# Fetch chain/node info from gRPC (GetNodeInfo) for summary display
###############################################################################

fetch_grpc_node_info() {
    local mode="$1"
    local grpc_host="$2"
    local grpc_port="$3"
    local node_info=""
    if [ "$mode" = "plaintext" ]; then
        node_info=$(grpcurl -plaintext -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetNodeInfo 2>/dev/null)
    elif [ "$mode" = "tls_insecure" ]; then
        node_info=$(grpcurl -insecure -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetNodeInfo 2>/dev/null)
    else
        node_info=$(grpcurl -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetNodeInfo 2>/dev/null)
    fi
    [ -z "$node_info" ] && return 0
    # Parse JSON without jq: network (chain_id), version (tendermint/comet), application name
    GRPC_CHAIN_ID=$(echo "$node_info" | tr -d '\n' | sed -n 's/.*"network"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    GRPC_NODE_VERSION=$(echo "$node_info" | tr -d '\n' | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    # application_version.name is usually the app binary (e.g. infinited); may appear after "application_version"
    GRPC_APP_NAME=$(echo "$node_info" | tr -d '\n' | sed -n 's/.*"application_version"[^}]*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$GRPC_APP_NAME" ] && GRPC_APP_NAME=$(echo "$node_info" | tr -d '\n' | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | tail -1 | sed 's/.*"\([^"]*\)"$/\1/')

    # Get latest block height and time (GetLatestBlock)
    local block_json=""
    if [ "$mode" = "plaintext" ]; then
        block_json=$(grpcurl -plaintext -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetLatestBlock 2>/dev/null)
    elif [ "$mode" = "tls_insecure" ]; then
        block_json=$(grpcurl -insecure -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetLatestBlock 2>/dev/null)
    else
        block_json=$(grpcurl -connect-timeout "$TIMEOUT" "$grpc_host:$grpc_port" cosmos.base.tendermint.v1beta1.Service/GetLatestBlock 2>/dev/null)
    fi
    if [ -n "$block_json" ]; then
        GRPC_LATEST_HEIGHT=$(echo "$block_json" | tr -d '\n' | sed -n 's/.*"height"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
        [ -z "$GRPC_LATEST_HEIGHT" ] && GRPC_LATEST_HEIGHT=$(echo "$block_json" | tr -d '\n' | grep -o '"height":"[^"]*"' | head -1 | sed 's/"height":"\(.*\)"/\1/')
        [ -z "$GRPC_LATEST_HEIGHT" ] && GRPC_LATEST_HEIGHT=$(echo "$block_json" | tr -d '\n' | sed -n 's/.*"height"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)
        GRPC_LATEST_BLOCK_TIME=$(echo "$block_json" | tr -d '\n' | sed -n 's/.*"time"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
        [ -z "$GRPC_LATEST_BLOCK_TIME" ] && GRPC_LATEST_BLOCK_TIME=$(echo "$block_json" | tr -d '\n' | grep -o '"time":"[^"]*"' | head -1 | sed 's/"time":"\(.*\)"/\1/')
    fi
}

###############################################################################
# gRPC service list and optional HTTP-based checks (CORS / Security headers)
###############################################################################

test_grpc_services() {
    print_header "5. gRPC Service Check (optional)"
    if ! command -v grpcurl >/dev/null 2>&1; then
        print_warning "grpcurl not installed; skipping gRPC service list"
        print_info "Install grpcurl to list gRPC services:"
        print_grpcurl_install_hint
        return 0
    fi

    # When no port is specified we do not impose one. We only use a protocol default (443/80) for the probe when
    # the user explicitly passed a scheme (https:// or http://); then the default is that scheme's standard port.
    # When the user passed only hostname (no protocol, no port), we do not assume a port and skip the probe.
    PORTS_TO_TRY=""
    if [ -n "$PORT" ]; then
        PORTS_TO_TRY="$PORT"
    else
        if [ "$USER_SPECIFIED_PROTOCOL" -eq 1 ]; then
            PORTS_TO_TRY=$(protocol_default_port "$PROTOCOL")
            print_info "No port in URL; probe will use protocol default $PORTS_TO_TRY for this check only (endpoint remains without port; server handles redirection)"
            [ -z "$PORTS_TO_TRY" ] && print_info "No port in URL; skipping gRPC service probe (endpoint remains without port)" && return 0
        else
            print_info "No port or protocol specified; skipping only this step (gRPC list/GetNodeInfo) so we do not assume a port. Endpoint remains as given; server handles redirection. Other steps (DNS, CORS, security headers) still run."
            GRPC_STEP_SKIPPED_NO_PROTOCOL_PORT=1
            print_incomplete_validation_hint "the gRPC service check (step 5)" "$HOST" "${HOST}:443 or ${HOST}:9090" "This run did not perform the full gRPC validation (step 5). For complete validation including chain info, re-run with:"
            return 0
        fi
    fi

    step_timer_start
    for GRPC_PORT in $PORTS_TO_TRY; do
        if [ -z "$PORT" ]; then
            print_info "Trying $HOST:$GRPC_PORT (plaintext)..."
        fi
        # Try plaintext first (common for Cosmos gRPC on 9090)
        if grpcurl -plaintext -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC server responds (plaintext) on $HOST:$GRPC_PORT; services listed"
            grpcurl -plaintext -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | while read -r svc; do
                [ -n "$svc" ] && print_info "  $svc"
            done
            fetch_grpc_node_info "plaintext" "$HOST" "$GRPC_PORT"
            step_timer_elapsed 5
            return 0
        fi

        if [ -z "$PORT" ] && [ "$GRPC_PORT" = "443" ]; then
            print_info "Trying $HOST:443 (TLS)..."
        fi
        # Try TLS (no client cert)
        if grpcurl -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC server responds (TLS) on $HOST:$GRPC_PORT; services listed"
            grpcurl -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | while read -r svc; do
                [ -n "$svc" ] && print_info "  $svc"
            done
            fetch_grpc_node_info "tls" "$HOST" "$GRPC_PORT"
            step_timer_elapsed 5
            return 0
        fi

        if [ -z "$PORT" ] && [ "$GRPC_PORT" = "443" ]; then
            print_info "Trying $HOST:443 (TLS, -insecure)..."
        fi
        # Try TLS with -insecure (e.g. self-signed or cert validation failed)
        if grpcurl -insecure -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | head -n1 | grep -q .; then
            print_success "gRPC server responds (TLS, -insecure) on $HOST:$GRPC_PORT; services listed"
            print_warning "Certificate verification was skipped (-insecure); ensure the endpoint is trusted"
            grpcurl -insecure -connect-timeout "$TIMEOUT" "$HOST:$GRPC_PORT" list 2>/dev/null | while read -r svc; do
                [ -n "$svc" ] && print_info "  $svc"
            done
            fetch_grpc_node_info "tls_insecure" "$HOST" "$GRPC_PORT"
            step_timer_elapsed 5
            return 0
        fi
    done

    step_timer_elapsed 5 " (no gRPC response)"

    if [ -z "$PORT" ]; then
        print_warning "grpcurl could not list services on $HOST (probe used protocol default port); endpoint may still work for Hermes if served elsewhere"
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

print_summary() {
    print_header "Validation Summary"
    echo -e "Total tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

    if [ -n "$GRPC_CHAIN_ID" ] || [ -n "$GRPC_NODE_VERSION" ] || [ -n "$GRPC_APP_NAME" ] || [ -n "$GRPC_LATEST_HEIGHT" ] || [ -n "$GRPC_LATEST_BLOCK_TIME" ]; then
        echo ""
        print_info "Endpoint information (from gRPC GetNodeInfo / GetLatestBlock):"
        [ -n "$GRPC_CHAIN_ID" ]       && print_info "  Chain ID:            $GRPC_CHAIN_ID"
        [ -n "$GRPC_NODE_VERSION" ]   && print_info "  Node version:       $GRPC_NODE_VERSION"
        [ -n "$GRPC_APP_NAME" ]       && print_info "  App name:           $GRPC_APP_NAME"
        [ -n "$GRPC_LATEST_HEIGHT" ]  && print_info "  Latest block height: $GRPC_LATEST_HEIGHT"
        [ -n "$GRPC_LATEST_BLOCK_TIME" ] && print_info "  Latest block time:   $GRPC_LATEST_BLOCK_TIME"
    else
        echo ""
        print_info "Endpoint information could not be retrieved (GetNodeInfo/GetLatestBlock failed or gRPC service check did not succeed)."
    fi

    if [ "${GRPC_STEP_SKIPPED_NO_PROTOCOL_PORT:-0}" -eq 1 ]; then
        echo ""
        print_incomplete_validation_hint "the gRPC service check (step 5)" "$HOST" "${HOST}:443 or ${HOST}:9090"
    fi

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
