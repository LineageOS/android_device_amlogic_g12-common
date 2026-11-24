/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 *
 * Installed as liboemcrypto.so and dlopens liboemcrypto_vendor.so, because
 * libwvhidl.so resolves _oecc* via dlsym() and a DT_NEEDED shim cannot
 * override symbols already defined in the stock library.
 */

#define LOG_TAG "oemcrypto_shim"

#include <dlfcn.h>
#include <errno.h>
#include <linux/types.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <log/log.h>

#define VENDOR_OEMCRYPTO_PATH "/vendor/lib/liboemcrypto_vendor.so"

#define SECURE_HEAP_DEFAULT_VERSION             1
#define SECURE_HEAP_USER_TA_VERSION             3

struct secure_block_info {
    __u32 version;
    __u32 size;
    __u32 handle;
    __u32 unused;
    __u32 state;
    __u32 id_high;
    __u32 id_low;
    __u32 paddr;
    __u32 psize;
    __u64 handle_extend;
    __u64 paddr_extend;
};

typedef struct {
    int version;
    int numFds;
    int numInts;
    int data[1];
} shim_native_handle_t;

/* 32-bit OEMCrypto_DestBufferDesc */
typedef struct {
    uint32_t type;
    void *handle_or_addr;
    uint32_t max_length;
    uint32_t offset;
} shim_dest_buffer_desc_t;

#define OEMCrypto_BufferType_Secure 1

static void *g_vendor_lib = NULL;
static pthread_once_t g_once = PTHREAD_ONCE_INIT;

static void init_vendor_lib(void) {
    g_vendor_lib = dlopen(VENDOR_OEMCRYPTO_PATH, RTLD_NOW | RTLD_LOCAL);
    if (!g_vendor_lib) {
        ALOGE("Failed to dlopen %s: %s", VENDOR_OEMCRYPTO_PATH, dlerror());
    } else {
        ALOGI("Loaded vendor OEMCrypto from %s", VENDOR_OEMCRYPTO_PATH);
    }
}

static void *resolve_sym(const char *name) {
    pthread_once(&g_once, init_vendor_lib);
    if (!g_vendor_lib) return NULL;
    void *fn = dlsym(g_vendor_lib, name);
    if (!fn) {
        ALOGE("Failed to dlsym %s: %s", name, dlerror());
    }
    return fn;
}

static const shim_dest_buffer_desc_t *prepare_dest_buffer(
        const shim_dest_buffer_desc_t *in_desc,
        shim_dest_buffer_desc_t *local_desc,
        shim_native_handle_t *local_nh) {
    if (!in_desc || in_desc->type != OEMCrypto_BufferType_Secure || !in_desc->handle_or_addr) {
        return in_desc;
    }

    const shim_native_handle_t *nh = (const shim_native_handle_t *)in_desc->handle_or_addr;
    uint32_t raw_val = (uint32_t)nh->data[0];

    /* Already a secmem handle (0xe2e0XXXX) or paddr, not an fd. */
    if ((raw_val >> 16) != 0 || nh->numFds <= 0) {
        return in_desc;
    }

    int dmabuf_fd = nh->data[0];
    size_t map_len = sizeof(struct secure_block_info);
    struct secure_block_info *block = (struct secure_block_info *)mmap(
            NULL, map_len, PROT_READ, MAP_SHARED, dmabuf_fd, 0);
    if (block == MAP_FAILED) {
        ALOGE("prepare_dest_buffer: mmap(fd=%d) failed: %s", dmabuf_fd, strerror(errno));
        return in_desc;
    }

    uint32_t ver = block->version;
    uint32_t sec_handle = block->handle;
    uint32_t vdec_handle = block->unused;
    uint32_t paddr = block->paddr;
    munmap(block, map_len);

    uint32_t target_handle = 0;
    if (ver == SECURE_HEAP_USER_TA_VERSION) {
        /* Prefer recycled mSecmemSession handle stored by libsecmem_shim. */
        if ((vdec_handle >> 20) == 0xe2e) {
            target_handle = vdec_handle;
        } else if (sec_handle != 0) {
            target_handle = sec_handle;
        }
    } else if (paddr != 0) {
        target_handle = paddr;
    } else if (sec_handle != 0) {
        target_handle = sec_handle;
    }

    if (target_handle == 0) {
        ALOGE("prepare_dest_buffer: fd=%d has empty secure_block_info (ver=%u, handle=0x%x, paddr=0x%x)",
              dmabuf_fd, ver, sec_handle, paddr);
        return in_desc;
    }

    *local_nh = *nh;
    local_nh->data[0] = (int)target_handle;

    *local_desc = *in_desc;
    local_desc->handle_or_addr = local_nh;
    return local_desc;
}

/* OEMCrypto_DecryptCENC */
typedef uint32_t (*fn_oecc48_t)(uint32_t session, const void *data_addr, uint32_t data_len,
                                uint32_t is_encrypted, const void *iv, uint32_t block_offset,
                                const shim_dest_buffer_desc_t *out_buffer,
                                const void *pattern, uint32_t subsample_flags);

uint32_t _oecc48(uint32_t session, const void *data_addr, uint32_t data_len,
                 uint32_t is_encrypted, const void *iv, uint32_t block_offset,
                 const shim_dest_buffer_desc_t *out_buffer,
                 const void *pattern, uint32_t subsample_flags) {
    static fn_oecc48_t real_fn = NULL;
    if (!real_fn) real_fn = (fn_oecc48_t)resolve_sym("_oecc48");
    if (!real_fn) return 28;

    shim_dest_buffer_desc_t local_desc;
    shim_native_handle_t local_nh;
    const shim_dest_buffer_desc_t *wrapped_out =
            prepare_dest_buffer(out_buffer, &local_desc, &local_nh);

    return real_fn(session, data_addr, data_len, is_encrypted, iv, block_offset,
                   wrapped_out, pattern, subsample_flags);
}

/* OEMCrypto_DecryptCENCExtend */
typedef uint32_t (*fn_oecc1501_t)(uint32_t session, const void *data_addr, uint32_t data_len,
                                  uint32_t is_encrypted, const void *iv, uint32_t block_offset,
                                  const shim_dest_buffer_desc_t *out_buffer,
                                  const void *pattern, uint32_t subsample_flags);

uint32_t _oecc1501(uint32_t session, const void *data_addr, uint32_t data_len,
                   uint32_t is_encrypted, const void *iv, uint32_t block_offset,
                   const shim_dest_buffer_desc_t *out_buffer,
                   const void *pattern, uint32_t subsample_flags) {
    static fn_oecc1501_t real_fn = NULL;
    if (!real_fn) real_fn = (fn_oecc1501_t)resolve_sym("_oecc1501");
    if (!real_fn) return 28;

    shim_dest_buffer_desc_t local_desc;
    shim_native_handle_t local_nh;
    const shim_dest_buffer_desc_t *wrapped_out =
            prepare_dest_buffer(out_buffer, &local_desc, &local_nh);

    return real_fn(session, data_addr, data_len, is_encrypted, iv, block_offset,
                   wrapped_out, pattern, subsample_flags);
}

/* OEMCrypto_CopyBuffer */
typedef uint32_t (*fn_oecc93_t)(uint32_t session, const void *data_addr, uint32_t data_len,
                                const shim_dest_buffer_desc_t *out_buffer,
                                uint32_t subsample_flags);

uint32_t _oecc93(uint32_t session, const void *data_addr, uint32_t data_len,
                 const shim_dest_buffer_desc_t *out_buffer, uint32_t subsample_flags) {
    static fn_oecc93_t real_fn = NULL;
    if (!real_fn) real_fn = (fn_oecc93_t)resolve_sym("_oecc93");
    if (!real_fn) return 28;

    shim_dest_buffer_desc_t local_desc;
    shim_native_handle_t local_nh;
    const shim_dest_buffer_desc_t *wrapped_out =
            prepare_dest_buffer(out_buffer, &local_desc, &local_nh);

    return real_fn(session, data_addr, data_len, wrapped_out, subsample_flags);
}

/* Naked tail-calls preserve arbitrary args; extra 4B keeps 8B stack alignment. */
#define DEFINE_OECC_FORWARD(sym)                                  \
    void *__resolve_##sym(void) { return resolve_sym(#sym); }     \
    __attribute__((naked)) void sym(void) {                       \
        __asm__ volatile(                                         \
            "push {r0-r3, lr}\n"                                  \
            "sub sp, sp, #4\n"                                    \
            "bl __resolve_" #sym "\n"                             \
            "mov r12, r0\n"                                       \
            "add sp, sp, #4\n"                                    \
            "pop {r0-r3, lr}\n"                                   \
            "bx r12\n"                                            \
        );                                                        \
    }

#define OECC_FWD(n) DEFINE_OECC_FORWARD(_oecc##n)
OECC_FWD(01) OECC_FWD(02) OECC_FWD(03) OECC_FWD(04) OECC_FWD(05) OECC_FWD(06) OECC_FWD(07)
OECC_FWD(08) OECC_FWD(09) OECC_FWD(10) OECC_FWD(12) OECC_FWD(13) OECC_FWD(14) OECC_FWD(17)
OECC_FWD(18) OECC_FWD(19) OECC_FWD(21) OECC_FWD(22) OECC_FWD(23) OECC_FWD(24) OECC_FWD(25)
OECC_FWD(26) OECC_FWD(27) OECC_FWD(29) OECC_FWD(30) OECC_FWD(31) OECC_FWD(32) OECC_FWD(33)
OECC_FWD(34) OECC_FWD(36) OECC_FWD(37) OECC_FWD(38) OECC_FWD(39) OECC_FWD(41) OECC_FWD(42)
OECC_FWD(43) OECC_FWD(44) OECC_FWD(45) OECC_FWD(46) OECC_FWD(49) OECC_FWD(50) OECC_FWD(51)
OECC_FWD(52) OECC_FWD(53) OECC_FWD(54) OECC_FWD(55) OECC_FWD(57) OECC_FWD(61) OECC_FWD(62)
OECC_FWD(63) OECC_FWD(64) OECC_FWD(65) OECC_FWD(66) OECC_FWD(67) OECC_FWD(68) OECC_FWD(69)
OECC_FWD(70) OECC_FWD(71) OECC_FWD(78) OECC_FWD(81) OECC_FWD(83) OECC_FWD(84) OECC_FWD(85)
OECC_FWD(86) OECC_FWD(88) OECC_FWD(89) OECC_FWD(90) OECC_FWD(91) OECC_FWD(92)
#undef OECC_FWD

DEFINE_OECC_FORWARD(OEMCrypto_DecryptCENCExtendSupport)
DEFINE_OECC_FORWARD(OEMCrypto_DecryptShareMemorySize)
DEFINE_OECC_FORWARD(OEMCrypto_DeleteUsageTable)
