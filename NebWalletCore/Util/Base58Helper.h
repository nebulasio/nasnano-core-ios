//
//  Base58Helper.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base58Helper : NSObject
+ (BOOL)isBase58String:(NSString *)strBase58;
+ (BOOL)isBase58CheckString:(NSString *)strBase58;
+ (NSString *)base58FromHexString:(NSString *)hexString;
+ (NSString *)base58CheckFromHexString:(NSString *)hexString;
+ (NSString *)hexStringFromBase58:(NSString *)base58;
+ (NSString *)hexStringFromBase58Check:(NSString *)base58Check;
@end
