#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
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
setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON}" "${ANDROID_ROOT}" true

# Warning headers and guards
write_headers "g12a g12b sm1" "TARGET_AMLOGIC_SOC"

# The standard common blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# The BSP blobs - we put a conditional in case the BSP
# is actually being built
printf '\n%s\n' 'ifneq ($(TARGET_HAS_TEE),false)' >> "$PRODUCTMK"

write_makefiles "${MY_DIR}/proprietary-files-tee.txt" true

printf '%s\n' 'endif' >> "$PRODUCTMK"

# The BSP blobs - we put a conditional in case the BSP
# is actually being built
printf '\n%s\n' 'ifneq ($(TARGET_USE_OSS_GRAPHIC),true)' >> "$PRODUCTMK"

write_makefiles "${MY_DIR}/proprietary-files-graphics.txt" true

printf '%s\n' 'endif' >> "$PRODUCTMK"

# The BSP blobs - we put a conditional in case the BSP
# is actually being built
printf '\n%s\n' 'ifneq ($(TARGET_USE_OSS_INTERFACES),true)' >> "$PRODUCTMK"

write_makefiles "${MY_DIR}/proprietary-files-interfaces.txt" true

printf '%s\n' 'endif' >> "$PRODUCTMK"

# Finish
write_footers

if [ -s "${MY_DIR}/../../${VENDOR_DEVICE}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    setup_vendor "${DEVICE}" "${VENDOR_DEVICE}" "${ANDROID_ROOT}" false

    # Warning headers and guards
    write_headers

    # The standard device blobs
    write_makefiles "${MY_DIR}/../../${VENDOR_DEVICE}/${DEVICE}/proprietary-files.txt" true

    # Finish
    write_footers
fi
