//
//  EthKey.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/11.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "Util.h"
#import "NebAccount.h"
#import "Secp256Key.h"
#import "Secp256k1Helper.h"
#import "KDFHelper.h"
#import "NebKeystore.h"
#import "NebTransaction.h"
#import "Sha3Helper.h"
#import "RMD160Helper.h"
#import "Base58Helper.h"
#import "NebTransactionData.h"

#define ADDRESS_PREFIX 25
#define ADDRESS_NORMAL_TYPE 87

@interface NebAccount() {
    NSString *_address;
    NSString *_compressedPublicKey;
    NSString *_uncompressedPublicKey;
}
@end

@implementation NebAccount

- (instancetype)init {
    if (self = [super init]) {
        _privateKey = [NSData randomDataWithLen:32].toHex;
    }
    return self;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey {
    if (self = [super init]) {
        if (!privateKey || ![privateKey.lowercaseString match:@"^[\\dabcdef]{64}$"]) {
            return nil;
        }
        _privateKey = privateKey;
    }
    return self;
}

- (instancetype)initWithKeystore:(NSString *)keystore pwd:(NSString *)pwd {
    NebKeystore *k = [NebKeystore fromJson:keystore];
    if (!k || !k.check) {
        [NSException raise:@"Keystore error" format:@"Keystore: %@", keystore];
        return nil;
    }
    NSString *privateKey = [k privateKeyWithPwd:pwd];
    if ([NSString isEmpty:privateKey] || ![Secp256k1Helper verifyPrivatekey:privateKey]) {
        [NSException raise:@"Password error" format:@"Password: %@", pwd];
        return nil;
    }
    if (self = [super init]) {
        _privateKey = privateKey;
    }
    return self;
}


#pragma mark - secp256k1

- (NSString *)compressedPublicKey {
    if (!_compressedPublicKey) {
        _compressedPublicKey = [Secp256k1Helper getPubKeyFromPrivateKey:self.privateKey compressed:YES];
    }
    return _compressedPublicKey;
}

- (NSString *)uncompressedPublicKey {
    if (!_uncompressedPublicKey) {
        _uncompressedPublicKey = [Secp256k1Helper getPubKeyFromPrivateKey:self.privateKey compressed:NO];
    }
    return _uncompressedPublicKey;
}

- (Secp256k1Signature *)signHash:(NSString *)hash {
    Secp256k1Signature *sig = [Secp256k1Signature new];
    sig.signature = [Secp256k1Helper signRecoveryHash:hash privateKey:self.privateKey];
    sig.r = [sig.signature substringWithRange:NSMakeRange(0, 64)];
    sig.s = [sig.signature substringWithRange:NSMakeRange(64, 64)];
    sig.v = [[sig.signature substringWithRange:NSMakeRange(128, 2)] hexToInt];
    return sig;
}

- (BOOL)verifySignature:(NSString *)signature hash:(NSString *)hash address:(NSString *)address addressCreator:(NSString *(^)(NSString *))addressCreator {
    return [Secp256k1Helper verifyRecoverableSignature:signature withHash:hash address:address addressCreator:addressCreator];
}


#pragma mark - public

- (NSString *)address {
    if (!_address) {
        NSString *content = [Sha3Helper sha3256:self.uncompressedPublicKey];
        content = [RMD160Helper rmd160:content];
        content = STRING(@"%@%@%@", STR(@ADDRESS_PREFIX).decimalToHex, STR(@ADDRESS_NORMAL_TYPE).decimalToHex, content);
        NSString *checkSum = [[Sha3Helper sha3256:content] substringToIndex:8];
        _address = [Base58Helper base58FromHexString:STRING(@"%@%@", content, checkSum)];
    }
    return _address;
}

- (NSString *)createNewKeystoreWithPwd:(NSString *)pwd {
    NebKeystore *keystore = [NebKeystore fromPrivateKey:self.privateKey pwd:pwd];
    if (keystore) {
        keystore.address = self.address;
        return keystore.json;
    }
    return nil;
}

- (NSString *)signTransaction:(NebTransaction *)transaction {
    NebTransactionData *data = [[NebTransactionData alloc] initWithTransaction:transaction];
    data.sign = [self signHash:data.txHash].signature;
    return data.encode;
}


@end
