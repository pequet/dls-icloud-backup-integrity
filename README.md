# DLS iCloud Backup Integrity Checker

A command-line tool to force the download of all files in a specified iCloud Drive directory, ensuring they are physically present on your Mac for local backups (e.g., Time Machine).

The macOS "Optimize Mac Storage" feature can silently remove local copies of files, leaving only placeholders. Backups will only capture these placeholders, leading to data loss upon restoration. This script prevents that by reading every file, which triggers a download from iCloud if the file is not already local. It is the command-line equivalent of Finder's "Download Now" function.

For this tool to be effective, you MUST disable "Optimize Mac Storage" first in **System Settings → Apple ID → iCloud → iCloud Drive**.

## Architectural Context

While this script is a standalone tool, its full significance is best understood as part of a larger security architecture. Each DLS script serves as the practical implementation of a core security principle, from ensuring data integrity (`dls-icloud-backup-integrity`) and managing redundancy (`dls-sync-drives`) to securing critical assets (`dls-password-backup`). 

## Installation

An installer script is provided to make the command globally available on your system.

1.  Open your Terminal.
2.  Navigate to the directory where you cloned this repository.
3.  Run the installer:

```bash
./install.sh
```

The script will ask for your administrator password to create a symbolic link in `/usr/local/bin`.

## Usage

Once installed, you can run the `dls-check-icloud-files.sh` command from any directory.

### Interactive Mode

Navigate to any directory you want to check and run the script with `.` as the argument. It will count the files and ask for your confirmation before proceeding.

```bash
# Navigate to a critical folder in your iCloud Drive
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/Obsidian/[Vault Name]/

# Run the check on the current directory
dls-check-icloud-files.sh .
```

### Automated Mode (for Cron Jobs)

You can run the script non-interactively by adding the `-y` or `--yes` flag. This is ideal for scheduled checks with `cron`.

To set up a `cron` job to run every Sunday at 2 AM:

1.  Open your crontab for editing: `crontab -e`
2.  Add the following line, adjusting the path to your target folder:

```cron
# Every day at 2 AM, ensure all files in my main TRI repo are local
0 2 * * * /usr/local/bin/dls-check-icloud-files.sh "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/[Vault Name]" --yes >/tmp/icloud_check.log 2>&1
```

## How to Offload Local Files (Reverse Operation) **Unreliable**

If you wish to reverse the download process and free up local disk space, you can use the `brctl evict` command. This is the command-line equivalent of selecting "Remove Download" in Finder.

This command must be run on a per-file basis. To apply it to an entire directory, use `find`.

```bash
# Navigate to the root folder and evict all files in that directory and subdirectories
cd /path/to/your/folder
find . -type f -exec brctl evict {} \;
```

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)
- [Deploy on DigitalOcean](https://www.digitalocean.com/?refcode=51594d5c5604) (affiliate link $) 

Your support helps in maintaining and improving this project. 

