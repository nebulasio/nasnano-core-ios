//
//  NSData+SHA.h
//  GpFramework
//
//  Created by 郭平 on 2018/3/5.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Security)

- (NSData *)md5;

- (NSData *)sha1;

- (NSData *)sha224;

- (NSData *)sha256;

- (NSData *)sha384;

- (NSData *)sha512;

@end
