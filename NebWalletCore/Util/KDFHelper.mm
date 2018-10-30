//
//  KDFHelper.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/12.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "Util.h"
#import "KDFHelper.h"
#import "libscrypt.h"

@implementation KDFHelper

+ (NSString *)kdfWithPBKDF2Salt:(NSString *)salt pwd:(NSString *)pwd rounds:(NSUInteger)rounds len:(NSUInteger)len prf:(CCPseudoRandomAlgorithm)prf {
    NSData *saltData = [salt hexToData];
    NSData *passwordData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hashKeyData = [NSMutableData dataWithLength:len];
    CCKeyDerivationPBKDF(
                         kCCPBKDF2,
                         (const char *) passwordData.bytes, passwordData.length,
                         (uint8_t *) saltData.bytes, saltData.length,
                         prf, (uint32_t)rounds, // prf: kCCPRFHmacAlgSHA256
                         (uint8_t *) hashKeyData.mutableBytes, hashKeyData.length
                         );
    return hashKeyData.toHex;
}

+ (NSString *)kdfWithScryptSalt:(NSString *)salt pwd:(NSString *)pwd n:(NSUInteger)n r:(NSUInteger)r p:(NSUInteger)p len:(NSUInteger)len {
    NSData *saltData = [salt hexToData];
    NSData *passwordData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hashKeyData = [NSMutableData dataWithLength:len];
    libscrypt_scrypt(
                     (uint8_t *) passwordData.bytes, (size_t) passwordData.length,
                     (uint8_t *) saltData.bytes, (size_t) saltData.length,
                     (uint64_t) n, (uint32_t) r, (uint32_t) p,
                     (uint8_t *) hashKeyData.bytes, (size_t) hashKeyData.length
                     );
    return hashKeyData.toHex;
}

@end
