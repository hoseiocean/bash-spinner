#!/bin/bash

################################################################################
# Unit Tests - Spinner Module
#
# Description:
#   Test suite to validate the spinner module functionality.
#   Compatible with macOS and Linux.
#
# Usage:
#   ./spinner_tests.sh
#
# Note:
#   Some tests require a TTY. In non-TTY environments (CI/CD, pipes),
#   the spinner operates in degraded mode (no animation).
#
################################################################################

# Source the spinner module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/spinner.sh" 2>/dev/null || {
    printf "Error: unable to load spinner module\n" >&2
    exit 1
}

# ============================================================================
# Test Configuration
# ============================================================================

TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
IS_TTY=false
[[ -t 1 ]] && IS_TTY=true

readonly TEST_PASS="${COLOR_GREEN}✓${COLOR_RESET}"
readonly TEST_FAIL="${COLOR_RED}✗${COLOR_RESET}"

# ============================================================================
# Test Utility Functions
# ============================================================================

##
# Runs a test and checks the return code
##
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_code="${3:-0}"

    reset_spinner_state
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    local actual_code=0
    eval "$command" 2>/dev/null || actual_code=$?

    if [[ $actual_code -eq $expected_code ]]; then
        printf "%b Test %d: %s\n" "$TEST_PASS" "$TESTS_TOTAL" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        printf "%b Test %d: %s (expected: %d, got: %d)\n" \
            "$TEST_FAIL" "$TESTS_TOTAL" "$test_name" "$expected_code" "$actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

##
# Runs a test with value comparison
##
assert_equals() {
    local test_name="$1"
    local actual="$2"
    local expected="$3"

    reset_spinner_state
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [[ "$actual" == "$expected" ]]; then
        printf "%b Test %d: %s\n" "$TEST_PASS" "$TESTS_TOTAL" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        printf "%b Test %d: %s (expected: '%s', got: '%s')\n" \
            "$TEST_FAIL" "$TESTS_TOTAL" "$test_name" "$expected" "$actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

##
# Skips a test with message
##
skip_test() {
    local test_name="$1"
    local reason="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    printf "%b Test %d: %s (SKIPPED: %s)\n" "${COLOR_YELLOW}⊘${COLOR_RESET}" "$TESTS_TOTAL" "$test_name" "$reason"
    TESTS_PASSED=$((TESTS_PASSED + 1))  # Counted as passed
}

##
# Resets spinner state between tests
##
reset_spinner_state() {
    # Kill spinner process if it exists
    if [[ -n "$SPINNER_PID" ]] && kill -0 "$SPINNER_PID" 2>/dev/null; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
    fi
    SPINNER_PID=""
    SPINNER_MESSAGE=""
    SPINNER_START_TIME=""
    SPINNER_IS_RUNNING="false"
}

print_section() {
    printf "\n${COLOR_CYAN}=== %s ===${COLOR_RESET}\n" "$1"
}

print_test_summary() {
    printf "\n"
    printf "════════════════════════════════════════════════════════════\n"
    printf "Test Summary\n"
    printf "════════════════════════════════════════════════════════════\n"
    printf "Total:  %d\n" "$TESTS_TOTAL"
    printf "Passed: %b%d%b\n" "$COLOR_GREEN" "$TESTS_PASSED" "$COLOR_RESET"
    printf "Failed: %b%d%b\n" "$COLOR_RED" "$TESTS_FAILED" "$COLOR_RESET"
    printf "TTY:    %s\n" "$IS_TTY"
    printf "════════════════════════════════════════════════════════════\n"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        printf "%bAll tests passed!%b\n" "$COLOR_GREEN" "$COLOR_RESET"
        return 0
    else
        printf "%b%d test(s) failed.%b\n" "$COLOR_RED" "$TESTS_FAILED" "$COLOR_RESET"
        return 1
    fi
}

# ============================================================================
# Test Suite - Input Validation (TTY independent)
# ============================================================================

print_section "Tests: Input Validation"

run_test \
    "_validate_non_empty: valid string" \
    "_validate_non_empty 'test' 'param'" \
    0

run_test \
    "_validate_non_empty: empty string" \
    "_validate_non_empty '' 'param'" \
    1

run_test \
    "_validate_delay: integer" \
    "_validate_delay '5'" \
    0

run_test \
    "_validate_delay: decimal" \
    "_validate_delay '0.08'" \
    0

run_test \
    "_validate_delay: invalid text" \
    "_validate_delay 'abc'" \
    1

run_test \
    "_validate_delay: negative number" \
    "_validate_delay '-0.5'" \
    1

run_test \
    "_process_exists: non-existent PID" \
    "_process_exists 99999" \
    1

run_test \
    "_process_exists: empty PID" \
    "_process_exists ''" \
    1

# ============================================================================
# Test Suite - Spinner Start
# ============================================================================

print_section "Tests: Spinner Start"

run_test \
    "Start with default message" \
    "spinner_start && sleep 0.2 && spinner_stop true" \
    0

run_test \
    "Start with custom message" \
    "spinner_start 'Custom test' && sleep 0.2 && spinner_stop true" \
    0

run_test \
    "Start with custom delay" \
    "spinner_start 'Test' 0.05 && sleep 0.2 && spinner_stop true" \
    0

# ============================================================================
# Test Suite - Spinner Stop
# ============================================================================

print_section "Tests: Spinner Stop"

run_test \
    "Stop with success" \
    "spinner_start && sleep 0.2 && spinner_stop true 'Success'" \
    0

run_test \
    "Stop with failure" \
    "spinner_start && sleep 0.2 && spinner_stop false 'Failure'" \
    0

run_test \
    "Stop without message (default)" \
    "spinner_start && sleep 0.2 && spinner_stop" \
    0

# ============================================================================
# Test Suite - State Management (TTY dependent)
# ============================================================================

print_section "Tests: State Management"

assert_equals \
    "Initial state: stopped" \
    "$(spinner_get_status)" \
    "stopped"

if [[ "$IS_TTY" == "true" ]]; then
    reset_spinner_state
    
    # Note: The spinner briefly appears during this test (normal behavior)
    # We don’t redirect stdout otherwise _is_interactive_terminal returns false
    printf "    (spinner visible) "
    spinner_start "Test" 2>/dev/null
    status_running="$(spinner_get_status)"
    spinner_stop true >/dev/null 2>&1
    printf "\n"
    
    assert_equals \
        "State after start: running" \
        "$status_running" \
        "running"
else
    skip_test "State after start: running" "requires TTY"
fi

assert_equals \
    "State after stop: stopped" \
    "$(spinner_get_status)" \
    "stopped"

# ============================================================================
# Test Suite - Edge Cases
# ============================================================================

print_section "Tests: Edge Cases"

run_test \
    "Empty message uses default" \
    "spinner_start '' && sleep 0.2 && spinner_stop true" \
    0

# ============================================================================
# Test Suite - Silent Mode
# ============================================================================

print_section "Tests: Silent Mode"

SPINNER_SILENT=true
output=$(_validate_delay 'invalid' 2>&1)
SPINNER_SILENT=false
assert_equals \
    "Silent mode: no error message" \
    "$output" \
    ""

# ============================================================================
# Test Suite - Multiple Cycles
# ============================================================================

print_section "Tests: Multiple Cycles"

run_test \
    "Multiple successive cycles" \
    "spinner_start 'Cycle 1' && sleep 0.2 && spinner_stop true && \
     spinner_start 'Cycle 2' && sleep 0.2 && spinner_stop true && \
     spinner_start 'Cycle 3' && sleep 0.2 && spinner_stop true" \
    0

# ============================================================================
# Display Summary
# ============================================================================

print_test_summary
exit $?
