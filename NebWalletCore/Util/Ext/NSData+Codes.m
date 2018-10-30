//
//  NSData+Ext.m
//  GpFramework
//
//  Created by 郭平 on 2017/11/10.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import "NSData+Codes.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData(Codes)

+ (NSData *)randomDataWithLen:(NSInteger)len {
    NSMutableData *bytes = [NSMutableData dataWithLength:len];
    int status = SecRandomCopyBytes(kSecRandomDefault, bytes.length, bytes.mutableBytes);
    if (status != -1) {
        return bytes;
    } else {
        [NSException raise:@"Unable to get random data!"
                    format:@"Unable to get random data!"];
        return nil;
    }
}

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithOptions:0];
}

- (NSString *)toHex {
    NSMutableString* output = [NSMutableString stringWithCapacity:self.length * 2];
    for(int i = 0; i < self.length; i++) {
        [output appendFormat:@"%02x", ((uint8_t *)self.bytes)[i]];
    }
    return output;
}

@end
