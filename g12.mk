#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

## Attestation
PRODUCT_COPY_FILES +=  \
    frameworks/native/data/etc/android.hardware.device_unique_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.device_unique_attestation.xml \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml

PRODUCT_COPY_FILES +=  \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml

## Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml

PRODUCT_PACKAGES += \
    android.hardware.audio@7.0-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.audio.service

## Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-legacy \
    android.hardware.camera.provider@2.5-legacy \
    android.hardware.camera.provider@2.5-service \
    camera.device@1.0-impl \
    camera.device@3.2-impl \
    camera.device@3.3-impl \
    camera.device@3.4-impl \
    camera.device@3.5-impl

## Cgroups
PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/cgroups_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    $(LOCAL_PATH)/configs/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

## Codecs
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media/media_codecs_amlogic_audio_ddp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_audio_ddp.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_audio_dts.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_audio_dts.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_audio_dtshd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_audio_dtshd.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_audio_ffmpeg.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_audio_ffmpeg.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_audio.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_encoder.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_encoder.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_performance_encoder.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_performance_encoder.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_performance_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_performance_video.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_video_ext.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_video_ext.xml \
    $(LOCAL_PATH)/media/media_codecs_amlogic_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_amlogic_video.xml \
    $(LOCAL_PATH)/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(LOCAL_PATH)/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/media/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles.xml

## Graphics
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2022-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2022-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/mesondisplay.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/mesondisplay.cfg \
    $(LOCAL_PATH)/configs/mesondisplay.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/mesondisplay.cfg

## Init-Files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init-files/init.amlogic.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.rc \
    $(LOCAL_PATH)/init-files/init.amlogic.board.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.board.rc \
    $(LOCAL_PATH)/init-files/init.amlogic.bluetooth.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.bluetooth.rc \
    $(LOCAL_PATH)/init-files/init.amlogic.media.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.media.rc \
    $(LOCAL_PATH)/init-files/init.amlogic.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.usb.rc \
    $(LOCAL_PATH)/init-files/init.amlogic.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.wifi.rc \
    $(LOCAL_PATH)/init-files/init.recovery.amlogic.rc:recovery/root/init.recovery.amlogic.rc

# Support both AVB/Non-AVB variants of multiple boot mediums (default to eMMC)
ifneq ($(TARGET_HAS_TEE),false)
  ifneq ($(strip $(TARGET_BOOTDEVICE)),)
  PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/init-files/fstab.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_RAMDISK)/first_stage_ramdisk/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_RAMDISK)/fstab.amlogic
  else
  PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/init-files/fstab.amlogic:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab.amlogic:$(TARGET_COPY_OUT_RAMDISK)/first_stage_ramdisk/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab.amlogic:$(TARGET_COPY_OUT_RAMDISK)/fstab.amlogic
  endif
else
  ifneq ($(strip $(TARGET_BOOTDEVICE)),)
  PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/init-files/fstab_no_avb.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab_no_avb.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_RAMDISK)/first_stage_ramdisk/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab_no_avb.$(TARGET_BOOTDEVICE).amlogic:$(TARGET_COPY_OUT_RAMDISK)/fstab.amlogic
  else
  PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/init-files/fstab_no_avb.amlogic:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab_no_avb.amlogic:$(TARGET_COPY_OUT_RAMDISK)/first_stage_ramdisk/fstab.amlogic \
      $(LOCAL_PATH)/init-files/fstab_no_avb.amlogic:$(TARGET_COPY_OUT_RAMDISK)/fstab.amlogic
  endif
endif

## OEM Lock
ifneq ($(TARGET_HAS_TEE),false)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported=1
endif

## Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)

## Platform
TARGET_AMLOGIC_SOC ?= g12a

## Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

## Shipping API
PRODUCT_SHIPPING_API_LEVEL := 29

## Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    bootable/deprecated-ota \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr

## VINTF
DEVICE_MANIFEST_FILE := $(LOCAL_PATH)/manifest.xml

ifneq ($(BOARD_HAVE_BLUETOOTH),false)
DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/manifest_bt.xml
endif

## Inherit from the main common tree product makefile
$(call inherit-product, device/amlogic/common/amlogic.mk)

## Inherit from the common proprietary files makefile
$(call inherit-product, vendor/amlogic/g12-common/g12-common-vendor.mk)
