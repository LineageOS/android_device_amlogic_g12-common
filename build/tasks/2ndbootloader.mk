#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifneq ($(filter g12a g12b sm1, $(TARGET_AMLOGIC_SOC)),)

MKDTBOIMG := $(HOST_OUT_EXECUTABLES)/mkdtboimg.py
DTBTARGET := $(PRODUCT_OUT)/dtb.img
DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbToolAmlogic$(HOST_EXECUTABLE_SUFFIX)
DTBTMP := $(PRODUCT_OUT)/tmp_dt
DTBDIR := $(PRODUCT_OUT)/obj/KERNEL_OBJ/arch/arm64/boot/dts/amlogic
DTCDIR := $(PRODUCT_OUT)/obj/KERNEL_OBJ/scripts/dtc/
TARGET_FLASH_DTB_PARTITION ?= true

TARGET_DTBO_NAME ?= android_p_overlay_dt

define aml-compress-dtb
	if [ -n "$(shell find $(1) -size +200k)" ]; then \
		echo "$(1) > 200k will be gziped"; \
		mv $(1) $(1).orig; \
		$(MINIGZIP) -c $(1).orig > $(1); \
	fi;
endef

$(INSTALLED_2NDBOOTLOADER_TARGET): $(INSTALLED_KERNEL_TARGET) $(DTBTOOL) | $(ACP) $(MINIGZIP)
ifeq ($(words $(TARGET_DTB_NAME)),1)
	$(hide) $(ACP) $(DTBDIR)/$(TARGET_DTB_NAME).dtb $(DTBTARGET)
else
	$(hide) mkdir -p $(DTBTMP)
	$(foreach aDts, $(TARGET_DTB_NAME), \
		$(ACP) $(DTBDIR)/$(strip $(aDts)).dtb $(DTBTMP)/$(strip $(aDts)).dtb; \
	)
	$(hide) $(DTBTOOL) -o $(DTBTARGET) -p $(DTCDIR) $(DTBTMP)
	$(hide) rm -rf $(DTBTMP)
endif
	$(hide) $(call aml-compress-dtb, $(DTBTARGET))
	$(hide) $(ACP) $(DTBTARGET) $@

$(BOARD_PREBUILT_DTBOIMAGE): $(INSTALLED_KERNEL_TARGET) $(MKDTBOIMG)
	$(MKDTBOIMG) create $@ $(foreach dtbo, $(TARGET_DTBO_NAME), \
		$(DTBDIR)/$(strip $(dtbo)).dtb \
	)

$(DTBTARGET): $(INSTALLED_2NDBOOTLOADER_TARGET)

ifeq ($(TARGET_FLASH_DTB_PARTITION),true)
INSTALLED_RADIOIMAGE_TARGET += $(DTBTARGET)
endif

.PHONY: dtbotest
dtbotest: $(BOARD_PREBUILT_DTBOIMAGE)

endif
