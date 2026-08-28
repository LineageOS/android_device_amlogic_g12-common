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
SSI_PARTITIONS := product system system_ext
TREBLE_PARTITIONS := odm system_dlkm vendor vendor_dlkm
ALL_PARTITIONS := $(SSI_PARTITIONS) $(TREBLE_PARTITIONS)

BOARD_AMLOGIC_DYNAMIC_PARTITIONS_PARTITION_LIST := $(ALL_PARTITIONS)
BOARD_AMLOGIC_DYNAMIC_PARTITIONS_SIZE := $(shell echo $$(($(BOARD_SUPER_PARTITION_SIZE) - 4194304))) # (BOARD_SUPER_PARTITION_SIZE - "reasonable overhead of 4 MiB" 4194304)
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := amlogic_dynamic_partitions

ifneq ($(PRODUCT_IS_ATV),true)
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 300000000
endif

## Properties
TARGET_SYSTEM_EXT_PROP += $(COMMON_PATH)/system_ext.prop
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
VENDOR_SECURITY_PATCH := 2025-02-01

## Include the main common tree BoardConfig makefile
include device/amlogic/common/BoardConfigAmlogic.mk

## Include the common proprietary BoardConfig makefile
include vendor/amlogic/g12-common/BoardConfigVendor.mk
