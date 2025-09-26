#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024-2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

from extract_utils.fixups_lib import (
    lib_fixups,
)

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/amlogic/g12-common',
]

blob_fixups: blob_fixups_user_type = {
    (
       'vendor/bin/hw/android.hardware.thermal@2.0-service.droidlogic',
       'vendor/bin/hw/android.hardware.usb.gadget@1.2-service.droidlogic'
    ): blob_fixup()
        .add_needed('libbase_shim.so'),
    (
        'vendor/lib/hw/camera.amlogic.so',
        'vendor/lib/hw/hwcomposer.amlogic.so',
        'vendor/lib/libOmxBase.so',
        'vendor/lib/libOmxCore.so',
        'vendor/lib/libOmxVideo.so',
        'vendor/lib/libmeson_display_service.so'
    ): blob_fixup()
        .add_needed('libui_shim.so'),
    (
        'vendor/bin/hw/android.hardware.memtrack-service.droidlogic',
        'vendor/lib/libmemtrack-amlogic.so'
    ): blob_fixup()
        .replace_needed('android.hardware.memtrack-V1-ndk_platform.so', 'android.hardware.memtrack-V1-ndk.so')
        .replace_needed('libbase.so', 'libbase-v33.so'),
    ('vendor/etc/init/fs.rc'): blob_fixup()
        .regex_replace('    mkdir /data/media 0770 media_rw media_rw\n', '')
        .regex_replace('    setprop ro.crypto.fuse_sdcard true\n', ''),
    'vendor/etc/bluetooth/bt_vendor.conf': blob_fixup()
        .regex_replace('/etc/bluetooth/', '/vendor/etc/bluetooth/'),
}  # fmt: skip

module = ExtractUtilsModule(
    'g12-common',
    'amlogic',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
