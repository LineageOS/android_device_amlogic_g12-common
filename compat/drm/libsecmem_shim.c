/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 *
 * Linked into stock libsecmem.so via DT_NEEDED so libmediahal_videodec.so
 * resolves the missing Codec2 Secmem V2 entrypoints via dlsym().
 */

#define LOG_TAG "secmem_shim"

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

/* Kernel amlogic_secure_dmabuf.c ABI */
#define SECURE_HEAP_DEFAULT_VERSION             1
#define SECURE_HEAP_USER_TA_VERSION             3
#define AML_SECURE_DMABUF_HEAP_SETTING_PHYADDR  3

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

#define TA_SECMEM_V2_CMD_MEM_TO_PHY     0xff
#define TA_SECMEM_V2_CMD_PARSE          0x117

#define SECMEM_PARSE_AVCC               1
#define SECMEM_PARSE_AVC_START_CODE     2
#define SECMEM_PARSE_VP9                3
#define SECMEM_PARSE_HVCC               4
#define SECMEM_PARSE_HVC_START_CODE     5
#define SECMEM_PARSE_AV1                6

typedef uint32_t (*fn_Secure_V2_Init_t)(void *sess, uint32_t src, uint32_t flags,
                                        uint32_t paddr, uint32_t size);
typedef uint32_t (*fn_Secure_V2_Close_t)(void *sess, uint32_t *out);
typedef uint32_t (*fn_Secure_V2_MemCreate_t)(void *sess, uint32_t *pHandle);
typedef uint32_t (*fn_Secure_V2_MemFree_t)(void *sess, uint32_t handle);
typedef uint32_t (*fn_Secure_V2_MemRelease_t)(void *sess, uint32_t handle);
typedef uint32_t (*fn_Secure_V2_MemToPhy_t)(void *sess, uint32_t handle, uint32_t *phyaddr);
typedef uint32_t (*fn_Secure_V2_MemFlush_t)(void *sess);
typedef uint32_t (*fn_Secure_V2_GetVp9HeaderSize_t)(void *sess, uint32_t paddr, uint32_t frame_len,
                                                    uint32_t *out_hdr_size,
                                                    uint32_t *out_frame_sizes);
typedef uint32_t (*fn_Teec_PackUInt_t)(void *shm, uint32_t val, uint32_t *offset);
typedef uint32_t (*fn_Teec_UnPackUInt_t)(void *shm, uint32_t *val, uint32_t *offset);
typedef uint32_t (*fn_Teec_Invoke_t)(void *teec_sess, uint32_t cmd, void *shm);
typedef void (*fn_TEEC_CloseSession_t)(void *teec_sess);
typedef void (*fn_TEEC_FinalizeContext_t)(void *teec_ctx);
typedef void (*fn_releaseshm_t)(void *sess);
typedef int (*fn_secmem_resman_acquire_t)(int handle, int tvp_set, int flags);
typedef int (*fn_tvp_mm_enable_t)(int flags);
typedef int (*fn_tvp_mm_disable_t)(int flags);

static fn_Secure_V2_Init_t p_Secure_V2_Init = NULL;
static fn_Secure_V2_Close_t p_Secure_V2_Close = NULL;
static fn_Secure_V2_MemCreate_t p_Secure_V2_MemCreate = NULL;
static fn_Secure_V2_MemFree_t p_Secure_V2_MemFree = NULL;
static fn_Secure_V2_MemRelease_t p_Secure_V2_MemRelease = NULL;
static fn_Secure_V2_MemToPhy_t p_Secure_V2_MemToPhy = NULL;
static fn_Secure_V2_MemFlush_t p_Secure_V2_MemFlush = NULL;
static fn_Secure_V2_GetVp9HeaderSize_t p_Secure_V2_GetVp9HeaderSize = NULL;
static fn_Teec_PackUInt_t p_Teec_PackUInt = NULL;
static fn_Teec_UnPackUInt_t p_Teec_UnPackUInt = NULL;
static fn_Teec_Invoke_t p_Teec_Invoke = NULL;
static fn_TEEC_CloseSession_t p_TEEC_CloseSession = NULL;
static fn_TEEC_FinalizeContext_t p_TEEC_FinalizeContext = NULL;
static fn_releaseshm_t p_releaseshm = NULL;
static fn_secmem_resman_acquire_t p_secmem_resman_acquire = NULL;
static fn_tvp_mm_enable_t p_tvp_mm_enable = NULL;
static fn_tvp_mm_disable_t p_tvp_mm_disable = NULL;

static pthread_once_t g_syms_once = PTHREAD_ONCE_INIT;

static void resolve_secmem_syms(void) {
    void *secmem_dl = dlopen("libsecmem.so", RTLD_NOLOAD | RTLD_NOW);
    if (!secmem_dl) {
        secmem_dl = RTLD_DEFAULT;
    }
    p_Secure_V2_Init = (fn_Secure_V2_Init_t)dlsym(secmem_dl, "Secure_V2_Init");
    p_Secure_V2_Close = (fn_Secure_V2_Close_t)dlsym(secmem_dl, "Secure_V2_Close");
    p_Secure_V2_MemCreate = (fn_Secure_V2_MemCreate_t)dlsym(secmem_dl, "Secure_V2_MemCreate");
    p_Secure_V2_MemFree = (fn_Secure_V2_MemFree_t)dlsym(secmem_dl, "Secure_V2_MemFree");
    p_Secure_V2_MemRelease = (fn_Secure_V2_MemRelease_t)dlsym(secmem_dl, "Secure_V2_MemRelease");
    p_Secure_V2_MemToPhy = (fn_Secure_V2_MemToPhy_t)dlsym(secmem_dl, "Secure_V2_MemToPhy");
    p_Secure_V2_MemFlush = (fn_Secure_V2_MemFlush_t)dlsym(secmem_dl, "Secure_V2_MemFlush");
    p_Secure_V2_GetVp9HeaderSize =
            (fn_Secure_V2_GetVp9HeaderSize_t)dlsym(secmem_dl, "Secure_V2_GetVp9HeaderSize");
    p_Teec_PackUInt = (fn_Teec_PackUInt_t)dlsym(secmem_dl, "Teec_PackUInt");
    p_Teec_UnPackUInt = (fn_Teec_UnPackUInt_t)dlsym(secmem_dl, "Teec_UnPackUInt");
    p_Teec_Invoke = (fn_Teec_Invoke_t)dlsym(secmem_dl, "Teec_Invoke");
    p_TEEC_CloseSession = (fn_TEEC_CloseSession_t)dlsym(secmem_dl, "TEEC_CloseSession");
    p_TEEC_FinalizeContext = (fn_TEEC_FinalizeContext_t)dlsym(secmem_dl, "TEEC_FinalizeContext");
    p_releaseshm = (fn_releaseshm_t)dlsym(secmem_dl, "_Z10releaseshmP12secmem_ctx_t");
    p_secmem_resman_acquire = (fn_secmem_resman_acquire_t)dlsym(secmem_dl, "secmem_resman_acquire");

    void *amav_dl = dlopen("libamavutils.so", RTLD_NOLOAD | RTLD_NOW);
    if (!amav_dl) {
        amav_dl = RTLD_DEFAULT;
    }
    p_tvp_mm_enable = (fn_tvp_mm_enable_t)dlsym(amav_dl, "tvp_mm_enable");
    p_tvp_mm_disable = (fn_tvp_mm_disable_t)dlsym(amav_dl, "tvp_mm_disable");

    ALOGI("Resolved libsecmem syms: Init=%p Close=%p Create=%p Free=%p ToPhy=%p Flush=%p Vp9Hdr=%p CloseSess=%p FinCtx=%p RelShm=%p TvpDis=%p",
          p_Secure_V2_Init, p_Secure_V2_Close, p_Secure_V2_MemCreate,
          p_Secure_V2_MemFree, p_Secure_V2_MemToPhy, p_Secure_V2_MemFlush,
          p_Secure_V2_GetVp9HeaderSize, p_TEEC_CloseSession,
          p_TEEC_FinalizeContext, p_releaseshm, p_tvp_mm_disable);
}

/*
 * Stock libsecmem.so secmem_ctx_t offsets:
 *   +0x00: initialized  +0x04: TEEC_Context  +0x08: TEEC_Session
 *   +0x10: cmd TEEC_SharedMemory
 *   +0x48: tvp_mode     +0x4c: tvp_set (1=1080p, 2=4K)  +0x58: resman_handle
 */

/* CMD 0xff searches all active TA sessions without rpc_peer checks (unlike CMD 0x100). */
static uint32_t secmem_handle_to_phy(void *sess, uint32_t handle, uint32_t *paddr) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    if (!sess || !paddr) return 1;
    uint32_t *ctx = (uint32_t *)sess;
    if (ctx[0] == 0) return 1;

    if (p_Secure_V2_MemToPhy) {
        uint32_t res = p_Secure_V2_MemToPhy(sess, handle, paddr);
        if (res == 0 && *paddr != 0) {
            return 0;
        }
    }

    if (p_Teec_PackUInt && p_Teec_UnPackUInt && p_Teec_Invoke) {
        uint8_t *base = (uint8_t *)sess;
        void *teec_sess = base + 0x08;
        void *shm = base + 0x10;
        uint32_t in_off = 0;
        uint32_t out_off = 0;
        uint32_t res = 0;

        res = p_Teec_PackUInt(shm, TA_SECMEM_V2_CMD_MEM_TO_PHY, &in_off);
        if (res == 0) res = p_Teec_PackUInt(shm, handle, &in_off);
        if (res == 0) res = p_Teec_Invoke(teec_sess, TA_SECMEM_V2_CMD_MEM_TO_PHY, shm);
        if (res == 0) res = p_Teec_UnPackUInt(shm, paddr, &out_off);
        if (res == 0 && *paddr != 0) {
            return 0;
        }
    }

    return 1;
}

static uint32_t secmem_invoke_parse(void *sess, uint32_t parse_type,
                                    uint32_t handle, uint32_t *out_added_size) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    if (!sess || !p_Teec_PackUInt || !p_Teec_UnPackUInt || !p_Teec_Invoke) return 1;
    uint32_t *ctx = (uint32_t *)sess;
    if (ctx[0] == 0) return 1;

    uint8_t *base = (uint8_t *)sess;
    void *teec_sess = base + 0x08;
    void *shm = base + 0x10;
    uint32_t in_off = 0;
    uint32_t out_off = 0;
    uint32_t res = 0;

    res = p_Teec_PackUInt(shm, TA_SECMEM_V2_CMD_PARSE, &in_off);
    if (res == 0) res = p_Teec_PackUInt(shm, parse_type, &in_off);
    if (res == 0) res = p_Teec_PackUInt(shm, handle, &in_off);
    if (res == 0) res = p_Teec_Invoke(teec_sess, TA_SECMEM_V2_CMD_PARSE, shm);
    if (res == 0 && out_added_size) {
        uint32_t parsed_size = 0;
        if (p_Teec_UnPackUInt(shm, &parsed_size, &out_off) == 0) {
            *out_added_size = parsed_size;
        }
    }
    return res;
}

uint32_t Secure_V2_EnableTVPMemory(void *sess, uint32_t tvp_set) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    if (!sess) return 1;

    uint32_t *ctx = (uint32_t *)sess;
    uint32_t actual_set = tvp_set ? (tvp_set & 0xf) : 1;
    uint32_t tvp_mode = ctx[0x48 / 4];
    int32_t resman_id = (int32_t)ctx[0x58 / 4];
    int rc = 0;

    if (p_tvp_mm_enable) {
        rc = p_tvp_mm_enable((int)actual_set);
    } else if (tvp_mode >= 2 && resman_id >= 0 && p_secmem_resman_acquire) {
        rc = p_secmem_resman_acquire(resman_id, (int)actual_set, 3);
    }

    ctx[0x4c / 4] = actual_set;
    ALOGI("Secure_V2_EnableTVPMemory(sess=%p, tvp_set=%u, mode=%u, resman=%d) -> rc=%d",
          sess, actual_set, tvp_mode, resman_id, rc);
    return 0;
}

/* Reset TEEC state so the next Secure_V2_Init() opens a fresh TA session. */
static void secmem_reset_teec_session(void *sess) {
    uint32_t *ctx = (uint32_t *)sess;
    if (!ctx || ctx[0] == 0) return;

    uint8_t *base = (uint8_t *)sess;
    if (p_TEEC_CloseSession) {
        p_TEEC_CloseSession(base + 0x08);
    }
    if (p_TEEC_FinalizeContext) {
        p_TEEC_FinalizeContext(base + 0x04);
    }
    if (p_releaseshm) {
        p_releaseshm(sess);
    }
    ctx[0] = 0;
}

uint32_t Secure_V2_InitSecurePool(void *sess, uint32_t src, uint32_t flags,
                                  uint32_t mode, uint32_t dmabuf_fd) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    if (!sess) return 1;

    uint32_t *ctx = (uint32_t *)sess;
    uint32_t saved_tvp_set = ctx[0x4c / 4];
    uint32_t actual_set = saved_tvp_set ? (saved_tvp_set & 0xf) : 1;

    /*
     * packed_flags: [12:9]=vdec_type, [7:4]=codec_flag (1=VP9, 2=AV1), [3:0]=tvp_set.
     * Default codec_flag to 1 when flags == 0 so CMD 0xd0 (VP9 header parsing)
     * works later; for H.264/HEVC this only adds 0x80B allocation headroom.
     */
    uint32_t codec_flag = (flags & 0xf) ? (flags & 0xf) : 1U;
    uint32_t packed_flags = (1U << 9) | (codec_flag << 4) | actual_set;

    uint32_t ret = 0;
    if (p_Secure_V2_Init) {
        ret = p_Secure_V2_Init(sess, src, packed_flags, 0, 0);
        if (ret != 0 && actual_set > 1) {
            /*
             * tvp_set == 2 requests a 12 MB ES pool, which can OOM when the
             * kernel dmabuf session shares OP-TEE's ES pool. Reopen the TA
             * session and fall back to the 4 MB ES pool (tvp_set == 1); 4K
             * CMA frame buffers are unaffected.
             */
            uint32_t fallback_flags = (1U << 9) | (codec_flag << 4) | 1U;
            ALOGW("Secure_V2_InitSecurePool: packed=0x%x failed (ret=0x%x), retrying with 4MB ES pool (packed=0x%x)",
                  packed_flags, ret, fallback_flags);
            secmem_reset_teec_session(sess);
            packed_flags = fallback_flags;
            ret = p_Secure_V2_Init(sess, src, packed_flags, 0, 0);
        }
    }
    ctx[0x4c / 4] = actual_set;

    ALOGI("Secure_V2_InitSecurePool(sess=%p, src=%u, flags=0x%x, req_mode=%u, fd=%u) -> packed=0x%x ret=0x%x",
          sess, src, flags, mode, dmabuf_fd, packed_flags, ret);
    return ret;
}

uint32_t Secure_V2_DestroySecurePool(void *sess) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    ALOGI("Secure_V2_DestroySecurePool(sess=%p)", sess);
    if (!sess) return 0;
    uint32_t out = 0;
    uint32_t ret = 0;
    if (p_Secure_V2_Close) {
        ret = p_Secure_V2_Close(sess, &out);
    }
    uint32_t *ctx = (uint32_t *)sess;
    if (p_tvp_mm_enable && p_tvp_mm_disable && ctx[0x4c / 4] != 0) {
        p_tvp_mm_disable(0);
        ctx[0x4c / 4] = 0;
    }
    return ret;
}

uint32_t Secure_V2_PoolFlush(void *sess) {
    pthread_once(&g_syms_once, resolve_secmem_syms);
    ALOGI("Secure_V2_PoolFlush(sess=%p)", sess);
    if (!sess) return 0;
    if (p_Secure_V2_MemFlush) {
        p_Secure_V2_MemFlush(sess);
    }
    return 0;
}

/*
 * codec_type: 0=H264/HEVC, 1=VP9, 2=AV1.
 * flags: 0x10 = add VP9/AV1 header, 0x04 = incomplete frame.
 * pFrameSize is IN/OUT (used by caller for V4L2 bytes_used); never zero it.
 */
uint32_t Secure_V2_UpdateFrameInfo(void *sess, uint32_t codec_type, uint32_t dmabuf_fd,
                                   uint32_t flags, uint32_t *pFrameSize) {
    pthread_once(&g_syms_once, resolve_secmem_syms);

    if ((dmabuf_fd >> 16) != 0) {
        return 0;
    }

    size_t map_len = sizeof(struct secure_block_info);
    struct secure_block_info *block = (struct secure_block_info *)mmap(
            NULL, map_len, PROT_READ | PROT_WRITE, MAP_SHARED, (int)dmabuf_fd, 0);
    if (block == MAP_FAILED) {
        ALOGE("Secure_V2_UpdateFrameInfo: mmap(fd=%u) failed: %s", dmabuf_fd, strerror(errno));
        return 0;
    }

    uint32_t ver = block->version;
    uint32_t kernel_handle = block->handle;
    uint32_t vdec_handle = block->unused;
    uint32_t active_handle = ((vdec_handle >> 20) == 0xe2e) ? vdec_handle : kernel_handle;
    uint32_t paddr = block->paddr;
    uint32_t size = block->size;

    if (ver == SECURE_HEAP_USER_TA_VERSION && (active_handle >> 20) == 0xe2e) {
        uint32_t resolved_paddr = 0;
        uint32_t ret = secmem_handle_to_phy(sess, active_handle, &resolved_paddr);
        if (ret == 0 && resolved_paddr != 0) {
            paddr = resolved_paddr;
        } else if (paddr == 0) {
            ALOGW("Secure_V2_UpdateFrameInfo: fd=%u handle=0x%x phy lookup failed (ret=0x%x)",
                  dmabuf_fd, active_handle, ret);
        }

        /*
         * Prefer Secure_V2_GetVp9HeaderSize (CMD 0xd0) over Secmem_V2_Parse
         * (CMD 0x117) for VP9: CMD 0x117 only cache-cleans orig_size after
         * shifting the frame, leaving the inserted header tail unflushed.
         * CMD 0xd0 flushes len + 0x84 but requires paddr in mSecmemSession's
         * pool, so fall back to CMD 0x117 for initial kernel frames and AV1.
         */
        if (flags & 0x10) {
            uint32_t orig_size = pFrameSize ? *pFrameSize : 0;
            int parsed = 0;

            if (codec_type == 1 && (vdec_handle >> 20) == 0xe2e &&
                paddr != 0 && orig_size > 0 && p_Secure_V2_GetVp9HeaderSize) {
                uint32_t hdr_size = 0;
                uint32_t frame_sizes[8];
                memset(frame_sizes, 0, sizeof(frame_sizes));
                uint32_t vp9_ret = p_Secure_V2_GetVp9HeaderSize(
                        sess, paddr, orig_size, &hdr_size, frame_sizes);
                if (vp9_ret == 0) {
                    uint32_t total_len = 0;
                    for (int i = 0; i < 8; i++) {
                        total_len += frame_sizes[i];
                    }
                    if (total_len > orig_size && total_len <= orig_size + 0x200) {
                        *pFrameSize = total_len;
                        parsed = 1;
                    } else if (hdr_size > 0 && hdr_size <= 0x200) {
                        *pFrameSize = orig_size + hdr_size;
                        parsed = 1;
                    }
                } else {
                    ALOGW("Secure_V2_UpdateFrameInfo: GetVp9HeaderSize(paddr=0x%x, len=%u) failed (ret=0x%x), falling back to Parse",
                          paddr, orig_size, vp9_ret);
                }
            }

            if (!parsed) {
                uint32_t parse_type = 0;
                if (codec_type == 1) {
                    parse_type = SECMEM_PARSE_VP9;
                } else if (codec_type == 2) {
                    parse_type = SECMEM_PARSE_AV1;
                }
                if (parse_type != 0) {
                    uint32_t added_bytes = 0;
                    uint32_t parse_ret = secmem_invoke_parse(sess, parse_type, active_handle, &added_bytes);
                    if (parse_ret == 0 && pFrameSize && added_bytes > 0 && added_bytes <= 0x200) {
                        *pFrameSize += added_bytes;
                    } else if (parse_ret != 0) {
                        ALOGW("Secure_V2_UpdateFrameInfo: Secmem_V2_Parse(type=%u, handle=0x%x) failed (ret=0x%x)",
                              parse_type, active_handle, parse_ret);
                    }
                }
            }
        }

        if (paddr != 0) {
            block->paddr = paddr;
            block->psize = size;
            block->state = AML_SECURE_DMABUF_HEAP_SETTING_PHYADDR;

            /* Re-mmap triggers kernel secure_heap_mmap() to bind sgl->dma_address. */
            void *bind_map = mmap(NULL, map_len, PROT_READ | PROT_WRITE,
                                  MAP_SHARED, (int)dmabuf_fd, 0);
            if (bind_map != MAP_FAILED) {
                munmap(bind_map, map_len);
            } else {
                ALOGE("Secure_V2_UpdateFrameInfo: bind mmap(fd=%u, paddr=0x%x) failed: %s",
                      dmabuf_fd, paddr, strerror(errno));
            }
        }

        /*
         * Frame is complete and bound for V4L2: free its ring-buffer slot (or
         * stash an mSecmemSession handle in block->unused on first use) so
         * reusing this dmabuf_fd allocates a fresh slot for the next frame.
         */
        if ((flags & 0x4) == 0) {
            if ((vdec_handle >> 20) == 0xe2e) {
                if (p_Secure_V2_MemFree) {
                    p_Secure_V2_MemFree(sess, vdec_handle);
                }
            } else if (p_Secure_V2_MemCreate) {
                uint32_t new_handle = 0;
                uint32_t cr = p_Secure_V2_MemCreate(sess, &new_handle);
                if (cr == 0 && (new_handle >> 20) == 0xe2e) {
                    block->unused = new_handle;
                } else {
                    ALOGW("Secure_V2_UpdateFrameInfo: Secure_V2_MemCreate failed (ret=0x%x, handle=0x%x)",
                          cr, new_handle);
                }
            }
        }
    }

    munmap(block, map_len);
    return 0;
}

/* Caller derives free_slots = 8 - (allocated + vdec_queued). */
uint32_t Secure_V2_GetFreeBlockCount(void *sess, int dmabuf_fd, int min_size,
                                     int *pAllocatedCount, int *pMaxCount) {
    (void)sess;
    (void)dmabuf_fd;
    (void)min_size;
    if (pAllocatedCount) *pAllocatedCount = 0;
    if (pMaxCount) *pMaxCount = 8;
    return 0;
}
