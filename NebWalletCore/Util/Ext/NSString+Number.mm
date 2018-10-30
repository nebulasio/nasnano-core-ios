//
//  NSString+Number.m
//  GpFramework
//
//  Created by 郭平 on 2018/2/8.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Util.h"
#import "mini-gmp.h"
#import "Util.h"

@implementation NSString(Number)

- (NSString *)addNumber:(NSString *)number {
    if ([NSString isEmpty:number]) {
        return self;
    }
    NSString *s = self.trimNumber;
    number = number.trimNumber;
    if ([@"0" isEqualToString:number]) {
        return self;
    }
    NSInteger n = MAX(s.decimalLen, number.decimalLen);
    NSString *n1 = [s mulPower10:n];
    NSString *n2 = [number mulPower10:n];
    mpz_t bn1, bn2;
    mpz_init_set_str(bn1, [n1 cStringUsingEncoding:NSUTF8StringEncoding], 10);
    mpz_init_set_str(bn2, [n2 cStringUsingEncoding:NSUTF8StringEncoding] , 10);
    mpz_add(bn1, bn1, bn2);
    NSString *r = [self mpzStr:bn1];
    mpz_clear(bn1);
    mpz_clear(bn2);
    return [r divPower10:n];
}

- (NSString *)subNumber:(NSString *)number {
    if ([NSString isEmpty:number]) {
        return self;
    }
    NSString *s = self.trimNumber;
    number = number.trimNumber;
    if ([@"0" isEqualToString:number]) {
        return self;
    }
    NSInteger n = MAX(s.decimalLen, number.decimalLen);
    NSString *n1 = [s mulPower10:n];
    NSString *n2 = [number mulPower10:n];
    mpz_t bn1, bn2;
    mpz_init_set_str(bn1, [n1 cStringUsingEncoding:NSUTF8StringEncoding], 10);
    mpz_init_set_str(bn2, [n2 cStringUsingEncoding:NSUTF8StringEncoding] , 10);
    mpz_sub(bn1, bn1, bn2);
    NSString *r = [self mpzStr:bn1];
    mpz_clear(bn1);
    mpz_clear(bn2);
    return [r divPower10:n];
}

- (NSString *)mulNumber:(NSString *)number {
    if ([NSString isEmpty:number] || [NSString isEmpty:self]) {
        return @"0";
    }
    NSString *s = self.trimNumber;
    number = number.trimNumber;
    if ([@"0" isEqualToString:s] || [@"0" isEqualToString:number]) {
        return @"0";
    }
    NSInteger len1 = s.decimalLen, len2 = number.decimalLen;
    NSString *n1 = [s mulPower10:len1];
    NSString *n2 = [number mulPower10:len2];
    mpz_t bn1, bn2;
    mpz_init_set_str(bn1, [n1 cStringUsingEncoding:NSUTF8StringEncoding], 10);
    mpz_init_set_str(bn2, [n2 cStringUsingEncoding:NSUTF8StringEncoding] , 10);
    mpz_mul(bn1, bn1, bn2);
    NSString *r = [self mpzStr:bn1];
    mpz_clear(bn1);
    mpz_clear(bn2);
    return [r divPower10:len1 + len2];
}

- (NSString *)mulPower10:(NSInteger)number {
    NSString *s = self.trimNumber;
    if ([@"0" isEqualToString:s]) {
        return s;
    }
    NSInteger loc = [s rangeOfString:@"."].location;
    if (loc == NSNotFound) {
        return STRING(@"%@%@", s, [@"" padLeft:@"0" length:number]);
    } else {
        NSString *decimal = [s substringFromIndex:loc + 1];
        if (number >= decimal.length) {
            s = [s stringByReplacingOccurrencesOfString:@"." withString:@""];
            return STRING(@"%@%@", s, [@"" padLeft:@"0" length:number - decimal.length]);
        } else {
            return STRING(@"%@%@.%@", [s substringToIndex:loc], [decimal substringToIndex:number], [decimal substringFromIndex:number]);
        }
    }
}

- (NSString *)divPower10:(NSInteger)n {
    if (n == 0) {
        return self;
    }
    NSString *s = self.trimNumber;
    if ([@"0" isEqualToString:s]) {
        return s;
    }
    NSString *integer, *decimal;
    NSInteger loc = [s rangeOfString:@"."].location;
    if (loc == NSNotFound) {
        integer = s;
        decimal = @"0";
    } else {
        integer = [s substringToIndex:loc];
        decimal = [s substringFromIndex:loc + 1];
    }
    if (integer.length <= n) {
        integer = STRING(@"0.%@", [integer padLeft:@"0" length:n]);
    } else {
        NSInteger i = integer.length - n;
        integer = STRING(@"%@.%@", [integer substringToIndex:i], [integer substringFromIndex:i]);
    }
    NSString *r = STRING(@"%@%@", integer, decimal);
    return r.trimNumber;
}

- (NSComparisonResult)compareNumber:(NSString *)number {
    NSString *s = self.trimNumber;
    number = number ? number.trimNumber : @"0";
    NSInteger n = MAX(s.decimalLen, number.decimalLen);
    NSString *n1 = [s mulPower10:n].trimNumber;
    NSString *n2 = [number mulPower10:n].trimNumber;
    mpz_t bn1, bn2;
    mpz_init_set_str(bn1, [n1 cStringUsingEncoding:NSUTF8StringEncoding], 10);
    mpz_init_set_str(bn2, [n2 cStringUsingEncoding:NSUTF8StringEncoding], 10);
    NSComparisonResult r = (NSComparisonResult) mpz_cmp(bn1, bn2);
    mpz_clear(bn1);
    mpz_clear(bn2);
    return r;
}

- (NSString *)trimNumber {
    NSString *s = self.trim;
    s = [s trimStartWithChars:@"0"];
    if ([s rangeOfString:@"."].location != NSNotFound) {
        s = [[s trimEndWithChars:@"0"] trimEndWithChars:@"."];
    }
    if ([s hasPrefix:@"."]) {
        s = STRING(@"0%@", s);
    }
    if ([NSString isEmpty:s]) {
        s = @"0";
    }
    return s;
}

- (NSString *)displayNumberWithPrecision:(NSInteger)precision minDecimalLen:(NSInteger)minDecimalLen withoutZero:(BOOL)withoutZero {
    NSInteger len = [self displayLenWithNumber:self precision:precision withoutZero:withoutZero];
    return [[self roundNumber:len] formatNumber:minDecimalLen];
}

- (NSString *)roundNumber:(NSInteger)number {
    NSInteger loc = [self rangeOfString:@"."].location;
    if (loc == NSNotFound) {
        return self;
    }
    NSString *s = [[self substringFromIndex:loc + 1] trimEndWithChars:@"0"];
    if (s.length > number) {
        s = [s substringToIndex:number];
    }
    if ([NSString isEmpty:s]) {
        s = @"0";
    }
    return STRING(@"%@.%@", [self substringToIndex:loc], s);
}

- (NSString *)formatNumber:(NSInteger)minDecimalLen {
    NSString *s = self.trimNumber;
    NSString *integer = nil, *decimal = nil;
    NSInteger loc = [s rangeOfString:@"."].location;
    if (loc == NSNotFound) {
        integer = s;
        decimal = @"";
    } else {
        integer = [s substringToIndex:loc];
        decimal = [s substringFromIndex:loc + 1];
    }
    
    decimal = [decimal padRight:@"0" length:minDecimalLen];
    
    NSMutableString *r = [[NSMutableString alloc] initWithCapacity:s.length];
    NSInteger i = integer.length % 3;
    if (i > 0) {
        [r appendString:[s substringToIndex:i]];
        [r appendString:@","];
    }
    while (i < integer.length) {
        [r appendString:[s substringWithRange:NSMakeRange(i, 3)]];
        [r appendString:@","];
        i += 3;
    }
    [r deleteCharactersInRange:NSMakeRange(r.length - 1, 1)];
    return STRING(@"%@.%@", r, decimal);
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

- (NSInteger)decimalLen {
    NSInteger loc = [self rangeOfString:@"."].location;
    if (loc == NSNotFound) {
        return 0;
    }
    return self.length - 1 - loc;
}

- (NSInteger)displayLenWithNumber:(NSString *)number precision:(NSInteger)precision withoutZero:(BOOL)withoutZero {
    if (!withoutZero) {
        return precision;
    }
    NSRange r = [number rangeOfString:@"."];
    if ((int)r.location < 0) {
        return precision;
    }
    NSData *d = [number dataUsingEncoding:NSUTF8StringEncoding];
    for (UInt64 i = r.location + 1; i < d.length; ++i) {
        char c = ((char *)d.bytes)[i];
        if (c != '0') {
            return i + precision - 1 - r.location;
        }
    }
    return precision;
}

@end
