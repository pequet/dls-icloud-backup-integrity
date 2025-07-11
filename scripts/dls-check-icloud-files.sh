#!/bin/bash

# Standard Error Handling
set -euo pipefail

# █████  iCloud Backup Integrity
# █  ██  Version: 2.0.0
# █ ███  Author: Benjamin Pequet
# █████  GitHub: https://github.com/pequet/dls-icloud-backup-integrity/
#
# Purpose:
#   This script ensures that all files within a specified directory are fully
#   downloaded from iCloud to the local machine. It does this by reading the
#   first byte of every file, which forces macOS to download any file that
#   is currently only a cloud placeholder. This is critical for ensuring
#   local backup solutions (like Time Machine) can back up all data.
#
# Usage:
#   ./scripts/dls-check-icloud-files.sh [DIRECTORY]
#
#   If DIRECTORY is not provided, the script will check the root of the
#   current Git repository. If not in a Git repository, it defaults to the
#   current working directory.
#
# Changelog:
#   2.0.0 - 2025-07-10 - Rearchitected to force-download files instead of unreliable detection.
#   1.0.0 - 2025-07-10 - Initial release (detection only).
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# --- Global Variables ---
# Resolve the true script directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

TARGET_DIR=""
LOG_FILE_PATH="${SCRIPT_DIR}/../logs/integrity_check.log"

# Source shared utilities
source "${SCRIPT_DIR}/utils/logging_utils.sh"
source "${SCRIPT_DIR}/utils/messaging_utils.sh"

# --- Function Definitions ---

# *
# * Usage and Information
# *
usage() {
  echo "Usage: $0 [DIRECTORY]"
  echo "Ensures all files in a directory are downloaded from iCloud."
  echo
  echo "If DIRECTORY is not provided, it defaults to the Git repository root, or the"
  echo "current directory if not within a Git repository."
}

# *
# * Core Logic
# *
ensure_files_are_local() {
    local scan_path="$1"
    local skip_prompt=false

    # Check for non-interactive flag
    if [ "${2:-}" == "-y" ] || [ "${2:-}" == "--yes" ]; then
        skip_prompt=true
    fi
    
    print_header "DLS iCloud Backup Integrity"
    print_info "Scanning directory: $scan_path"

    # Find all files and count them.
    local file_list
    file_list=$(find "$scan_path" -type f)
    local file_count
    file_count=$(echo "$file_list" | wc -l | tr -d " ")

    if [ "$file_count" -eq 0 ]; then
        print_info "No files found in the specified directory."
        print_footer
        exit 0
    fi

    print_info "Found $file_count total file(s) to check."
    print_info "This script will ensure all of them are available locally."
    print_warning "This may trigger large downloads from iCloud if files are not on this machine."
    
    if $skip_prompt; then
        print_info "Proceeding automatically with --yes flag."
    else
        # Prompt the user to continue.
        read -p "Do you want to proceed? (y/N): " -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled by user."
            print_footer
            exit 0
        fi
    fi
    
    local success_count=0
    local failed_count=0
    while IFS= read -r file; do
        local basename
        basename=$(basename "$file")
        local output
        
        # The 'brctl' command is specific to macOS for checking iCloud status.
        if ! output=$(brctl download "$file" 2>&1); then
            print_status_line "- [DOWNLOAD]" "${basename}" "FAILED"
            print_error_details "brctl download \"$file\"" "$output"
            ((failed_count++))
        else
            print_status_line "- [DOWNLOAD]" "${basename}" "SUCCESS"
            ((success_count++))
        fi
    done <<< "$file_list"
    
    print_separator
    print_completed "Integrity check complete."
    
    local summary_line="Succeeded: ${success_count} | Failed: ${failed_count}"
    print_info "${summary_line}"
    log_message "INFO" "Summary: ${summary_line}"

    print_footer
}

# --- Script Entrypoint ---

main() {
    ensure_log_directory
    log_message "INFO" "=== DLS iCloud Backup Integrity starting ==="

    local directory_arg=""
    local yes_flag_arg=""
    local TARGET_DIR=""

    # Parse arguments
    for arg in "$@"; do
        case $arg in
            -h|--help)
                usage
                exit 0
                ;;
            -y|--yes)
                yes_flag_arg="--yes"
                ;;
            *)
                if [ -n "$directory_arg" ]; then
                    print_error "Error: Too many directory arguments specified."
                    usage
                    exit 1
                fi
                directory_arg="$arg"
                ;;
        esac
    done

    # Determine target directory
    if [[ -n "$directory_arg" ]]; then
        TARGET_DIR="$directory_arg"
    else
        # If no directory is provided, use git root or current dir
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            TARGET_DIR="$(git rev-parse --show-toplevel)"
            log_message "INFO" "No directory specified. Defaulting to Git root: ${TARGET_DIR}"
        else
            TARGET_DIR="$(pwd)"
            log_message "INFO" "No directory specified and not in a Git repository. Defaulting to current directory: ${TARGET_DIR}"
        fi
    fi

    # Check if directory exists before canonicalizing
    if [[ ! -d "$TARGET_DIR" ]]; then
        print_error "Directory not found: $TARGET_DIR"
        usage
        exit 1
    fi

    # Canonicalize path to be absolute
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

    ensure_files_are_local "$TARGET_DIR" "$yes_flag_arg"

    log_message "INFO" "=== DLS iCloud Backup Integrity finished ==="
}

main "$@"

