//
//  NSString+SHA.h
//  GpFramework
//
//  Created by 郭平 on 2018/3/3.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Security)

- (NSString *)sha1;
- (NSString *)sha224;
- (NSString *)sha256;
- (NSString *)sha384;
- (NSString *)sha512;

- (NSString *)hexSha1;
- (NSString *)hexSha224;
- (NSString *)hexSha256;
- (NSString *)hexSha384;
- (NSString *)hexSha512;

@end
