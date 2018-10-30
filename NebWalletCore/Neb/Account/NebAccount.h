//
//  EthKey.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/11.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "NebTransaction.h"

@interface NebAccount : NSObject

@property (nonatomic, copy, readonly) NSString *address;

@property (nonatomic, copy, readonly) NSString *privateKey;

- (instancetype)init;

- (instancetype)initWithPrivateKey:(NSString *)privateKey;

- (instancetype)initWithKeystore:(NSString *)keystore pwd:(NSString *)pwd;

- (NSString *)createNewKeystoreWithPwd:(NSString *)pwd;

- (NSString *)signTransaction:(NebTransaction *)transaction;

@end
