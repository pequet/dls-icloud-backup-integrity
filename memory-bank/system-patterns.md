---
type: overview
domain: system-state
subject: DLS iCloud Backup Integritystatus: active
summary: "Documents the interactive script pattern used to ensure user consent."
tags: [notes-active]
---
# System Patterns

## 1. The Interactive Confirmation Pattern

This project establishes a critical pattern for any script that performs a potentially long-running or data-intensive operation. The script should not proceed automatically.

### Pattern Implementation:

1.  **Analyze & Inform:** The script first performs a lightweight analysis to understand the scope of the potential operation (in this case, counting the files with `find` and `wc`). It then presents this information to the user in a clear, understandable way.
2.  **Warn:** It explicitly warns the user about the potential consequences of the action (e.g., "This may trigger large downloads").
3.  **Prompt for Confirmation:** It uses the `read` command to pause execution and wait for explicit user confirmation (`y/n`).
4.  **Graceful Exit:** If the user does not confirm, the script prints a clear "Operation cancelled" message and exits. It does not perform any part of the core operation.

This pattern respects the user's control over their system and prevents accidental execution of powerful commands, building trust and ensuring the tool is used intentionally.
