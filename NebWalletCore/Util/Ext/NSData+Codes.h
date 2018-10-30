//
//  NSData+Ext.h
//  GpFramework
//
//  Created by 郭平 on 2017/11/10.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Codes)

+ (NSData *)randomDataWithLen:(NSInteger)len;

- (NSString *)base64EncodedString;

- (NSString *)toHex;

@end
