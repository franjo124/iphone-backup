# iphone-backup

Back up an iPhone to Linux using [`pymobiledevice3`](https://github.com/doronz88/pymobiledevice3).

Replaces `idevicebackup2` from the `libimobiledevice` package, which segfaults on iOS 17+ due to the `com.apple.mobile.notification_proxy` service no longer being accessible via the old lockdown protocol.

## Requirements

- Python 3.13+
- `pipx` (installed via Homebrew)
- `pymobiledevice3` (installed via pipx)
- `usbmuxd` (Ubuntu package, for USB device detection)

### Install dependencies

```bash
brew install pipx
pipx install pymobiledevice3
```

## Usage

Connect your iPhone via USB, **unlock it**, then run:

```bash
./iphone-backup.sh [backup_directory]
```

- `backup_directory` defaults to `~/iphone-backup` if not specified.
- Backup data is written to a subdirectory named after the device UDID (same layout as iTunes/Finder backups).

### Examples

```bash
# Backup to default location (~/iphone-backup)
./iphone-backup.sh

# Backup to a custom location
./iphone-backup.sh /mnt/external/iphone-backup
```

## What the script does

1. Detects the connected device via usbmux and prints model/iOS version.
2. Checks the device is unlocked before attempting backup.
3. Runs `pymobiledevice3 backup2 backup` over the direct USB/usbmux connection (no tunnel required for backup).
4. Streams progress to the terminal in real time.
5. Exits with a clear error message if the device is locked or an error occurs.

## Troubleshooting

**"No device found"** — Make sure the iPhone is connected via USB and you have tapped *Trust* on the device for this computer.

**"iPhone is locked"** — Unlock your iPhone (enter PIN or use Face ID) and re-run the script.

**"Could not start service com.apple.mobile.notification_proxy" / segfault** — This happens when using the old `idevicebackup2` tool from Ubuntu's `libimobiledevice` package. Use this script instead.
