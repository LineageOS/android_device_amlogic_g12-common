#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for common
setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON:-$VENDOR}" "${ANDROID_ROOT}" true

# Warning headers and guards
write_headers "sm1" "TARGET_AMLOGIC_SOC"

# The standard common blobs
write_makefiles "${MY_DIR}/proprietary-files.txt"

# Allow opting out of OP-TEE
printf '\n%s\n' 'ifneq ($(TARGET_HAS_TEE),false)' >> "$PRODUCTMK"

write_makefiles "${MY_DIR}/proprietary-files-tee.txt"

printf '%s\n' 'endif' >> "$PRODUCTMK"

# Finish
write_footers

if [ -s "${MY_DIR}/../../${VENDOR_BRAND}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

    # Warning headers and guards
    write_headers

    # The standard device blobs
    write_makefiles "${MY_DIR}/../../${VENDOR_BRAND}/${DEVICE}/proprietary-files.txt"

    if [ -f "${MY_DIR}/../../${VENDOR_BRAND}/${DEVICE}/proprietary-firmware.txt" ]; then
        append_firmware_calls_to_makefiles "${MY_DIR}/../../${VENDOR_BRAND}/${DEVICE}/proprietary-firmware.txt"
    fi

    # Finish
    write_footers
fi
