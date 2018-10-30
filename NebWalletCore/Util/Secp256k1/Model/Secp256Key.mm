//
//  Secp256Key.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Util.h"
#import "Secp256Key.h"
#import "gp_secp256k1.h"
#import "Secp256k1Helper.h"

@interface Secp256Key() {
    NSString *_compressedPublicKey;
    NSString *_uncompressedPublicKey;
}
@end

@implementation Secp256Key

- (instancetype)init {
    @throw
    [NSException
     exceptionWithName:@"NotSupportException"
     reason:@"Secp256Key NotSupport init"
     userInfo:nil];
}

- (instancetype)initWithRawPrivateKey:(NSString *)rawPrivateKey {
    if (self = [super init]) {
        if (![Secp256k1Helper verifyPrivatekey:rawPrivateKey]) {
            @throw
            [NSException
             exceptionWithName:@"PrivateKeyErrorFoundException"
             reason:@"rawPrivateKey error"
             userInfo:nil];
        }
        _rawPrivateKey = rawPrivateKey;
    }
    return self;
}

- (NSString *)compressedPublicKey {
    if (!_compressedPublicKey) {
        _compressedPublicKey = [Secp256k1Helper getPubKeyFromPrivateKey:self.rawPrivateKey compressed:YES];
    }
    return _compressedPublicKey;
}

- (NSString *)uncompressedPublicKey {
    if (!_uncompressedPublicKey) {
        _uncompressedPublicKey = [Secp256k1Helper getPubKeyFromPrivateKey:self.rawPrivateKey compressed:NO];
    }
    return _uncompressedPublicKey;
}

- (Secp256k1Signature *)signHash:(NSString *)hash {
    Secp256k1Signature *sig = [Secp256k1Signature new];
    sig.signature = [Secp256k1Helper signRecoveryHash:hash privateKey:self.rawPrivateKey];
    sig.r = [sig.signature substringWithRange:NSMakeRange(0, 64)];
    sig.s = [sig.signature substringWithRange:NSMakeRange(64, 64)];
    sig.v = [[sig.signature substringWithRange:NSMakeRange(128, 2)] hexToInt];
    return sig;
}

- (BOOL)verifySignature:(NSString *)signature hash:(NSString *)hash address:(NSString *)address addressCreator:(NSString *(^)(NSString *))addressCreator {
    return [Secp256k1Helper verifyRecoverableSignature:signature withHash:hash address:address addressCreator:addressCreator];
}

@end
