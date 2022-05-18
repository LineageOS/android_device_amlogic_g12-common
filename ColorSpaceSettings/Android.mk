LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(call all-java-files-under, src)
LOCAL_PACKAGE_NAME := ColorSpaceSettings

LOCAL_CERTIFICATE := platform
LOCAL_PRIVATE_PLATFORM_APIS := true
LOCAL_PRIVILEGED_MODULE := true
LOCAL_MODULE_TAGS := optional

LOCAL_STATIC_ANDROID_LIBRARIES := \
    org.lineageos.settings.resources

LOCAL_STATIC_JAVA_LIBRARIES := \
    droidlogic

LOCAL_JAVA_LIBRARIES := \
    org.lineageos.platform.internal

LOCAL_AAPT_FLAGS := \
    --extra-packages com.droidlogic.app

LOCAL_PROGUARD_ENABLED := disabled

include $(BUILD_PACKAGE)
include $(CLEAR_VARS)

LOCAL_PREBUILT_STATIC_JAVA_LIBRARIES := \
    droidlogic:lib/droidlogic.jar

include $(BUILD_MULTI_PREBUILT)
