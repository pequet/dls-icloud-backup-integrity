---
type: overview
domain: system-state
subject: DLS iCloud Backup Integrity
status: active
summary: "Details the technical investigation, final script architecture, and OS limitations."
tags: [notes-active]
---
# Technical Context

## 1. Technology Stack

*   **Language:** Bash
*   **Core Utilities:** `find`, `wc`, `read`, `brctl`
*   **Environment:** macOS command line

## 2. Technical Investigation & Core Challenge

The initial goal was to create a script that could *detect* and *report* on files that were iCloud placeholders. This proved to be impossible with standard command-line tools.

Our investigation revealed the following:
*   **`xattr` is Insufficient:** Cloud-only files do not consistently have a unique extended attribute that can be queried.
*   **`brctl status` is Obsolete:** This tool, related to an older version of the iCloud daemon, is deprecated and does not provide reliable status information for detection.
*   **`mdfind` (Spotlight) is Unreliable:** The command-line interface for Spotlight does not expose the specific metadata key (`NSMetadataUbiquitousItemDownloadingStatusKey`) that accurately reflects a file's download status. Finder uses private APIs to access this key, which are not available to shell scripts.
*   **`.icloud` Files are Not Universal:** The system of using hidden `.filename.icloud` placeholder files is not a consistent or reliable indicator.

**Conclusion:** We confirmed via research and extensive testing that there is **no reliable, purely shell-based method** to determine if a file is a placeholder. The operating system does not expose this information at the command-line level.

## 3. Final Architecture: The `brctl download` Solution

Given the inability to *detect* the status, the strategy was pivoted to *acting* on the files to ensure a desired state. While an initial version used a "force-read" hack with `dd`, the final and more robust solution uses the `brctl download` command.

The final script employs this mechanism:
1.  It uses `find` to generate a complete list of all files within the target path.
2.  It prompts the user for confirmation before proceeding.
3.  It iterates through every file in the list.
4.  For each file, it calls `brctl download "<file>"`.
5.  This command directly instructs the system to download the file if it is not already local, providing a more explicit and reliable method than the "force-read" hack.

This approach bypasses the metadata problem entirely and directly achieves the project's goal of ensuring all files are locally present for backup.
