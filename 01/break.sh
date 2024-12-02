#!/usr/bin/env bash

# exit on error, undefined variables, and pipe failures
set -euo pipefail

# constants
readonly DEFAULT_TIME=-1
readonly SECONDS_IN_HOUR=3600
readonly SECONDS_IN_MINUTE=60

# help text
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <minutes>

Take a computer break after the countdown!

Options:
    -h, --help      Show this help message
    -c, --confirm  Show confirmation prompt before locking
    -n, --no-lock   Only show countdown without locking (for testing)
    -v, --verbose   Show debug information

Arguments:
    minutes         Time in minutes until screen lock (required)

Examples:
    $(basename "$0") 30        # Lock screen after 30 minutes
    $(basename "$0") -c 5      # Confirm lock after 5 minutes
    $(basename "$0") -n 1      # Test countdown for 1 minute
EOF
    exit 1
}

# log utility
print_to_stderr() {
    echo "$@" >&2
}

# log utility
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        "DEBUG")
            if [ "$VERBOSE" = true ]; then
                echo "[$timestamp] 🔍 $message" >&2
            fi
            ;;
        "INFO")
            print_to_stderr "[$timestamp] 📌 $message"
            ;;
        "WARN")
            print_to_stderr "[$timestamp] ⚠️ $message"
            ;;
        "ERROR")
            print_to_stderr "[$timestamp] ❌ $message"
            ;;
    esac
}

# math utility
floor() {
    local dividend=$1
    local divisor=$2
    echo $(( (dividend - (dividend % divisor)) / divisor ))
}

# format time for display
format_time() {
    local seconds=$1
    local hours minutes remaining_seconds

    hours=$(floor "$seconds" "$SECONDS_IN_HOUR")
    remaining_seconds=$((seconds - (hours * SECONDS_IN_HOUR)))
    minutes=$(floor "$remaining_seconds" "$SECONDS_IN_MINUTE")
    remaining_seconds=$((remaining_seconds - (minutes * SECONDS_IN_MINUTE)))

    printf "%02dh %02dm %02ds" "$hours" "$minutes" "$remaining_seconds"
}

# countdown display
countdown() {
    local total_seconds=$1
    local remaining_seconds=$total_seconds
    local start_time
    start_time=$(date +%s)

    log "INFO" "Starting countdown for $(format_time "$total_seconds")"

    while ((remaining_seconds >= 0)); do
        printf "Next break in... %s \033[0K\r" "$(format_time "$remaining_seconds")"
        sleep 1
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        remaining_seconds=$((total_seconds - elapsed))
    done
    echo
}

# get the appropriate lock command for the current OS
get_lock_command() {
    case "$OSTYPE" in
        darwin*)
            echo "pmset displaysleepnow"
            ;;
        msys|win32)
            echo "rundll32.exe powrprof.dll, SetSuspendState Sleep"
            ;;
        *)
            log "ERROR" "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
}

# main execution function
run_with_delay() {
    local minutes=$1
    local confirm=${CONFIRM:-false}
    local no_lock=${NO_LOCK:-false}
    local lock_command

    # validate input
    if [[ $minutes -eq -1 ]]; then
        log "ERROR" "Please provide time (in minutes) until next break"
        usage
    fi

    if [[ $minutes -le 0 ]]; then
        log "ERROR" "Time must be a positive number"
        exit 1
    fi

    # get lock command
    lock_command=$(get_lock_command)
    log "DEBUG" "Using lock command: $lock_command"

    # confirm with user if requested
    if [[ "$confirm" == "true" ]]; then
        print_to_stderr -n "Screen will lock in $minutes minutes. Continue? [y/N] "
        read -r confirm_res
        [[ "${confirm_res,,}" != "y" ]] && exit 0
    fi

    # convert minutes to seconds and start countdown
    local total_seconds=$((minutes * SECONDS_IN_MINUTE))
    countdown "$total_seconds"

    # execute lock command
    if [[ "$no_lock" == "false" ]]; then
        log "INFO" "Locking screen now..."
        eval "$lock_command"
    else
        log "INFO" "Lock command skipped (no-lock mode)"
    fi
}

# parse command line arguments
CONFIRM=false
NO_LOCK=false
VERBOSE=false
MINUTES=$DEFAULT_TIME

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -c|--confirm)
            CONFIRM=true
            shift
            ;;
        -n|--no-lock)
            NO_LOCK=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            log "ERROR" "Unknown option: $1"
            usage
            ;;
        *)
            if [[ $MINUTES -ne $DEFAULT_TIME ]]; then
                log "ERROR" "Multiple time values provided"
                usage
            fi
            if [[ $1 =~ ^[0-9]+$ ]]; then
                MINUTES=$1
            else
                log "ERROR" "Invalid time value: $1"
                usage
            fi
            shift
            ;;
    esac
done

# execute main function
run_with_delay "$MINUTES"
