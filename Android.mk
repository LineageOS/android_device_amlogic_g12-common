#
# Copyright (C) 2021-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifneq ($(filter g12a g12b sm1,$(TARGET_AMLOGIC_SOC)),)
ifneq ($(TARGET_USES_P_MODULES),true)

LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

VULKAN_SYMLINK := $(TARGET_OUT_VENDOR)/lib/hw
$(VULKAN_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Vulkan lib link: $@"
	@mkdir -p $@
	$(hide) ln -sf /vendor/lib/egl/libGLES_mali.so $@/vulkan.amlogic.so

ALL_DEFAULT_INSTALLED_MODULES += $(VULKAN_SYMLINK)

endif
endif
