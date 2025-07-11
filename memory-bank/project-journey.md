---
type: overview
domain: system-state
subject: DLS iCloud Backup Integrity
status: active
summary: "Chronicles the project's evolution from a simple detector to a robust 'force-download' tool."
tags: [notes-active]
---
# Project Journey

## 1. The Initial Idea: A Simple Detector

The project began with a straightforward goal: create a shell script to scan a directory and list all files that were only stored in iCloud, not locally. The purpose was to warn the user about files that would be missed by local backup systems like Time Machine.

## 2. The Investigation: Hitting a Wall

The initial implementation attempted to use standard macOS command-line tools to identify the "cloud-only" status of files. This led to a deep and frustrating investigation where every conventional method failed:
*   `xattr` showed no consistent iCloud-specific attributes.
*   `brctl status` (related to the older daemon) proved to be obsolete and unhelpful for detection.
*   `mdfind` and Spotlight searches, even with specific iCloud-related keys like `kMDItemIsUbiquitous`, failed to differentiate between downloaded files and placeholders.
*   Searching for hidden `.icloud` files also yielded no results, proving this convention isn't universally applied.

This process revealed a critical insight: **the file status shown in the Finder is not exposed to the standard command-line environment.** There is a fundamental discrepancy between the GUI and the CLI.

## 3. The Pivot: From Detection to Action

The realization that reliable detection was impossible with shell scripting forced a strategic pivot. If we couldn't *see* the status, could we *change* it? This led to the "force-download" concept. An initial "force-read" hack using `dd` was implemented, but further refinement led to a more direct solution.

## 4. The Final Product: A Direct Solution

The final script uses the `brctl download` command, a more direct and robust method than the initial "force-read" hack. This command explicitly tells the system to download the file, achieving the project's goal without relying on side effects.

The final product incorporates this direct mechanism while prioritizing user control. It first counts the files to be processed and requires explicit user confirmation before starting the potentially lengthy and data-intensive download process. The journey is a classic example of a simple idea uncovering a deep systemic limitation, forcing a pivot from a passive detector to a direct, problem-solving tool.