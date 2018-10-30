//
//  Secp256Key.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Secp256k1Signature.h"

@interface Secp256Key : NSObject
- (instancetype)initWithRawPrivateKey:(NSString *)rawPrivateKey;
@property (nonatomic, copy, readonly) NSString *rawPrivateKey;
@property (nonatomic, copy, readonly) NSString *compressedPublicKey;
@property (nonatomic, copy, readonly) NSString *uncompressedPublicKey;
- (Secp256k1Signature *)signHash:(NSString *)hash;
- (BOOL)verifySignature:(NSString *)signature hash:(NSString *)hash address:(NSString *)address addressCreator:(NSString *(^)(NSString *))addressCreator;
@end
