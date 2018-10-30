//
//  base58.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#ifndef Base58_h
#define Base58_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
    extern bool (*b58_sha256_impl)(uint8_t *, const uint8_t *, size_t);
    
    extern bool b58tobin(uint8_t *bin, size_t *binsz, const uint8_t *b58, size_t b58sz);
    extern int b58check(const uint8_t *bin, size_t binsz, const uint8_t *b58, size_t b58sz);
    
    extern bool b58enc(uint8_t *b58, size_t *b58sz, const uint8_t *bin, size_t binsz);
    extern bool b58check_enc(uint8_t *b58c, size_t *b58c_sz, uint8_t ver, const uint8_t *data, size_t datasz);
    
#ifdef __cplusplus
}
#endif

#endif /* Base58_h */
