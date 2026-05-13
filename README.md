# iphone-backup

Back up an iPhone to Linux using [`pymobiledevice3`](https://github.com/doronz88/pymobiledevice3). Supports iOS 17 and later, including iOS 26.

Replaces `idevicebackup2` from Ubuntu's `libimobiledevice` package, which segfaults on iOS 17+ because `com.apple.mobile.notification_proxy` is no longer accessible via the old lockdown protocol.

## Requirements

- Ubuntu (tested) or any Linux distro with `usbmuxd`
- Python 3.13+
- Homebrew (for `pipx`)
- `usbmuxd` — install via `sudo apt install usbmuxd`

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/franjo124/iphone-backup.git
cd iphone-backup

# 2. Install pipx via Homebrew
brew install pipx

# 3. Install pymobiledevice3
pipx install pymobiledevice3

# 4. Make the script executable
chmod +x iphone-backup.sh
```

## Usage

1. Connect your iPhone via USB.
2. Unlock the device (enter PIN or use Face ID).
3. If prompted on the iPhone, tap **Trust** and enter your PIN.
4. Run:

```bash
./iphone-backup.sh [backup_directory]
```

`backup_directory` defaults to `~/iphone-backup`. Backup data is written into a subdirectory named after the device UDID — the same layout used by iTunes and Finder, making it compatible with standard restore tools.

### Examples

```bash
# Backup to the default location (~/iphone-backup)
./iphone-backup.sh

# Backup to an external drive
./iphone-backup.sh /mnt/external/iphone-backup
```

### Expected output

```
==> Backup directory: /home/user/iphone-backup
==> Checking for connected device...
    Found: iPhoneFranjo (iPhone13,2, iOS 26.5)
==> Checking device is unlocked...
==> Starting backup (this may take a while)...
100%|██████████| 100.0/100 [01:09<00:00,  1.43it/s]

==> Backup complete! Files saved to: /home/user/iphone-backup
```

## Backup structure

Backups are stored under `<backup_directory>/<UDID>/` and contain:

- `Info.plist` — device metadata (model, iOS version, serial number)
- `Manifest.db` — SQLite index of all backed-up files
- `Manifest.plist` — backup configuration and app list
- `Status.plist` — backup state (`SnapshotState: finished` indicates a complete backup)
- `[0-f]/` — hashed file data organised into 256 subdirectories

### Verifying a backup

```bash
python3 -c "
import plistlib
d = plistlib.load(open('~/iphone-backup/<UDID>/Status.plist', 'rb'))
print('Snapshot:', d['SnapshotState'])   # should be 'finished'
print('Date:', d['Date'])
print('Full backup:', d['IsFullBackup'])
"
```

## Incremental vs full backups

By default, subsequent runs are **incremental** — only changed files are transferred, which is significantly faster. To force a complete fresh backup:

```bash
pymobiledevice3 backup2 backup --full ~/iphone-backup
```

> **Note:** `--full` discards the previous backup snapshot before starting.

## How it works

1. Detects the connected device via usbmux and prints model and iOS version.
2. Checks the `PasscodeRequired` lockdown key to verify the device is unlocked.
3. Runs `pymobiledevice3 backup2 backup` over the direct USB/usbmux connection — **no RemoteXPC tunnel is needed for backup**.
4. Streams progress to the terminal in real time.
5. Inspects output for known error strings and exits with a clear message if anything goes wrong.

## Troubleshooting

**"No device found"**
Make sure the iPhone is connected via USB. Check `usbmuxd` is running (`systemctl status usbmuxd`). If the device is new to this machine, unlock it and tap **Trust** when prompted.

**"iPhone is locked"**
Unlock your iPhone (enter PIN or use Face ID) and re-run the script.

**`pymobiledevice3: command not found`**
The pipx bin directory is not on your `PATH`. Run `pipx ensurepath` and open a new terminal, or use the full path `~/.local/bin/pymobiledevice3`.

**`usbmuxd` not found / device not detected after connecting**
Install or restart usbmuxd:
```bash
sudo apt install usbmuxd
sudo systemctl restart usbmuxd
```

**`SnapshotState` is not `finished` after backup**
The backup was interrupted. Re-run the script — pymobiledevice3 will resume from where it left off, or use `--full` to start clean.

**"Could not start service com.apple.mobile.notification_proxy" / segfault**
This is the symptom of using the old `idevicebackup2` tool from Ubuntu's `libimobiledevice` package (version 1.3.0), which does not support iOS 17+. Use this script instead.
