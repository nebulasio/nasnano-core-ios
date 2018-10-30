//
//  Sha3Helper.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/13.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Sha3Helper.h"
#import "sha3.h"
#import "Util.h"

@implementation Sha3Helper

+ (NSString *)sha3256:(NSString *)data {
    NSData *d = [data hexToData];
    sha3_context context;
    sha3_Init256(&context);
    sha3_Update(&context, (uint8_t *) d.bytes, d.length);
    const uint8_t *hash = sha3_Finalize(&context);
    return [NSData dataWithBytes:hash length:32].toHex;
}

+ (NSString *)sha3256WithArray:(NSArray<NSString *> *)array {
    sha3_context context;
    sha3_Init256(&context);
    for (NSString *s in array) {
        NSData *d = [s hexToData];
        sha3_Update(&context, (uint8_t *) d.bytes, d.length);
    }
    const uint8_t *hash = sha3_Finalize(&context);
    return [NSData dataWithBytes:hash length:32].toHex;
}

@end
