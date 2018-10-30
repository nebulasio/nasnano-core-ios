//
//  NSData+SHA.m
//  GpFramework
//
//  Created by 郭平 on 2018/3/5.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "NSData+Security.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData(Security)

- (NSData *)md5 {
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:sizeof(digest)];
}

- (NSData*)sha1 {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

- (NSData*)sha224 {
    uint8_t digest[CC_SHA224_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
}

- (NSData*)sha256 {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData*)sha384 {
    uint8_t digest[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
}

- (NSData*)sha512 {
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(self.bytes, (uint32_t) self.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
}

@end
