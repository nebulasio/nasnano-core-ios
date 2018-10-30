//
//  NSString+Codes.m
//  GpFramework
//
//  Created by 郭平 on 2018/8/2.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Util.h"
#import "mini-gmp.h"

@implementation NSString (Codes)

- (NSInteger)hexToInt {
    NSString *hex = self.lowercaseString;
    if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }
    mpz_t bn;
    mpz_init_set_str(bn, [hex cStringUsingEncoding:NSUTF8StringEncoding], 16);
    NSString *r = [self mpzStr:bn base:10];
    mpz_clear(bn);
    return r.integerValue;
}

- (NSData *)toData {
    const char *c = [self cStringUsingEncoding:NSUTF8StringEncoding];
    return [NSData dataWithBytes:c length:strlen(c)];
}

- (NSData *)hexToData {
    NSString *n = self.lowercaseString;
    if ([n hasPrefix:@"0x"]) {
        n = [n substringFromIndex:2];
    }
    if (n.length % 2 != 0) {
        n = STRING(@"0%@", n);
    }
    NSMutableData *d = [NSMutableData dataWithLength:n.length / 2];
    for (int i = 0; i < d.length; ++i) {
        NSString *strV = [n substringWithRange:NSMakeRange(i * 2, 2)];
        ((uint8_t *)d.mutableBytes)[i] = (uint8_t) [strV hexToDecimal].integerValue;
    }
    return d;
}

// 16进制转十进制
- (NSString *)hexToDecimal {
    NSString *hex = self.lowercaseString;
    if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }
    mpz_t bn;
    mpz_init_set_str(bn, [hex cStringUsingEncoding:NSUTF8StringEncoding], 16);
    NSString *r = [self mpzStr:bn base:10];
    mpz_clear(bn);
    return r;
}

- (NSString *)decimalToHex {
    mpz_t bn;
    mpz_init_set_str(bn, [self cStringUsingEncoding:NSUTF8StringEncoding], 10);
    NSString *r = [self mpzStr:bn base:16];
    mpz_clear(bn);
    return r;
}

- (NSData *)base64StringDecode {
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)urlEncode {
    NSArray *escapeChars = @[
        @";", @"/", @"?", @":",
        @"@", @"&", @"=", @"+", @"$", @",", @"!",
        @"'", @"(", @")", @"*", @"-", @"~", @"_"
    ];
    NSArray *replaceChars = @[
        @"%3B", @"%2F", @"%3F", @"%3A",
        @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
        @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F"
    ];
    
    int len = (int) [escapeChars count];
    NSString *tempStr = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (tempStr == nil) {
        return nil;
    }
    NSMutableString *temp = [tempStr mutableCopy];
    int i;
    for (i = 0; i < len; i++) {
        [temp
         replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
         withString:[replaceChars objectAtIndex:i]
         options:NSLiteralSearch
         range:NSMakeRange(0, [temp length])];
    }
    NSString *outStr = [NSString stringWithString:temp];
    return outStr;
}

- (NSString *)urlDecode {
    NSArray *escapeChars = @[
        @";", @"/", @"?", @":",
        @"@", @"&", @"=", @"+", @"$", @",", @"!",
        @"'", @"(", @")", @"*", @"-", @"~", @"_"
    ];
    NSArray *replaceChars = @[
        @"%3B", @"%2F", @"%3F", @"%3A",
        @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
        @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F"
    ];
    int len = (int) [escapeChars count];
    NSMutableString *temp = [self mutableCopy];
    int i;
    for (i = 0; i < len; i++) {
        [temp
         replaceOccurrencesOfString:[replaceChars objectAtIndex:i]
         withString:[escapeChars objectAtIndex:i]
         options:NSLiteralSearch
         range:NSMakeRange(0, [temp length])];
    }
    NSString *outStr = [NSString stringWithString:temp];
    return [outStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - private

- (NSString *)mpzStr:(mpz_t)bn {
    return [self mpzStr:bn base:10];
}

- (NSString *)mpzStr:(mpz_t)bn base:(NSInteger)base {
    char *n = mpz_get_str(NULL, (int) base, bn);
    NSString *r = [NSString stringWithUTF8String:n];
    free(n);
    return r;
}

@end
