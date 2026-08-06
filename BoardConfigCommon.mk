#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/amlogic/g12-common

## Architecture
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

## BUILD_BROKEN_*
# Needed for systemcontrol blobs copy-files to recovery via TARGET_RECOVERY_DEVICE_DIRS
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

## HIDL
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/manifest.xml

ifneq ($(BOARD_HAVE_BLUETOOTH),false)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/manifest_bt.xml
endif

## Kernel
BOARD_KERNEL_CMDLINE := androidboot.dynamic_partitions=true use_uvm=1
ifeq ($(TARGET_BOOTDEVICE),usb)
  BOARD_KERNEL_CMDLINE += androidboot.boot_devices=ff500000.dwc3
else ifeq ($(TARGET_BOOTDEVICE),sdcard)
  BOARD_KERNEL_CMDLINE += androidboot.boot_devices=ffe05000.sd2
else
  BOARD_KERNEL_CMDLINE += androidboot.boot_devices=ffe07000.emmc
endif

ifeq ($(WITH_CONSOLE),true)
  BOARD_KERNEL_CMDLINE += console=ttyS0,115200 no_console_suspend ignore_loglevel
endif

TARGET_KERNEL_VERSION ?= 5.15

## Partitions
BOARD_USES_SYSTEM_DLKMIMAGE := true
BOARD_USES_VENDOR_DLKMIMAGE := true
SSI_PARTITIONS := product system system_ext
TREBLE_PARTITIONS := odm system_dlkm vendor vendor_dlkm
ALL_PARTITIONS := $(SSI_PARTITIONS) $(TREBLE_PARTITIONS)

BOARD_AMLOGIC_DYNAMIC_PARTITIONS_PARTITION_LIST := $(ALL_PARTITIONS)
BOARD_AMLOGIC_DYNAMIC_PARTITIONS_SIZE := $(shell echo $$(($(BOARD_SUPER_PARTITION_SIZE) - 4194304))) # (BOARD_SUPER_PARTITION_SIZE - "reasonable overhead of 4 MiB" 4194304)
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := amlogic_dynamic_partitions

## Properties
TARGET_SYSTEM_PROP += $(COMMON_PATH)/system.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor.prop

## Recovery
TARGET_RECOVERY_DEVICE_DIRS += vendor/amlogic/g12-common/proprietary
ifneq ($(strip $(TARGET_BOOTDEVICE)),)
  TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init-files/fstab.$(TARGET_BOOTDEVICE).amlogic
else
  TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init-files/fstab.amlogic
endif

## Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(COMMON_PATH)/releasetools

## Updater
AB_OTA_UPDATER := false

## Vendor SPL
VENDOR_SECURITY_PATCH := 2024-07-01

## Include the main common tree BoardConfig makefile
include device/amlogic/common/BoardConfigAmlogic.mk

## Include the common proprietary BoardConfig makefile
include vendor/amlogic/g12-common/BoardConfigVendor.mk
