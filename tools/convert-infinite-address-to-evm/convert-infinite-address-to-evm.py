#!/usr/bin/env python3
#
# Convert an Infinite (Bech32) account address to EVM (0x...) format.
#
# Copyright 2025, Deep Thought Labs. https://deep-thought.computer
# This file is part of the Infinite Drive ecosystem (Project 42).
#
# Usage:
#   python3 convert-infinite-address-to-evm.py <infinite_address>
#   echo "infinite1..." | python3 convert-infinite-address-to-evm.py
#
# Requires: pip install bech32

import sys

try:
    import bech32
except ImportError:
    print("Error: the 'bech32' package is required. Install with: pip install bech32", file=sys.stderr)
    sys.exit(1)

BECH32_HRP_INFINITE = "infinite"
EXPECTED_ACCOUNT_BYTES = 20


def bech32_to_evm(bech32_addr: str) -> str:
    """Decode a Bech32 address (e.g. infinite1...) to EVM hex (0x...)."""
    addr = bech32_addr.strip()
    if not addr:
        raise ValueError("Empty address")

    hrp, data_5bit = bech32.bech32_decode(addr)
    if hrp is None or data_5bit is None:
        raise ValueError("Invalid Bech32 address")

    data_8bit = bech32.convertbits(data_5bit, 5, 8, False)
    if data_8bit is None:
        raise ValueError("Invalid Bech32 data")

    raw = bytes(data_8bit)
    if len(raw) != EXPECTED_ACCOUNT_BYTES:
        raise ValueError(
            f"Address decodes to {len(raw)} bytes; expected {EXPECTED_ACCOUNT_BYTES} for an account address"
        )

    return "0x" + raw.hex()


def main() -> None:
    if len(sys.argv) > 1:
        addr = sys.argv[1]
    else:
        addr = sys.stdin.read().strip()
        if not addr:
            print("Usage: convert-infinite-address-to-evm.py <infinite_address>", file=sys.stderr)
            print("   or: echo 'infinite1...' | convert-infinite-address-to-evm.py", file=sys.stderr)
            sys.exit(1)

    try:
        evm_hex = bech32_to_evm(addr)
        print(evm_hex)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
