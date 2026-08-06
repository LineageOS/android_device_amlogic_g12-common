#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
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
       'vendor/lib/egl/libGLES_mali.so',
       'vendor/lib/hw/android.hardware.graphics.allocator-V2-arm.so',
       'vendor/lib/hw/android.hardware.graphics.mapper@4.0-impl-arm.so',
       'vendor/lib/hw/mapper.arm.so',
       'vendor/bin/hw/android.hardware.graphics.allocator-service'
    ): blob_fixup()
        .replace_needed('android.hardware.graphics.common-V4-ndk.so', 'android.hardware.graphics.common-V7-ndk.so'),
    'vendor/lib/libamlaudiohal@7.0.so': blob_fixup()
        .replace_needed('android.media.audio.common.types-V2-cpp.so', 'android.media.audio.common.types-V4-cpp.so'),
    'vendor/lib/hw/audio.primary.amlogic.so': blob_fixup()
        .add_needed('libbluetooth_audio_session_aidl_shim.so'),
    (
        'vendor/lib/hw/camera.amlogic.so',
        'vendor/lib/hw/hwcomposer.amlogic.so',
        'vendor/lib/libmeson_display_service.so',
        'vendor/lib/libscreencontrolservice.so'
    ): blob_fixup()
        .add_needed('libui_shim.so'),
    ('vendor/etc/init/fs.rc'): blob_fixup()
        .regex_replace('    mkdir /data/media 0770 media_rw media_rw encryption=None\n', '')
        .regex_replace('    setprop ro.crypto.fuse_sdcard true\n', ''),
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
