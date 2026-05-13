#!/usr/bin/env bash
# iPhone backup script using pymobiledevice3 (supports iOS 17+)
# Usage: ./iphone-backup.sh [backup_directory]
#
# Requires: pymobiledevice3 (installed via pipx)
# Make sure your iPhone is unlocked before running.

set -euo pipefail

BACKUP_DIR="${1:-$HOME/iphone-backup}"

echo "==> Backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Check device is connected
echo "==> Checking for connected device..."
DEVICE=$(pymobiledevice3 usbmux list 2>/dev/null)
if [ -z "$DEVICE" ] || echo "$DEVICE" | grep -q '^\[\]'; then
    echo "ERROR: No device found. Make sure your iPhone is connected via USB and unlocked."
    exit 1
fi
echo "$DEVICE" | python3 -c "import sys,json; d=json.load(sys.stdin)[0]; print(f\"    Found: {d['DeviceName']} ({d['ProductType']}, iOS {d['ProductVersion']})\")"

# Check device is not locked
echo "==> Checking device is unlocked..."
LOCK_CHECK=$(pymobiledevice3 lockdown get-value --domain com.apple.mobile.lockdown PasscodeRequired 2>&1 || true)
if echo "$LOCK_CHECK" | grep -qi 'true\|password protected\|locked'; then
    echo "ERROR: iPhone is locked. Please unlock your iPhone and try again."
    exit 1
fi

# Run the backup (backup2 uses direct usbmux — no tunnel needed)
echo "==> Starting backup (this may take a while)..."
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
pymobiledevice3 backup2 backup "$BACKUP_DIR" 2>&1 | tee "$TMPFILE" || true
if grep -qi 'password protected' "$TMPFILE"; then
    echo "ERROR: iPhone is locked. Please unlock your iPhone and try again."
    exit 1
elif grep -qi 'ERROR' "$TMPFILE"; then
    echo "ERROR: Backup failed (see above)."
    exit 1
fi

echo ""
echo "==> Backup complete! Files saved to: $BACKUP_DIR"
