//
//  NSString+Codes.h
//  GpFramework
//
//  Created by 郭平 on 2018/8/2.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Codes)

- (NSInteger)hexToInt;

- (NSData *)toData;

- (NSData *)hexToData;

- (NSString *)hexToDecimal;

- (NSString *)decimalToHex;

- (NSData *)base64StringDecode;

- (NSString *)urlEncode;

- (NSString *)urlDecode;

@end
