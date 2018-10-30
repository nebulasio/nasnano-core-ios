//
//  NebKeystore.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/12.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NebKeystoreCipherParams : NSObject
@property (nonatomic, copy) NSString *iv;
@end


@interface NebKeystoreKdfParams : NSObject
@property (nonatomic, assign) NSUInteger dklen;
@property (nonatomic, copy) NSString *salt;

@property (nonatomic, assign) NSUInteger n;
@property (nonatomic, assign) NSUInteger r;
@property (nonatomic, assign) NSUInteger p;

@property (nonatomic, assign) NSUInteger c;
@property (nonatomic, copy) NSString *prf;
@end


@interface NebKeystoreCrypto : NSObject
@property (nonatomic, copy) NSString *cipher;
@property (nonatomic, copy) NSString *ciphertext;
@property (nonatomic, strong) NebKeystoreCipherParams *cipherparams;

@property (nonatomic, copy) NSString *kdf;
@property (nonatomic, copy) NSString *mac;
@property (nonatomic, strong) NebKeystoreKdfParams *kdfparams;
@property (nonatomic, copy) NSString *machash;

@property (nonatomic, assign, readonly) BOOL isScrypt;
@end


@interface NebKeystore : NSObject

+ (NebKeystore *)fromJson:(NSString *)json;

+ (NebKeystore *)fromPrivateKey:(NSString *)privateKey pwd:(NSString *)pwd;

@property (nonatomic, copy) NSString *keyId;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) NebKeystoreCrypto *crypto;

- (NSString *)json;
- (BOOL)check;
- (NSString *)privateKeyWithPwd:(NSString *)pwd;

@end
