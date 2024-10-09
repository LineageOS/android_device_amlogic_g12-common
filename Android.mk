#
# Copyright (C) 2021-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifneq ($(filter sm1,$(TARGET_AMLOGIC_SOC)),)
ifneq ($(TARGET_USES_P_MODULES),true)

LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

endif
endif
