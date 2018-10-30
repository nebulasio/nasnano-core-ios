//
//  Base58Helper.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Base58Helper.h"
#import "base58.h"
#import "Util.h"

#define kBase58BufferLen 1000

@implementation Base58Helper

+ (void)initialize {
    [super initialize];
    b58_sha256_impl = sha256;
}

+ (BOOL)isBase58String:(NSString *)strBase58 {
    return [strBase58 match:@"^[1-9A-HJ-NP-Za-km-z]+$"];
}

+ (BOOL)isBase58CheckString:(NSString *)strBase58 {
    if (![self isBase58String:strBase58]) {
        return NO;
    }
    NSString *fullData = [self hexStringFromBase58:strBase58];
    if (fullData.length < 8) {
        return NO;
    }
    NSString *data = [fullData substringToIndex:fullData.length - 8];
    NSString *checksum = [[[data hexSha256] hexSha256] substringToIndex:8];
    if (![checksum isEqualToString:[fullData substringFromIndex:fullData.length - 8]]) {
        return YES;
    }
    return NO;
}

+ (NSString *)base58FromHexString:(NSString *)hexString {
    NSData *d = [hexString hexToData];
    uint8_t *data = (uint8_t *)d.bytes;
    uint8_t data58[kBase58BufferLen];
    size_t data58Len = sizeof(data58) / sizeof(uint8_t);
    b58enc(data58, &data58Len, data, d.length);
    if (data58[data58Len - 1] == '\0') {
        data58Len--;
    }
    NSData *p58Data = [NSData dataWithBytes:data58 length:data58Len];
    return [[NSString alloc] initWithData:p58Data encoding:NSUTF8StringEncoding];
}

+ (NSString *)base58CheckFromHexString:(NSString *)hexString {
    NSString *hex = hexString.lowercaseString;
    if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }
    NSString *checksum = [[[hex hexSha256] hexSha256] substringToIndex:8];
    hex = STRING(@"%@%@", hex, checksum);
    return [self base58FromHexString:hex];
}

+ (NSString *)hexStringFromBase58:(NSString *)base58 {
    NSData *data58 = [base58.trim dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t bin[kBase58BufferLen];
    size_t binLen = sizeof(bin) / sizeof(uint8_t);
    if(b58tobin(bin, &binLen, (uint8_t *) data58.bytes, data58.length)) {
        return [NSData dataWithBytes:bin + kBase58BufferLen - binLen length:binLen].toHex;
    } else {
        return nil;
    }
}

+ (NSString *)hexStringFromBase58Check:(NSString *)base58Check {
    NSString *fullData = [self hexStringFromBase58:base58Check];
    if (fullData.length < 8) {
        return nil;
    }
    NSString *data = [fullData substringToIndex:fullData.length - 8];
    NSString *checksum = [[[data hexSha256] hexSha256] substringToIndex:8];
    if (![checksum isEqualToString:[fullData substringFromIndex:fullData.length - 8]]) {
        return nil;
    }
    return data;
}


#pragma mark - private

bool sha256(uint8_t *result, const uint8_t *data, size_t len) {
    NSData *d = [[NSData alloc] initWithBytes:data length:len];
    NSData *r = [d sha256];
    memcpy(result, r.bytes, r.length);
    return true;
}

@end
