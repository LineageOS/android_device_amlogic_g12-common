LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE           := fstab.amlogic
LOCAL_MODULE_TAGS      := optional
LOCAL_MODULE_CLASS     := ETC
ifneq ($(TARGET_HAS_TEE),false)
LOCAL_SRC_FILES        := fstab.amlogic
else
LOCAL_SRC_FILES        := fstab_no_avb.amlogic
endif
LOCAL_REQUIRED_MODULES := fstab.amlogic_ramdisk fstab.amlogic_first_stage_ramdisk
LOCAL_MODULE_PATH      := $(TARGET_OUT_VENDOR_ETC)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE           := fstab.amlogic_ramdisk
LOCAL_MODULE_STEM      := fstab.amlogic
LOCAL_MODULE_TAGS      := optional
LOCAL_MODULE_CLASS     := ETC
ifneq ($(TARGET_HAS_TEE),false)
LOCAL_SRC_FILES        := fstab.amlogic
else
LOCAL_SRC_FILES        := fstab_no_avb.amlogic
endif
LOCAL_MODULE_PATH      := $(TARGET_RAMDISK_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE           := fstab.amlogic_first_stage_ramdisk
LOCAL_MODULE_STEM      := fstab.amlogic
LOCAL_MODULE_TAGS      := optional
LOCAL_MODULE_CLASS     := ETC
ifneq ($(TARGET_HAS_TEE),false)
LOCAL_SRC_FILES        := fstab.amlogic
else
LOCAL_SRC_FILES        := fstab_no_avb.amlogic
endif
LOCAL_MODULE_PATH      := $(TARGET_RAMDISK_OUT)/first_stage_ramdisk
include $(BUILD_PREBUILT)
