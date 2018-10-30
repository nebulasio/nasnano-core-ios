//
//  KDFHelper.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/12.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDFHelper : NSObject


/**
 KDF PBKDF2

 @param salt salt description
 @param pwd pwd description
 @param rounds rounds description
 @param len len description
 @param prf prf description
 @return return hex string key
 */
+ (NSString *)kdfWithPBKDF2Salt:(NSString *)salt pwd:(NSString *)pwd rounds:(NSUInteger)rounds len:(NSUInteger)len prf:(uint32_t)prf;

/**
 KDF Scrypt

 @param salt salt description
 @param pwd pwd description
 @param n n description
 @param r r description
 @param p p description
 @param len len description
 @return return hex string key
 */
+ (NSString *)kdfWithScryptSalt:(NSString *)salt pwd:(NSString *)pwd n:(NSUInteger)n r:(NSUInteger)r p:(NSUInteger)p len:(NSUInteger)len;

@end
