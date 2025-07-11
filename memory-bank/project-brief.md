---
type: overview
domain: system-state
subject: DLS iCloud Backup Integrity
status: active
summary: "Defines the core mission and purpose of the iCloud Backup Integrity project."
tags: [notes-active] 
---
# Project Brief: iCloud Backup Integrity

## 1. Mission

To ensure that all files stored in iCloud Drive are fully downloaded to the local machine, making them available for local backup solutions like Time Machine and preventing potential data loss.

## 2. Problem Statement

Users of iCloud Drive often have files that exist only as "placeholders" on their local machine to save disk space. These placeholder files are not included in standard local backups (e.g., Time Machine), creating a significant and often invisible risk of data loss. There is no built-in, reliable command-line utility on macOS to identify and download all these placeholder files in a given directory.

## 3. Solution

A shell script (`scripts/dls-check-icloud-files.sh`) that provides an interactive way to solve this problem. The script:
1.  Scans a user-specified directory and counts the total number of files.
2.  Informs the user of the file count and the nature of the operation.
3.  Requires explicit user confirmation before proceeding.
4.  Upon confirmation, it uses the `brctl download` command for each file, which is the system-level command to force macOS to download the full file from iCloud if it is not already present locally.

This ensures all files are physically present on the disk and can be captured by local backup systems.

