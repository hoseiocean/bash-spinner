#!/bin/bash

################################################################################
# Usage Examples - Spinner Module
#
# Description:
#   Demonstrates different use cases of the spinner module with realistic
#   and relevant examples.
#
# Usage:
#   ./spinner_examples.sh        # Interactive mode
#   ./spinner_examples.sh 1      # Run specific example
#
################################################################################

set -euo pipefail

# Source the spinner module (same directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/spinner.sh"

# ============================================================================
# Example 1: Simple Usage
# ============================================================================

example_simple() {
    printf "\n${COLOR_CYAN}═══ Example 1: Simple Usage ═══${COLOR_RESET}\n\n"

    printf "Spinner duration in seconds (default: 2): "
    read -r duration
    duration="${duration:-2}"

    # Validate that it’s a number
    if [[ ! "$duration" =~ ^[0-9]+$ ]]; then
        _log_error "Invalid duration, using 2 seconds"
        duration=2
    fi

    printf "${COLOR_YELLOW}Tip: Ctrl+C to interrupt at any time${COLOR_RESET}\n\n"

    spinner_start "Loading data"
    sleep "$duration"
    spinner_stop true "Data loaded (${duration}s)"
}

# ============================================================================
# Example 2: Error Handling
# ============================================================================

example_error_handling() {
    printf "\n${COLOR_CYAN}═══ Example 2: Error Handling ═══${COLOR_RESET}\n\n"

    spinner_start "Connecting to server"
    sleep 2
    spinner_stop false "Connection failed (timeout)"
}

# ============================================================================
# Example 3: Real Download (curl)
# ============================================================================

example_real_download() {
    printf "\n${COLOR_CYAN}═══ Example 3: Real Download ═══${COLOR_RESET}\n\n"

    local url="https://api.github.com/users/octocat"
    local output_file="/tmp/github_user.json"

    spinner_start "Downloading from GitHub API"
    
    if curl -s -o "$output_file" "$url" 2>/dev/null; then
        local size
        size=$(wc -c < "$output_file" 2>/dev/null | tr -d ' ')
        spinner_stop true "Downloaded (${size} bytes)"
        rm -f "$output_file"
    else
        spinner_stop false "Download failed"
    fi
}

# ============================================================================
# Example 6: Task Loop
# ============================================================================

example_task_loop() {
    printf "\n${COLOR_CYAN}═══ Example 6: Task Loop ═══${COLOR_RESET}\n\n"

    local tasks=("Verification" "Download" "Extraction" "Installation" "Configuration")

    for task in "${tasks[@]}"; do
        spinner_start "${task} in progress"
        sleep 1
        spinner_stop true "${task} complete"
    done
}

# ============================================================================
# Example 5: Reusable Wrapper Function
# ============================================================================

##
# Executes a command with a spinner
#
# Arguments:
#   $1 - Task description
#   $2+ - Command to execute
#
# Return:
#   Command exit code
##
run_with_spinner() {
    local description="$1"
    shift
    local command="$@"

    spinner_start "$description"
    sleep 1  # Minimum delay to see the spinner

    local exit_code=0
    if eval "$command" >/dev/null 2>&1; then
        spinner_stop true "$description - OK"
    else
        exit_code=$?
        spinner_stop false "$description - Error (code: $exit_code)"
    fi
    
    return $exit_code
}

example_wrapper_function() {
    printf "\n${COLOR_CYAN}═══ Example 5: Wrapper Function ═══${COLOR_RESET}\n\n"

    run_with_spinner "Creating directory" "mkdir -p /tmp/spinner_test"
    run_with_spinner "Creating file" "touch /tmp/spinner_test/data.txt"
    run_with_spinner "Writing data" "echo 'Hello World' > /tmp/spinner_test/data.txt"
    run_with_spinner "Reading file" "cat /tmp/spinner_test/data.txt"
    run_with_spinner "Cleanup" "rm -rf /tmp/spinner_test"
}

# ============================================================================
# Example 4: File Processing
# ============================================================================

example_file_processing() {
    printf "\n${COLOR_CYAN}═══ Example 4: File Processing ═══${COLOR_RESET}\n\n"

    spinner_start "Analyzing file system"
    local file_count
    file_count=$(find /tmp -type f 2>/dev/null | wc -l | tr -d ' ')
    sleep 1
    spinner_stop true "Found ${file_count} files in /tmp"

    spinner_start "Searching for large files (>1MB)"
    local big_files
    big_files=$(find /tmp -type f -size +1M 2>/dev/null | wc -l | tr -d ' ')
    sleep 1
    spinner_stop true "Found ${big_files} files > 1MB"
}

# ============================================================================
# Example 7: Deployment Pipeline
# ============================================================================

example_deployment_pipeline() {
    printf "\n${COLOR_CYAN}═══ Example 7: Deployment Pipeline ═══${COLOR_RESET}\n\n"

    local steps=(
        "Checking prerequisites"
        "Pulling latest changes"
        "Installing dependencies"
        "Running tests"
        "Building application"
        "Deploying to production"
    )

    local failed=false

    for step in "${steps[@]}"; do
        spinner_start "$step"
        sleep 1

        # Simulate random failure on tests (1 in 3 chance)
        if [[ "$step" == "Running tests" ]] && (( RANDOM % 3 == 0 )); then
            spinner_stop false "$step - 2 tests failed"
            failed=true
            break
        fi

        spinner_stop true "$step"
    done

    echo ""
    if [[ "$failed" == "true" ]]; then
        printf "${COLOR_RED}Pipeline interrupted${COLOR_RESET}\n"
    else
        printf "${COLOR_GREEN}Deployment successful!${COLOR_RESET}\n"
    fi
}

# ============================================================================
# Main Menu
# ============================================================================

show_menu() {
    printf "\n${COLOR_CYAN}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}\n"
    printf "${COLOR_CYAN}║              Spinner Module - Usage Examples                  ║${COLOR_RESET}\n"
    printf "${COLOR_CYAN}╠═══════════════════════════════════════════════════════════════╣${COLOR_RESET}\n"
    printf "${COLOR_CYAN}║${COLOR_RESET}  1. Simple usage                5. Reusable wrapper           ${COLOR_CYAN}║${COLOR_RESET}\n"
    printf "${COLOR_CYAN}║${COLOR_RESET}  2. Error handling              6. Task loop                  ${COLOR_CYAN}║${COLOR_RESET}\n"
    printf "${COLOR_CYAN}║${COLOR_RESET}  3. Download (curl)             7. Deployment pipeline        ${COLOR_CYAN}║${COLOR_RESET}\n"
    printf "${COLOR_CYAN}║${COLOR_RESET}  4. File processing             q. Quit                       ${COLOR_CYAN}║${COLOR_RESET}\n"
    printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}\n"
}

run_example() {
    local choice="$1"
    
    case "$choice" in
        1) example_simple ;;
        2) example_error_handling ;;
        3) example_real_download ;;
        4) example_file_processing ;;
        5) example_wrapper_function ;;
        6) example_task_loop ;;
        7) example_deployment_pipeline ;;
        q|0)
            printf "\nGoodbye!\n"
            exit 0
            ;;
        *)
            _log_error "Invalid choice: $choice"
            return 1
            ;;
    esac
}

# ============================================================================
# Entry Point
# ============================================================================

# Variable to manage interruption
INTERRUPTED=false

handle_menu_interrupt() {
    INTERRUPTED=true
    spinner_force_stop
}

main() {
    if [[ $# -gt 0 ]]; then
        # Command line mode
        run_example "$1"
    else
        # Interactive mode
        while true; do
            show_menu
            printf "\nYour choice: "
            read -r choice || exit 0
            
            INTERRUPTED=false
            trap 'handle_menu_interrupt' INT
            
            run_example "$choice" || true
            
            trap - INT
            
            if [[ "$INTERRUPTED" == "true" ]]; then
                printf "\n${COLOR_YELLOW}Interrupted - returning to menu${COLOR_RESET}\n"
            fi
        done
    fi
}

main "$@"
