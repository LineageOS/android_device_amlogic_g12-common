#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

include $(CLEAR_VARS)

LOGO_FILES := device/amlogic/g12-common/logo

IMGPACK := $(HOST_OUT_EXECUTABLES)/res_packer$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_LOGOIMAGE_TARGET := $(PRODUCT_OUT)/logo.img
$(INSTALLED_LOGOIMAGE_TARGET): $(LOCAL_INSTALLED_MODULE) | $(IMGPACK) $(MINIGZIP) $(ACP)
	@echo "generate $(INSTALLED_LOGOIMAGE_TARGET) $(LOGO_FILES)"
	$(hide) mkdir -p $(PRODUCT_OUT)/logo
	$(foreach bmpf, $(filter %.bmp, $(wildcard $(LOGO_FILES)/*)), \
		if [ -n "$(shell find $(bmpf) -type f -size +256k)" ]; then \
			echo "logo pic $(bmpf) >256k gziped"; \
			$(MINIGZIP) -c $(bmpf) > $(PRODUCT_OUT)/logo/$(notdir $(bmpf)); \
		else \
			$(ACP) $(bmpf) $(PRODUCT_OUT)/logo; \
		fi;)
	$(hide) $(IMGPACK) -r $(PRODUCT_OUT)/logo $(INSTALLED_LOGOIMAGE_TARGET)
	$(hide) rm -rf $(PRODUCT_OUT)/logo

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_LOGOIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_LOGOIMAGE_TARGET)

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_LOGOIMAGE_TARGET)

.PHONY: logoimage
logoimage: $(INSTALLED_LOGOIMAGE_TARGET)
