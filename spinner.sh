#!/bin/bash

################################################################################
# Module: Spinner - Loading spinner manager
#
# Description:
#   Provides functions to display a loading spinner with progress messages.
#   Follows Clean Code and Extreme Programming principles.
#   Compatible with macOS (bash 3.2+)
#
# Usage:
#   source spinner.sh
#   spinner_start "Loading message"
#   # … perform a task …
#   spinner_stop true "Success"
#
# Or run directly for demonstration:
#   ./spinner.sh
#
# Author: Thomas Heinis
# Date: 08/01/2026
################################################################################

# ============================================================================
# Configuration - Constants
# ============================================================================

readonly SPINNER_ANIMATION_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
readonly SPINNER_DEFAULT_DELAY=0.08
readonly SPINNER_DEFAULT_MESSAGE='Loading'

# ANSI color codes
readonly COLOR_CYAN='\033[36m'
readonly COLOR_GREEN='\033[32m'
readonly COLOR_RED='\033[31m'
readonly COLOR_YELLOW='\033[33m'
readonly COLOR_RESET='\033[0m'

# Terminal control
readonly CLEAR_LINE='\r\033[K'

# Status symbols
readonly SYMBOL_SUCCESS='✓'
readonly SYMBOL_FAILURE='✗'
readonly SYMBOL_WARNING='⚠'

# ============================================================================
# State Variables
# ============================================================================

SPINNER_PID=""
SPINNER_MESSAGE=""
SPINNER_START_TIME=""
SPINNER_IS_RUNNING="false"
SPINNER_SILENT="${SPINNER_SILENT:-false}"

# ============================================================================
# Utility Functions (Private)
# ============================================================================

_validate_non_empty() {
    local value="$1"
    local param_name="$2"

    if [[ -z "$value" ]]; then
        _log_error "Parameter '$param_name' cannot be empty"
        return 1
    fi
    return 0
}

_validate_delay() {
    local delay="$1"

    if [[ ! "$delay" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        _log_error "Delay must be a positive number, received: '$delay'"
        return 1
    fi
    return 0
}

_log_error() {
    [[ "$SPINNER_SILENT" == "true" ]] && return 0
    local message="$1"
    printf "${COLOR_RED}[ERROR]${COLOR_RESET} %s\n" "$message" >&2
}

_log_warning() {
    [[ "$SPINNER_SILENT" == "true" ]] && return 0
    local message="$1"
    printf "${COLOR_YELLOW}[WARNING]${COLOR_RESET} %s\n" "$message" >&2
}

_log_info() {
    [[ "$SPINNER_SILENT" == "true" ]] && return 0
    local message="$1"
    printf "${COLOR_CYAN}[INFO]${COLOR_RESET} %s\n" "$message"
}

_process_exists() {
    local pid="$1"
    [[ -z "$pid" ]] && return 1
    kill -0 "$pid" 2>/dev/null
}

_is_interactive_terminal() {
    [[ -t 1 ]]
}

# ============================================================================
# Main Functions (Public)
# ============================================================================

##
# Starts a loading spinner
#
# Arguments:
#   $1 - Message to display (optional, default: "Loading")
#   $2 - Delay between frames in seconds (optional, default: 0.08)
#
# Return:
#   0 if success, 1 on error
#
# Example:
#   spinner_start "Downloading…"
##
spinner_start() {
    local message="${1:-$SPINNER_DEFAULT_MESSAGE}"
    local delay="${2:-$SPINNER_DEFAULT_DELAY}"

    # Don’t display if not a TTY (redirected to file)
    if ! _is_interactive_terminal; then
        printf "%s…\n" "$message"
        return 0
    fi

    _validate_non_empty "$message" "message" || return 1
    _validate_delay "$delay" || return 1

    if [[ "$SPINNER_IS_RUNNING" == "true" ]]; then
        _log_warning "A spinner is already running"
        return 1
    fi

    SPINNER_MESSAGE="$message"
    SPINNER_START_TIME=$(date +%s)
    SPINNER_IS_RUNNING="true"

    _spinner_loop "$message" "$delay" &
    SPINNER_PID=$!

    return 0
}

##
# Spinner animation loop (internal function)
##
_spinner_loop() {
    trap 'exit 0' TERM
    
    local message="$1"
    local delay="$2"
    local frame_index=0
    local total_frames=${#SPINNER_ANIMATION_CHARS}

    while true; do
        local current_char="${SPINNER_ANIMATION_CHARS:$frame_index:1}"
        printf "${CLEAR_LINE}${COLOR_CYAN}%s${COLOR_RESET} %s" "$current_char" "$message"
        frame_index=$(( (frame_index + 1) % total_frames ))
        sleep "$delay"
    done
}

##
# Stops the spinner and displays a result message
#
# Arguments:
#   $1 - Success or not (true/false, optional, default: true)
#   $2 - Result message (optional, default: "Done")
#
# Return:
#   0 if success, 1 on error
#
# Example:
#   spinner_stop true "Download complete"
##
spinner_stop() {
    local success="${1:-true}"
    local result_message="${2:-Done}"

    # If not a TTY, simply display the result
    if ! _is_interactive_terminal; then
        if [[ "$success" == "true" ]]; then
            printf "%s %s\n" "$SYMBOL_SUCCESS" "$result_message"
        else
            printf "%s %s\n" "$SYMBOL_FAILURE" "$result_message"
        fi
        return 0
    fi

    _validate_non_empty "$result_message" "result message" || return 1

    if [[ "$SPINNER_IS_RUNNING" != "true" ]]; then
        _log_warning "No spinner is currently running"
        return 1
    fi

    if _process_exists "$SPINNER_PID"; then
        kill "$SPINNER_PID" 2>/dev/null || {
            _log_error "Unable to stop spinner (PID: $SPINNER_PID)"
            return 1
        }
        wait "$SPINNER_PID" 2>/dev/null || true
    fi

    _display_result "$success" "$result_message"

    SPINNER_PID=""
    SPINNER_MESSAGE=""
    SPINNER_START_TIME=""
    SPINNER_IS_RUNNING="false"

    return 0
}

_display_result() {
    local success="$1"
    local message="$2"

    if [[ "$success" == "true" ]]; then
        printf "${CLEAR_LINE}${COLOR_GREEN}%s${COLOR_RESET} %s\n" "$SYMBOL_SUCCESS" "$message"
    else
        printf "${CLEAR_LINE}${COLOR_RED}%s${COLOR_RESET} %s\n" "$SYMBOL_FAILURE" "$message"
    fi
}

##
# Gets the elapsed time since the spinner started
##
spinner_get_elapsed_time() {
    local start_time="$SPINNER_START_TIME"

    if [[ -z "$start_time" ]]; then
        echo "0"
        return 1
    fi

    local current_time
    current_time=$(date +%s)
    echo $((current_time - start_time))
}

##
# Gets the current spinner status
##
spinner_get_status() {
    if [[ "$SPINNER_IS_RUNNING" == "true" ]]; then
        echo "running"
    else
        echo "stopped"
    fi
}

##
# Force stops the spinner (for use by external interrupt handlers)
##
spinner_force_stop() {
    if [[ "$SPINNER_IS_RUNNING" == "true" ]] && [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        printf "${CLEAR_LINE}${COLOR_RED}%s${COLOR_RESET} %s\n" "$SYMBOL_FAILURE" "Interrupted"
        SPINNER_PID=""
        SPINNER_MESSAGE=""
        SPINNER_START_TIME=""
        SPINNER_IS_RUNNING="false"
    fi
}

# ============================================================================
# Signal Handling
# ============================================================================

_cleanup() {
    spinner_force_stop
}

trap _cleanup EXIT

# For INT/TERM: cleanup but don’t exit (unless run directly)
trap '_cleanup; [[ "${BASH_SOURCE[0]}" == "${0}" ]] && exit 130' INT TERM
