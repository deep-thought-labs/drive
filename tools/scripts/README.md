# Shared scripts for endpoint validators

This directory holds **shared code** used by the endpoint validation tools in `../validate-*`. Sourcing a common script keeps behavior and output consistent across validators.

## `endpoint-validation-common.sh`

Centralises **shared endpoint-handling practices** so validators only implement logic specific to their endpoint type (gRPC, RPC, EVM).

### Provided symbols

- **Colors** — `RED`, `GREEN`, `YELLOW`, `BLUE`, `NC` for terminal output.
- **Print helpers** — `print_header`, `print_success`, `print_error`, `print_warning`, `print_info` (they update `PASSED_TESTS`, `FAILED_TESTS`, `TOTAL_TESTS` when used by validators).
- **DNS** — `resolve_dns <host>` (sets `RESOLVED_IP`, return 0/1); `test_dns_resolution` (uses global `HOST`, prints result, exits 1 on failure if DNS tools are available).
- **Credits** — `print_credits` for the shared footer.

### Endpoint / protocol helpers

- **`url_has_scheme <url>`** — Returns 0 if `url` starts with `https://` or `http://`, 1 otherwise. Use to set `USER_SPECIFIED_PROTOCOL` (1 when user passed a scheme, 0 when only hostname).
- **`protocol_default_port <protocol>`** — Echoes the default port for the protocol (`https` → 443, `http` → 80). Use when the user specified a protocol but no port, so the probe uses only that default.
- **`step_timer_start`** — Sets `ENDPOINT_STEP_START` to the current time. Call at the start of a step.
- **`step_timer_elapsed <step_number> [suffix]`** — Prints “Step N completed in Xs” (and optional suffix) using `ENDPOINT_STEP_START`. Call at the end of a step for consistent timing across validators.
- **`print_incomplete_validation_hint <step_desc> [host] [port_examples] [intro_line]`** — Standard warning when a step was skipped because no protocol or port was specified. If `intro_line` is set, prints it and bullet lines (protocol/port); otherwise prints the summary-style block. Use in the skipped step and in the final summary.

### Usage

Each validator sources the script at the top:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../scripts/endpoint-validation-common.sh"
```

Before calling `test_dns_resolution`, the validator must set `HOST`, and optionally `PASSED_TESTS`, `FAILED_TESTS`, `TOTAL_TESTS` (usually to 0).

Validators that support “no protocol / no port” (e.g. gRPC) should set `USER_SPECIFIED_PROTOCOL` from `url_has_scheme "$ORIGINAL_URL"` and use `protocol_default_port` and `print_incomplete_validation_hint` so behaviour stays consistent. Any validator can use `step_timer_start` and `step_timer_elapsed` to report step duration.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.** Part of the **Infinite Drive** ecosystem (**Project 42**).
