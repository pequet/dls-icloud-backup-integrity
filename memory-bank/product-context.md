---
type: overview
domain: system-state
subject: DLS iCloud Backup Integritystatus: active
summary: "Describes the user problem, target audience, and operational environment."
tags: [notes-active]
---
# Product Context

## 1. Target Audience

The primary user is anyone who relies on both Apple's iCloud Drive for file syncing and a separate, local backup solution (like Time Machine, Carbon Copy Cloner, or `rsync` scripts) for data preservation.

This user is typically technically proficient enough to use the command line but may not be aware of the underlying limitations of how iCloud Drive interacts with local backups.

## 2. The User Problem

A user believes their files are safe because they use two different systems: iCloud for convenience and a local backup for security. However, a critical gap exists that undermines this belief:

*   **"Optimize Mac Storage" is Deceptive:** When this iCloud setting is enabled, macOS offloads less-used files to the cloud, leaving only a lightweight placeholder on the local disk.
*   **Backups Miss Cloud-Only Files:** Local backup software can only back up what is physically on the disk. It sees the tiny placeholder file, backs that up, and reports success. It has no knowledge of the full file's contents in the cloud.
*   **Catastrophic Data Loss is Possible:** If a user's machine is lost or damaged and they try to restore from their local backup, they will only recover the placeholder files, not the actual data. If the files are also gone from iCloud for any reason, the data is permanently lost.

The core problem is a **false sense of security** caused by a lack of transparency between the file system's state and the user's backup software.

## 3. The "Aha!" Moment

The solution provides a moment of clarity and control. By running the script, the user can be confident that for a given directory, every single file is physically present and therefore fully included in their next local backup, closing the data-loss gap.
