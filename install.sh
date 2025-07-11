#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: Installs the dls-check-icloud-files.sh script for global use.
# Project: https://github.com/pequet/dls-icloud-backup-integrity/
# Refer to main project for detailed docs.

# --- Source Utilities ---
# Resolve the true directory of this install script to find project files
INSTALL_SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# --- Logging & Messaging Setup ---
LOG_FILE_PATH="${INSTALL_SCRIPT_DIR}/logs/install.log"
source "${INSTALL_SCRIPT_DIR}/scripts/utils/logging_utils.sh"
source "${INSTALL_SCRIPT_DIR}/scripts/utils/messaging_utils.sh"

# --- Main Installation Logic ---
main() {
    ensure_log_directory
    print_header "DLS iCloud Backup Integrity Installer"

    # --- Define Paths ---
    local SOURCE_SCRIPT_NAME="dls-check-icloud-files.sh"
    local DEST_DIR="/usr/local/bin"
    local DEST_PATH="${DEST_DIR}/${SOURCE_SCRIPT_NAME}"
    local SOURCE_SCRIPT_PATH="${INSTALL_SCRIPT_DIR}/scripts/${SOURCE_SCRIPT_NAME}"

    # --- Step 1: Verify source file ---
    print_step "Step 1: Verifying required script"
    if [ ! -f "$SOURCE_SCRIPT_PATH" ]; then
        print_error "Source script not found at ${SOURCE_SCRIPT_PATH}"
        exit 1
    fi

    # --- Step 2: Verify destination directory ---
    print_step "Step 2: Verifying destination directory"
    if [ ! -d "$DEST_DIR" ]; then
        print_error "Destination directory ${DEST_DIR} not found."
        print_info "Please ensure standard Homebrew/macOS paths are configured."
        exit 1
    fi

    # --- Step 3: Install the main script ---
    print_step "Step 3: Installing the main script"
    print_step "Attempting to create a symbolic link from ${SOURCE_SCRIPT_PATH} to ${DEST_PATH}"
    print_info "This will make the '${SOURCE_SCRIPT_NAME}' command available globally."
    print_info "You may be prompted for your administrator password."

    if ! sudo ln -sf "$SOURCE_SCRIPT_PATH" "$DEST_PATH"; then
        print_error "Failed to create symbolic link. Please check permissions for ${DEST_DIR}."
        exit 1
    fi

    print_separator
    print_completed "Success!"
    print_info "The '${SOURCE_SCRIPT_NAME}' command is now installed."
    print_info "You can now run it from any directory, for example:"
    echo # for spacing
    echo "  cd ~/Documents"
    echo "  dls-check-icloud-files.sh ."
    echo # for spacing
    print_footer
}

# --- Script Entrypoint ---
main "$@" 