//
//  Secp256k1Helper.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Secp256Key.h"

@interface Secp256k1Helper : NSObject
+ (NSString *)getPubKeyFromPrivateKey:(NSString *)privateKey compressed:(BOOL)compressed;
+ (BOOL)verifyPrivatekey:(NSString *)privateKey;
+ (NSString *)signWithHash:(NSString *)hash privateKey:(NSString *)privateKey;
+ (BOOL)verifySignature:(NSString *)signature withPubKey:(NSString *)pubKey compressed:(BOOL)compressed hash:(NSString *)hash;
+ (NSString *)signRecoveryHash:(NSString *)hash privateKey:(NSString *)privateKey;
+ (BOOL)verifyRecoverableSignature:(NSString *)signature withHash:(NSString *)hash address:(NSString *)address addressCreator:(NSString *(^)(NSString *pubKey))addrCreator;
@end
