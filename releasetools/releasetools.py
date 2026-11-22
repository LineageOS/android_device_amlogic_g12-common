#!/bin/env python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import common


def FullOTA_InstallEnd(info):
    OTA_InstallEnd(info)
    return


def IncrementalOTA_InstallEnd(info):
    OTA_InstallEnd(info)
    return


def AddImage(info, folder, basename):
    data = info.input_zip.read(folder + basename)
    common.ZipWriteStr(info.output_zip, basename, data)


def PrintInfo(info, dest):
    info.script.Print("Patching {} image unconditionally...".format(
        dest.split('/')[-1]))


def WriteBootloaderImage(info, folder, basename):
    AddImage(info, folder, basename)
    PrintInfo(info, "/dev/block/by-name/bootloader")
    info.script.AppendExtra(
        'package_extract_file("%s", "/tmp/bootloader.img") || abort("Failed to extract bootloader.img.");'
        % basename)
    info.script.AppendExtra(
        'run_program("/system/bin/dd", "if=/tmp/bootloader.img", "of=/dev/block/by-name/bootloader", "bs=512", "seek=1", "conv=notrunc,fsync") == "0" || abort("Failed to update bootloader.");'
    )
    for part in ("mmcblk0boot0", "mmcblk0boot1"):
        info.script.AppendExtra(
            'ifelse(run_program("/system/bin/test", "-b", "/dev/block/%s") == "0", ('
            '\n  write_value("0", "/sys/block/%s/force_ro") || abort("Failed to unlock %s.");'
            '\n  run_program("/system/bin/dd", "if=/tmp/bootloader.img", "of=/dev/block/%s", "bs=512", "seek=1", "conv=notrunc,fsync") == "0" || abort("Failed to update %s.");'
            '\n  write_value("1", "/sys/block/%s/force_ro");'
            '\n));' % (part, part, part, part, part, part))
    info.script.AppendExtra('delete("/tmp/bootloader.img");')


def WriteDtbImage(info, folder, basename):
    AddImage(info, folder, basename)
    PrintInfo(info, "/dev/dtb")
    info.script.AppendExtra('package_extract_file("%s", "/tmp/dtb.img");' %
                            basename)
    info.script.AppendExtra(
        'run_program("/system/bin/dd", "if=/tmp/dtb.img", "of=/dev/dtb", "bs=1k", "count=256");'
    )


def WriteImage(info, folder, basename, dest):
    AddImage(info, folder, basename)
    PrintInfo(info, dest)
    info.script.AppendExtra('package_extract_file("%s", "%s");' %
                            (basename, dest))


def OTA_InstallEnd(info):
    WriteImage(info, "IMAGES/", "dtbo.img", "/dev/block/by-name/dtbo")
    WriteImage(info, "IMAGES/", "vbmeta.img", "/dev/block/by-name/vbmeta")
    if 'RADIO/bootloader.img' in info.input_zip.namelist():
        WriteBootloaderImage(info, "RADIO/", "bootloader.img")
    if 'RADIO/dtb.img' in info.input_zip.namelist():
        WriteDtbImage(info, "RADIO/", "dtb.img")
    if 'RADIO/logo.img' in info.input_zip.namelist():
        WriteImage(info, "RADIO/", "logo.img", "/dev/block/by-name/logo")
    if 'RADIO/misc.img' in info.input_zip.namelist():
        AddImage(info, "RADIO/", "misc.img")
    return
