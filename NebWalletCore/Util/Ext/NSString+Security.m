//
//  NSString+SHA.m
//  GpFramework
//
//  Created by 郭平 on 2018/3/3.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Security.h"
#import "NSData+Security.h"
#import "NSData+Codes.h"
#import "NSString+Codes.h"

@implementation NSString(Security)

- (NSString*)sha1 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    return [data sha1].toHex;
}

- (NSString*)sha224 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    return [data sha224].toHex;
}

- (NSString*)sha256 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    return [data sha256].toHex;
}

- (NSString*)sha384 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    return [data sha384].toHex;
}

- (NSString*)sha512 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    return [data sha512].toHex;
}

-(NSString *) hexSha1 {
    return [[self hexToData] sha1].toHex;
}

-(NSString *) hexSha224 {
    return [[self hexToData] sha224].toHex;
}

-(NSString *) hexSha256 {
    return [[self hexToData] sha256].toHex;
}

-(NSString *) hexSha384 {
    return [[self hexToData] sha384].toHex;
}

-(NSString *) hexSha512 {
    return [[self hexToData] sha512].toHex;
}


@end
