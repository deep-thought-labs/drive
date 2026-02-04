#!/bin/bash

###############################################################################
# EVM RPC Endpoint Validation Script
#
# Copyright 2025, Deep Thought Labs. https://deep-thought.computer
# This file is part of the Infinite Drive ecosystem (Project 42).
#
# Usage: ./validate-evm-rpc-endpoint.sh <URL>
# Example: ./validate-evm-rpc-endpoint.sh https://rpc.example.com:8545
#
# Validates EVM (Ethereum) JSON-RPC endpoints only.
# Not for Cosmos Tendermint RPC or gRPC; use the other tools in tools/ for those.
###############################################################################

set -uo pipefail
# Don't use -e to allow error handling in functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/endpoint-validation-common.sh
. "${SCRIPT_DIR}/../common/endpoint-validation-common.sh"

# Variables
URL="${1:-}"
TIMEOUT=10
VERBOSE=false
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
PROTOCOL=""
HOST=""
PORT=""
PATH_PART=""

# Store chain information for display
CHAIN_ID=""
NETWORK_ID=""
BLOCK_NUMBER=""
BLOCK_TIMESTAMP=""
CLIENT_VERSION=""
# 1 if user passed URL with scheme (https:// or http://), 0 if only hostname
USER_SPECIFIED_PROTOCOL=0

###############################################################################
# Parameter validation
###############################################################################

validate_usage() {
    if [ -z "$URL" ]; then
        echo -e "${RED}Error: URL parameter is required${NC}"
        echo "Usage: $0 <URL>"
        echo "Example: $0 https://rpc.example.com:8545"
        exit 1
    fi
}

###############################################################################
# URL normalization
###############################################################################

normalize_url() {
    print_header "1. URL Normalization and Validation"
    ORIGINAL_URL="$URL"
    url_has_scheme "$ORIGINAL_URL" && USER_SPECIFIED_PROTOCOL=1 || USER_SPECIFIED_PROTOCOL=0

    # If URL doesn't have protocol, try to add it
    if [[ ! "$URL" =~ ^https?:// ]]; then
        print_info "URL without protocol detected, attempting to normalize..."
        
        # Extract hostname and port if present
        if [[ "$URL" =~ ^([a-zA-Z0-9.-]+)(:([0-9]+))?(/.*)?$ ]]; then
            HOST="${BASH_REMATCH[1]}"
            PORT="${BASH_REMATCH[3]:-}"
            PATH_PART="${BASH_REMATCH[4]:-}"
            
            # Ensure PATH_PART is defined
            if [ -z "$PATH_PART" ]; then
                PATH_PART=""
            fi
            
            # Try HTTPS first (more common for RPC)
            if [ -z "$PORT" ]; then
                # No port specified, DO NOT add default port
                # Try to detect the correct protocol without specifying port
                print_info "No port specified, detecting protocol (without adding default port)..."
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
                            # Default to HTTPS without port
                            PROTOCOL="https"
                            URL="https://$HOST$PATH_PART"
                            print_warning "Could not auto-detect, using HTTPS as default: $URL (no explicit port)"
                        fi
                    fi
                else
                    # Without curl, use HTTPS as default without port
                    PROTOCOL="https"
                    URL="https://$HOST$PATH_PART"
                    print_info "Using HTTPS as default: $URL (no explicit port)"
                fi
            else
                # Port specified, use HTTPS if 443, HTTP if 80, or try to detect
                if [ "$PORT" = "443" ]; then
                    PROTOCOL="https"
                    URL="https://$HOST:$PORT$PATH_PART"
                    # PORT already set above
                elif [ "$PORT" = "80" ]; then
                    PROTOCOL="http"
                    URL="http://$HOST:$PORT$PATH_PART"
                    # PORT already set above
                else
                    # For other ports, try to detect
                    print_info "Port $PORT specified, attempting to detect protocol..."
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
                        # Without curl, use HTTPS as default for non-standard ports
                        PROTOCOL="https"
                        URL="https://$HOST:$PORT$PATH_PART"
                        print_info "Using HTTPS as default on port $PORT: $URL"
                    fi
                fi
            fi
        else
            print_error "Invalid hostname format: $ORIGINAL_URL"
            exit 1
        fi
    else
        # URL already has protocol, extract components
        if [[ "$URL" =~ ^(https?)://([^:/]+)(:([0-9]+))?(/.*)?$ ]]; then
            PROTOCOL="${BASH_REMATCH[1]}"
            HOST="${BASH_REMATCH[2]}"
            PORT="${BASH_REMATCH[4]:-}"
            PATH_PART="${BASH_REMATCH[5]:-}"
            
            # If no port, DO NOT add a default one
            # Keep PORT empty if not specified
            
            # Ensure PATH_PART is defined
            if [ -z "$PATH_PART" ]; then
                PATH_PART=""
            fi
        else
            print_error "Invalid URL format: $ORIGINAL_URL"
            exit 1
        fi
    fi
    
    # Validate that we have the necessary components (PORT is optional)
    if [ -z "$PROTOCOL" ] || [ -z "$HOST" ]; then
        print_error "Error normalizing URL: $ORIGINAL_URL"
        exit 1
    fi
    
    print_success "URL normalized: $URL"
    print_info "Protocol: $PROTOCOL"
    print_info "Host: $HOST"
    if [ -n "$PORT" ]; then
        print_info "Port: $PORT"
    else
        print_info "Port: (not specified - server will handle redirection)"
    fi
    if [ -n "$PATH_PART" ]; then
        print_info "Path: $PATH_PART"
    fi
}

###############################################################################
# Network connectivity validation
###############################################################################

test_network_connectivity() {
    print_header "3. Network Connectivity"
    
    # If no port specified, skip this test (server will handle redirection)
    if [ -z "$PORT" ]; then
        print_info "Port not specified, skipping port connectivity test"
        print_info "Connectivity will be validated via HTTP/HTTPS response"
        return 0
    fi
    
    # Check if port is open using nc (netcat) or timeout
    if command -v nc >/dev/null 2>&1; then
        print_info "Checking port (timeout ${TIMEOUT}s)..."
        if timeout "$TIMEOUT" nc -z "$HOST" "$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST"
        else
            print_error "Port $PORT not accessible on $HOST"
            exit 1
        fi
    elif command -v timeout >/dev/null 2>&1; then
        print_info "Checking port with /dev/tcp (timeout ${TIMEOUT}s)..."
        if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
            print_success "Port $PORT accessible on $HOST"
        else
            print_error "Port $PORT not accessible on $HOST"
            exit 1
        fi
    else
        print_warning "Connectivity tools not available, skipping test"
    fi
}

###############################################################################
# SSL certificate validation (if HTTPS)
###############################################################################

test_ssl_certificate() {
    if [ "$PROTOCOL" = "https" ]; then
        print_header "4. SSL Certificate Validation"
        step_timer_start
        if command -v openssl >/dev/null 2>&1; then
            # Build connection string based on whether port is present or not
            if [ -n "$PORT" ]; then
                CONNECT_STRING="$HOST:$PORT"
            else
                # No port, use hostname and let openssl use default port (443)
                CONNECT_STRING="$HOST:443"
            fi

            print_info "Checking certificate (timeout ${TIMEOUT}s)..."
            # Get certificate information with better error handling
            SSL_OUTPUT=$(echo | timeout "$TIMEOUT" openssl s_client -connect "$CONNECT_STRING" -servername "$HOST" 2>&1)
            SSL_EXIT_CODE=$?
            
            if [ $SSL_EXIT_CODE -eq 0 ]; then
                CERT_INFO=$(echo "$SSL_OUTPUT" | openssl x509 -noout -dates -subject -issuer 2>/dev/null)
                
                if [ -n "$CERT_INFO" ]; then
                    print_success "SSL certificate valid and accessible"
                    
                    # Check expiration date
                    EXPIRY=$(echo "$SSL_OUTPUT" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
                    if [ -n "$EXPIRY" ]; then
                        # Try to parse date (compatible with Linux and macOS)
                        if date -d "$EXPIRY" +%s >/dev/null 2>&1; then
                            # Linux
                            EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
                        elif date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s >/dev/null 2>&1; then
                            # macOS
                            EXPIRY_EPOCH=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s)
                        else
                            EXPIRY_EPOCH=""
                        fi
                        
                        if [ -n "$EXPIRY_EPOCH" ]; then
                            NOW_EPOCH=$(date +%s)
                            DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
                            if [ $DAYS_LEFT -gt 30 ]; then
                                print_success "Certificate valid for $DAYS_LEFT more days"
                            elif [ $DAYS_LEFT -gt 0 ]; then
                                print_warning "Certificate expires in $DAYS_LEFT days"
                            else
                                print_error "Certificate expired"
                            fi
                        fi
                    fi
                else
                    # If curl can connect but openssl can't, it might be a configuration issue
                    # Verify if at least HTTPS connection works
                    if curl -s -o /dev/null -w "%{http_code}" --max-time 3 "https://$HOST" >/dev/null 2>&1; then
                        print_warning "SSL certificate present but could not extract detailed information"
                        print_info "HTTPS connection works correctly"
                    else
                        print_error "Could not validate SSL certificate"
                    fi
                fi
            else
                # If openssl fails, verify if at least curl can connect
                if curl -s -o /dev/null -w "%{http_code}" --max-time 3 "https://$HOST" >/dev/null 2>&1; then
                    print_warning "Could not validate certificate with OpenSSL, but HTTPS connection works"
                else
                    print_error "Could not validate SSL certificate"
                fi
            fi
        else
            print_warning "OpenSSL not available, skipping certificate validation"
        fi
        step_timer_elapsed 4
    else
        print_info "HTTP protocol (not HTTPS), skipping SSL validation"
    fi
}

###############################################################################
# HTTP/HTTPS response validation
###############################################################################

test_http_response() {
    print_header "5. HTTP/HTTPS Response"
    step_timer_start
    if command -v curl >/dev/null 2>&1; then
        print_info "Requesting $URL (timeout ${TIMEOUT}s)..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$URL" 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" != "000" ]; then
            print_success "Server responds with HTTP code: $HTTP_CODE"
            
            # Verify that the code is valid (not 5xx)
            if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
                print_success "Successful status code (2xx)"
            elif [ "$HTTP_CODE" -ge 300 ] && [ "$HTTP_CODE" -lt 400 ]; then
                print_warning "Redirect detected (3xx)"
            elif [ "$HTTP_CODE" -ge 400 ] && [ "$HTTP_CODE" -lt 500 ]; then
                print_warning "Client error (4xx) - may be normal for RPC without method"
            elif [ "$HTTP_CODE" -ge 500 ]; then
                print_error "Server error (5xx)"
            fi
        else
            print_error "Could not connect to server or timeout"
            exit 1
        fi
        
        # Get headers
        RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$URL" 2>/dev/null || echo "0")
        if [ "$RESPONSE_TIME" != "0" ]; then
            print_info "Response time: ${RESPONSE_TIME}s"
        fi
        step_timer_elapsed 5
    else
        print_warning "curl not available, skipping HTTP test"
    fi
}

###############################################################################
# RPC endpoint validation (JSON-RPC, Ethereum/EVM methods)
###############################################################################

test_rpc_methods() {
    print_header "6. RPC Methods Validation"
    step_timer_start
    if command -v curl >/dev/null 2>&1; then
        print_info "Calling RPC methods (timeout ${TIMEOUT}s per request): web3_clientVersion, eth_blockNumber, net_version, eth_chainId"
        # Test standard Ethereum/EVM JSON-RPC methods
        RPC_METHODS=("web3_clientVersion" "eth_blockNumber" "net_version" "eth_chainId")
        
        for METHOD in "${RPC_METHODS[@]}"; do
            RPC_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "$METHOD",
    "params": [],
    "id": 1
}
EOF
)
            
            RESPONSE=$(curl -s --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" \
                -X POST \
                -H "Content-Type: application/json" \
                -d "$RPC_REQUEST" \
                "$URL" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
                # Check if response contains "result" or "error"
                if echo "$RESPONSE" | grep -q '"result"'; then
                    print_success "RPC method '$METHOD' responds correctly"
                    
                    # Extract result value - handle both quoted strings and hex values
                    # Try to extract quoted string first
                    RESULT_VALUE=$(echo "$RESPONSE" | grep -o '"result":"[^"]*"' | sed 's/"result":"\(.*\)"/\1/' | head -n1)
                    
                    # If empty, try to extract from JSON more carefully
                    if [ -z "$RESULT_VALUE" ]; then
                        # Use a more robust extraction that handles JSON properly
                        RESULT_VALUE=$(echo "$RESPONSE" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p' | head -n1)
                    fi
                    
                    # Store chain information based on method
                    case "$METHOD" in
                        "eth_chainId")
                            if [ -n "$RESULT_VALUE" ]; then
                                CHAIN_ID="$RESULT_VALUE"
                            fi
                            ;;
                        "net_version")
                            if [ -n "$RESULT_VALUE" ]; then
                                NETWORK_ID="$RESULT_VALUE"
                            fi
                            ;;
                        "eth_blockNumber")
                            if [ -n "$RESULT_VALUE" ]; then
                                BLOCK_NUMBER="$RESULT_VALUE"
                            fi
                            ;;
                        "web3_clientVersion")
                            if [ -n "$RESULT_VALUE" ]; then
                                CLIENT_VERSION="$RESULT_VALUE"
                            fi
                            ;;
                    esac
                elif echo "$RESPONSE" | grep -q '"error"'; then
                    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4 || echo "Unknown error")
                    print_warning "RPC method '$METHOD' returns error: $ERROR_MSG"
                else
                    print_warning "RPC method '$METHOD' returns unexpected response"
                fi
            else
                print_error "Could not connect to test RPC method '$METHOD'"
            fi
        done
        
        # Display chain information summary
        if [ -n "$CHAIN_ID" ] || [ -n "$NETWORK_ID" ] || [ -n "$BLOCK_NUMBER" ] || [ -n "$CLIENT_VERSION" ]; then
            echo ""
            print_info "Chain Information:"
            if [ -n "$CHAIN_ID" ]; then
                # Convert hex to decimal if it's a hex value
                if echo "$CHAIN_ID" | grep -qE "^0x[0-9a-fA-F]+$"; then
                    CHAIN_ID_DEC=$(printf "%d" "$CHAIN_ID" 2>/dev/null || echo "N/A")
                    print_info "  Chain ID: $CHAIN_ID (decimal: $CHAIN_ID_DEC)"
                else
                    print_info "  Chain ID: $CHAIN_ID"
                fi
            fi
            if [ -n "$NETWORK_ID" ]; then
                print_info "  Network ID: $NETWORK_ID"
            fi
            if [ -n "$BLOCK_NUMBER" ]; then
                # Convert hex to decimal if it's a hex value
                if echo "$BLOCK_NUMBER" | grep -qE "^0x[0-9a-fA-F]+$"; then
                    BLOCK_NUMBER_DEC=$(printf "%d" "$BLOCK_NUMBER" 2>/dev/null || echo "N/A")
                    print_info "  Current Block: $BLOCK_NUMBER (decimal: $BLOCK_NUMBER_DEC)"
                else
                    print_info "  Current Block: $BLOCK_NUMBER"
                fi
            fi
            if [ -n "$CLIENT_VERSION" ]; then
                print_info "  Client Version: $CLIENT_VERSION"
            fi
        fi

        # Fetch latest block timestamp (eth_getBlockByNumber) for summary
        if [ -n "$BLOCK_NUMBER" ]; then
            BLOCK_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "eth_getBlockByNumber",
    "params": ["latest", false],
    "id": 1
}
EOF
)
            BLOCK_RESPONSE=$(curl -s --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" \
                -X POST -H "Content-Type: application/json" -d "$BLOCK_REQUEST" "$URL" 2>/dev/null)
            if [ -n "$BLOCK_RESPONSE" ] && echo "$BLOCK_RESPONSE" | grep -q '"result"'; then
                TS_HEX=$(echo "$BLOCK_RESPONSE" | grep -o '"timestamp":"0x[0-9a-fA-F]*"' | sed 's/"timestamp":"\(.*\)"/\1/')
                if [ -n "$TS_HEX" ]; then
                    TS_DEC=$(printf "%d" "$TS_HEX" 2>/dev/null)
                    if [ -n "$TS_DEC" ]; then
                        BLOCK_TIMESTAMP=$(date -r "$TS_DEC" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
                        [ -z "$BLOCK_TIMESTAMP" ] && BLOCK_TIMESTAMP=$(date -d "@$TS_DEC" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
                        [ -z "$BLOCK_TIMESTAMP" ] && BLOCK_TIMESTAMP="${TS_DEC} (unix)"
                    fi
                fi
                if [ -n "$BLOCK_TIMESTAMP" ]; then
                    print_info "  Latest block time: $BLOCK_TIMESTAMP"
                fi
            fi
        fi
        step_timer_elapsed 6
    else
        print_warning "curl not available, skipping RPC methods tests"
    fi
}

###############################################################################
# CORS validation (if applicable)
###############################################################################

test_cors_headers() {
    print_header "7. CORS Headers Validation"
    print_info "CORS is CRITICAL for MetaMask and other wallets to work from the browser"
    
    if command -v curl >/dev/null 2>&1; then
        # Make an OPTIONS request (preflight) as the browser would
        OPTIONS_RESPONSE=$(curl -s -I -X OPTIONS \
            --max-time "$TIMEOUT" \
            --connect-timeout "$TIMEOUT" \
            -H "Origin: https://metamask.io" \
            -H "Access-Control-Request-Method: POST" \
            -H "Access-Control-Request-Headers: content-type" \
            "$URL" 2>/dev/null)
        
        # Also check headers in a normal POST request
        POST_RESPONSE=$(curl -s -I -X POST \
            --max-time "$TIMEOUT" \
            --connect-timeout "$TIMEOUT" \
            -H "Origin: https://metamask.io" \
            -H "Content-Type: application/json" \
            "$URL" 2>/dev/null)
        
        # Combine both responses to check headers
        ALL_HEADERS=$(echo -e "$OPTIONS_RESPONSE\n$POST_RESPONSE")
        
        # Check critical CORS headers (take only the first occurrence of each)
        ACCESS_CONTROL_ORIGIN=$(echo "$ALL_HEADERS" | grep -i "access-control-allow-origin" | head -n1 || echo "")
        ACCESS_CONTROL_METHODS=$(echo "$ALL_HEADERS" | grep -i "access-control-allow-methods" | head -n1 || echo "")
        ACCESS_CONTROL_HEADERS=$(echo "$ALL_HEADERS" | grep -i "access-control-allow-headers" | head -n1 || echo "")
        ACCESS_CONTROL_CREDENTIALS=$(echo "$ALL_HEADERS" | grep -i "access-control-allow-credentials" | head -n1 || echo "")
        
        CORS_HEADERS=$(echo "$ALL_HEADERS" | grep -i "access-control" || echo "")
        
        if [ -n "$CORS_HEADERS" ]; then
            print_success "CORS headers detected"
            
            # Check Access-Control-Allow-Origin (most critical)
            if [ -n "$ACCESS_CONTROL_ORIGIN" ]; then
                # Extract value after colon, clean spaces and line breaks
                ORIGIN_VALUE=$(echo "$ACCESS_CONTROL_ORIGIN" | sed 's/.*:[[:space:]]*//' | tr -d '\r\n' | sed 's/[[:space:]]*$//' | head -c 200)
                if [ "$ORIGIN_VALUE" = "*" ]; then
                    print_success "Access-Control-Allow-Origin configured: * (allows all origins)"
                elif echo "$ORIGIN_VALUE" | grep -qE "^https?://"; then
                    print_success "Access-Control-Allow-Origin configured: $ORIGIN_VALUE"
                else
                    print_warning "Access-Control-Allow-Origin with value: $ORIGIN_VALUE"
                fi
            else
                print_error "Access-Control-Allow-Origin NOT configured (CRITICAL for MetaMask)"
                ((FAILED_TESTS++))
                ((TOTAL_TESTS++))
            fi
            
            # Check other important headers
            if [ -n "$ACCESS_CONTROL_METHODS" ]; then
                print_success "Access-Control-Allow-Methods configured"
                print_info "  $ACCESS_CONTROL_METHODS"
            else
                print_warning "Access-Control-Allow-Methods not configured (recommended)"
            fi
            
            if [ -n "$ACCESS_CONTROL_HEADERS" ]; then
                print_success "Access-Control-Allow-Headers configured"
                print_info "  $ACCESS_CONTROL_HEADERS"
            else
                print_warning "Access-Control-Allow-Headers not configured (recommended)"
            fi
            
            # Show all CORS headers found
            echo "$CORS_HEADERS" | while read -r line; do
                if [ -n "$line" ]; then
                    print_info "  $line"
                fi
            done
        else
            print_error "NO CORS headers detected - MetaMask and other wallets will NOT work"
            print_error "Server must configure at least: Access-Control-Allow-Origin"
            print_info "Example of required configuration:"
            print_info "  Access-Control-Allow-Origin: *"
            print_info "  Access-Control-Allow-Methods: POST, OPTIONS"
            print_info "  Access-Control-Allow-Headers: Content-Type"
            ((FAILED_TESTS++))
            ((TOTAL_TESTS++))
        fi
    else
        print_warning "curl not available, skipping CORS test"
    fi
}

###############################################################################
# Security validation
###############################################################################

test_security_headers() {
    print_header "8. Security Headers Validation"
    
    if command -v curl >/dev/null 2>&1; then
        SECURITY_HEADERS=("X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Strict-Transport-Security")
        HEADERS=$(curl -s -I --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$URL" 2>/dev/null)
        
        FOUND_HEADERS=0
        for HEADER in "${SECURITY_HEADERS[@]}"; do
            if echo "$HEADERS" | grep -qi "$HEADER"; then
                ((FOUND_HEADERS++))
            fi
        done
        
        if [ $FOUND_HEADERS -gt 0 ]; then
            print_success "Found $FOUND_HEADERS security headers"
        else
            print_warning "No security headers detected (recommended for production)"
        fi
    else
        print_warning "curl not available, skipping security test"
    fi
}

###############################################################################
# Final summary
###############################################################################

print_summary() {
    print_header "Validation Summary"
    
    echo -e "Total tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed tests: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed tests: ${RED}$FAILED_TESTS${NC}"

    if [ -n "$CHAIN_ID" ] || [ -n "$BLOCK_NUMBER" ] || [ -n "$BLOCK_TIMESTAMP" ] || [ -n "$CLIENT_VERSION" ]; then
        echo ""
        print_info "Endpoint information (from JSON-RPC):"
        if [ -n "$CHAIN_ID" ]; then
            if echo "$CHAIN_ID" | grep -qE "^0x[0-9a-fA-F]+$"; then
                CHAIN_ID_DEC=$(printf "%d" "$CHAIN_ID" 2>/dev/null || echo "N/A")
                print_info "  Chain ID:           $CHAIN_ID (decimal: $CHAIN_ID_DEC)"
            else
                print_info "  Chain ID:           $CHAIN_ID"
            fi
        fi
        if [ -n "$BLOCK_NUMBER" ]; then
            if echo "$BLOCK_NUMBER" | grep -qE "^0x[0-9a-fA-F]+$"; then
                BLOCK_NUMBER_DEC=$(printf "%d" "$BLOCK_NUMBER" 2>/dev/null || echo "N/A")
                print_info "  Latest block height: $BLOCK_NUMBER_DEC"
            else
                print_info "  Latest block height: $BLOCK_NUMBER"
            fi
        fi
        [ -n "$BLOCK_TIMESTAMP" ] && print_info "  Latest block time:   $BLOCK_TIMESTAMP"
        [ -n "$CLIENT_VERSION" ]  && print_info "  Client version:      $CLIENT_VERSION"
    fi
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ All validations passed successfully${NC}"
        echo -e "${GREEN}The RPC endpoint is working correctly${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"
        print_credits
        exit 0
    else
        echo -e "\n${RED}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}✗ Some validations failed${NC}"
        echo -e "${RED}Review the errors above for more details${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════════${NC}\n"
        print_credits
        exit 1
    fi
}

###############################################################################
# Main function
###############################################################################

main() {
    print_header "Starting EVM RPC Endpoint Validation"
    print_info "Target URL: $URL"
    print_info "Timeout: ${TIMEOUT}s"
    
    validate_usage
    normalize_url
    test_dns_resolution
    test_network_connectivity
    test_ssl_certificate
    test_http_response
    test_rpc_methods
    test_cors_headers
    test_security_headers
    print_summary
}

# Execute main function
main "$@"
