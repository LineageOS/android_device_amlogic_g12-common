#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/amlogic/g12-common',
]


def lib_fixup_system_ext_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'system_ext' else None

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    'libamavutils': lib_fixup_system_ext_suffix,
    (
        'vendor.amlogic.hardware.subtitleserver@1.0',
        'libvendorfont',
        'libsubtitlebinder'
    ): lib_fixup_vendor_suffix,
    'libwpa_client': lib_fixup_remove,
}

blob_fixups: blob_fixups_user_type = {
   (
        'vendor/lib/hw/camera.amlogic.so',
        'vendor/lib/hw/hwcomposer.amlogic.so',
        'vendor/lib/libOmxBase.so',
        'vendor/lib/libOmxCore.so',
        'vendor/lib/libOmxVideo.so',
        'vendor/lib/libmeson_display_service.so'
    ): blob_fixup()
        .add_needed('libui_shim.so'),
    ('vendor/etc/init/fs.rc'): blob_fixup()
        .regex_replace('    mkdir /data/media 0770 media_rw media_rw\n', '')
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
