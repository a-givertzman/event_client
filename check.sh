#!/bin/bash

# Debian 12 Kernel Upgrade Pre-Check Script
# This script identifies common pitfalls before/after a backports kernel upgrade.

set -e

# 1. Check Debian Version
echo "--- Checking OS Version ---"
if [[ -f /etc/debian_version ]]; then
    DEB_VER=$(cat /etc/debian_version)
    echo "Debian version: $DEB_VER"
    if [[ $DEB_VER != 12* ]]; then
        echo "[WARNING] This script is optimized for Debian 12. Use with caution."
    fi
else
    echo "[ERROR] Could not detect Debian version."
fi

# 2. Check current and installed kernels
echo -e "\n--- Kernel Information ---"
echo "Currently running: $(uname -r)"
echo "Installed kernels:"
dpkg -l | grep -E 'linux-image-[0-9]' | awk '{print $2, $3}'

# 3. Check for linux-base dependency (Critical for 6.12+)
echo -e "\n--- Checking linux-base (Backports Requirement) ---"
LB_VER=$(dpkg-query -W -f='${Version}' linux-base 2>/dev/null || echo "0")
echo "Installed linux-base version: $LB_VER"
if dpkg --compare-versions "$LB_VER" lt "4.12"; then
    echo "[CRITICAL] linux-base is < 4.12. Kernel 6.12+ WILL FAIL to install."
    echo "Solution: sudo apt install -t bookworm-backports linux-base"
else
    echo "[OK] linux-base version is compatible with newer kernels."
fi

# 4. Check for DKMS modules (NVIDIA, WiFi, VirtualBox)
echo -e "\n--- Checking DKMS Modules ---"
if command -v dkms >/dev/null; then
    DKMS_STATUS=$(dkms status)
    if [[ -z "$DKMS_STATUS" ]]; then
        echo "[OK] No DKMS modules detected."
    else
        echo "Detected modules:"
        echo "$DKMS_STATUS"
        if echo "$DKMS_STATUS" | grep -qv "installed"; then
            echo "[WARNING] Some DKMS modules are not fully installed. They may break on a new kernel."
        fi
    fi
else
    echo "[INFO] DKMS not installed. No external driver modules to check."
fi

# 5. Check for missing firmware
echo -e "\n--- Checking for Firmware Errors (Last Boot) ---"
DMESG_FIRMWARE=$(dmesg | grep -i "firmware" | grep -i "fail" || true)
if [[ -n "$DMESG_FIRMWARE" ]]; then
    echo "[WARNING] Recent firmware failures detected:"
    echo "$DMESG_FIRMWARE"
else
    echo "[OK] No firmware failures found in current logs."
fi

# 6. Check if reboot is required
echo -e "\n--- Status ---"
if [[ -f /var/run/reboot-required ]]; then
    echo "[NOTICE] A reboot is required to finish previous updates."
else
    echo "[OK] No pending reboots."
fi

echo -e "\n--- Script Complete ---"
