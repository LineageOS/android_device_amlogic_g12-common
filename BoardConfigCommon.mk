#
# Copyright (C) 2021-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/amlogic/g12-common

## Android Verified Boot
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 0
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 2
BOARD_AVB_ROLLBACK_INDEX := 0
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

## Audio
BOARD_USES_ALSA_AUDIO := true
USE_CUSTOM_AUDIO_POLICY := 1

## BUILD_BROKEN_*
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

## Dex Pre-Opt
WITH_DEXPREOPT_DEBUG_INFO := false

## Display
TARGET_SCREEN_DENSITY := 320

# GPU
TARGET_AMLOGIC_GPU_ARCH := bifrost

## HIDL
ifeq ($(BOARD_HAVE_BLUETOOTH),false)
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/manifest.xml
else
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/manifest.xml
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/manifest_bt.xml
endif
DEVICE_MATRIX_FILE := $(COMMON_PATH)/compatibility_matrix.xml

## Kernel
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_DTB_OFFSET := 0x00e88000
BOARD_KERNEL_BASE := 0x01078000
BOARD_KERNEL_CMDLINE := androidboot.dynamic_partitions=true androidboot.dtbo_idx=0 androidboot.boot_devices=ffe07000.emmc otg_device=1 use_uvm=1
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
TARGET_KERNEL_CONFIG := g12a_defconfig
TARGET_KERNEL_SOURCE := kernel/amlogic/linux-4.9
TARGET_KERNEL_VARIANT_CONFIG ?= g12a_variant_defconfig
TARGET_USES_64_BIT_BINDER := true

BOARD_MKBOOTIMG_ARGS = --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --kernel_offset $(BOARD_KERNEL_OFFSET) --second_offset $(BOARD_SECOND_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_TAGS_OFFSET) --dtb_offset $(BOARD_DTB_OFFSET) --header_version $(BOARD_BOOTIMG_HEADER_VERSION) --dtb $(PRODUCT_OUT)/dtb.img

## LMKD
TARGET_LMKD_STATS_LOG := true

## Metadata
BOARD_USES_METADATA_PARTITION := true

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
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 15000000
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 626000000
BOARD_SYSTEM_EXTIMAGE_PARTITION_RESERVED_SIZE := 15000000
endif
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 5000000

$(foreach p, $(call to-upper, $(ALL_PARTITIONS)), \
    $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := ext4) \
    $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 838860800
BOARD_DTBOIMG_PARTITION_SIZE := 2097152
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := 4896849920
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 25165824
TARGET_USERIMAGES_USE_EXT4 := true

## Properties
TARGET_PRODUCT_PROP += $(COMMON_PATH)/product.prop
TARGET_SYSTEM_PROP += $(COMMON_PATH)/system.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor.prop

## Recovery
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init-files/fstab.amlogic
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"

## Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(COMMON_PATH)/releasetools

## Vendor SPL
VENDOR_SECURITY_PATCH := 2021-11-05

## Wi-Fi
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

## Include the main common tree BoardConfig makefile
include device/amlogic/common/BoardConfigAmlogic.mk

## Include the common proprietary BoardConfig makefile
include vendor/amlogic/g12-common/BoardConfigVendor.mk
