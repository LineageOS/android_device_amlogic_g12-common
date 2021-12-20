#
# Copyright (C) 2021-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/amlogic/g12-common

## BUILD_BROKEN_*
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
SELINUX_IGNORE_NEVERALLOWS := true

# GPU
TARGET_AMLOGIC_GPU_ARCH := bifrost

## HIDL
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/manifest.xml

## Kernel
<<<<<<< HEAD   (72abed g12: Decommonize libsecmem)
BOARD_KERNEL_CMDLINE := androidboot.dynamic_partitions=true androidboot.boot_devices=ffe07000.emmc use_uvm=1
=======
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_DTB_OFFSET := 0x00e88000
BOARD_KERNEL_BASE := 0x01078000
BOARD_KERNEL_CMDLINE := androidboot.dtbo_idx=0 androidboot.boot_devices=ffe07000.emmc otg_device=1 use_uvm=1 androidboot.selinux=permissive
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ/arch/$(KERNEL_ARCH)/boot/dtbo.img
BOARD_RAMDISK_OFFSET := 0xfef10000
BOARD_SECOND_OFFSET := 0xfee10000
BOARD_TAGS_OFFSET := 0xfdf10100
TARGET_BOOTLOADER_IS_2ND := true
TARGET_KERNEL_ADDITIONAL_FLAGS := HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument"
TARGET_KERNEL_CLANG_COMPILE := true
>>>>>>> CHANGE (7ca572 [DNM] g12: Set SELinux status to Permissive)
TARGET_KERNEL_CONFIG := g12a_defconfig
TARGET_KERNEL_SOURCE := kernel/amlogic/linux-4.9
TARGET_KERNEL_VARIANT_CONFIG ?= g12a_variant_defconfig

## Partitions
CORE_PARTITIONS := system vendor
ADDITIONAL_PARTITIONS := odm product system_ext
ALL_PARTITIONS := $(CORE_PARTITIONS) $(ADDITIONAL_PARTITIONS)

BOARD_AMLOGIC_DYNAMIC_PARTITIONS_PARTITION_LIST := $(ALL_PARTITIONS)
BOARD_AMLOGIC_DYNAMIC_PARTITIONS_SIZE := 1673527296 # (BOARD_SUPER_PARTITION_SIZE - "Reasonable Overhead of 4 MiB" 4194304)
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := amlogic_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE := 1677721600
BUILDING_SUPER_EMPTY_IMAGE := true

ifneq ($(WITH_GMS),true)
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 300000000
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 200000000
BOARD_SYSTEM_EXTIMAGE_PARTITION_RESERVED_SIZE := 100000000
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 10000000
endif

## Properties
TARGET_PRODUCT_PROP += $(COMMON_PATH)/product.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor.prop

## Recovery
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init-files/fstab.amlogic

## Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(COMMON_PATH)/releasetools

## Vendor SPL
VENDOR_SECURITY_PATCH := 2022-12-01

## Include the main common tree BoardConfig makefile
include device/amlogic/common/BoardConfigAmlogic.mk

## Include the common proprietary BoardConfig makefile
include vendor/amlogic/g12-common/BoardConfigVendor.mk
