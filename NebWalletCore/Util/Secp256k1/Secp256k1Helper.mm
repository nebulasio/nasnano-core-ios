//
//  Secp256k1Helper.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/10.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import "Util.h"
#import "Secp256k1Helper.h"
#import "gp_secp256k1.h"
#import "Sha3Helper.h"

@implementation Secp256k1Helper

static NSLock *_lock;

+ (void)initialize {
    [super initialize];
    _lock = [[NSLock alloc] init];
}

+ (NSString *)getPubKeyFromPrivateKey:(NSString *)privateKey compressed:(BOOL)compressed {
    [_lock lock];
    ecc_start();
    uint8_t pubKey[100];
    size_t pubKeyLen = sizeof(pubKey) / sizeof(uint8_t);
    NSString *r = nil;
    if(ecc_get_pubkey((uint8_t *) [privateKey hexToData].bytes, pubKey, &pubKeyLen, compressed)) {
        r = [NSData dataWithBytes:pubKey length:pubKeyLen].toHex;
    }
    ecc_stop();
    [_lock unlock];
    return r;
}

+ (BOOL)verifyPrivatekey:(NSString *)privateKey {
    [_lock lock];
    ecc_start();
    NSData *data = [privateKey hexToData];
    BOOL r = ecc_verify_privatekey((uint8_t *)data.bytes);
    ecc_stop();
    [_lock unlock];
    return r;
}

+ (NSString *)signWithHash:(NSString *)hash privateKey:(NSString *)privateKey {
    [_lock lock];
    ecc_start();
    uint8_t *pkData = (uint8_t *)[privateKey hexToData].bytes;
    uint8_t *hashData = (uint8_t *)[hash hexToData].bytes;
    uint8_t signature[100];
    NSString *r = nil;
    size_t len = sizeof(signature) / sizeof(uint8_t);
    if(ecc_sign(pkData, hashData, signature, &len)) {
        r = [NSData dataWithBytes:signature length:len].toHex;
    }
    ecc_stop();
    [_lock unlock];
    return r;
}

+ (BOOL)verifySignature:(NSString *)signature withPubKey:(NSString *)pubKey compressed:(BOOL)compressed hash:(NSString *)hash {
    [_lock lock];
    ecc_start();
    uint8_t *dPubKey = (uint8_t *) [pubKey hexToData].bytes;
    uint8_t *dHash = (uint8_t *) [hash hexToData].bytes;
    NSData *dSignature = [signature hexToData];
    bool r = ecc_verify_sig(dPubKey, compressed, dHash, (uint8_t *) dSignature.bytes, dSignature.length);
    ecc_stop();
    [_lock unlock];
    return r;
}

+ (NSString *)signRecoveryHash:(NSString *)hash privateKey:(NSString *)privateKey {
    [_lock lock];
    ecc_start();
    uint8_t *pkData = (uint8_t *)[privateKey hexToData].bytes;
    uint8_t *hashData = (uint8_t *)[hash hexToData].bytes;
    uint8_t signature[64];
    NSString *r = nil;
    int v;
    if(ecc_sign_recovery(pkData, hashData, signature, &v)) {
        NSString *strV = [[STR(@(v)) decimalToHex] padLeft:@"0" length:2];
        r = STRING(@"%@%@", [NSData dataWithBytes:signature length:64].toHex, strV);
    }
    ecc_stop();
    [_lock unlock];
    return r;
}

+ (BOOL)verifyRecoverableSignature:(NSString *)signature withHash:(NSString *)hash address:(NSString *)address addressCreator:(NSString *(^)(NSString *pubKey))addrCreator {
    [_lock lock];
    ecc_start();
    uint8_t *dHash = (uint8_t *) [hash hexToData].bytes;
    NSData *dSignature = [signature hexToData];
    int v = (int) [[signature substringFromIndex:signature.length - 2] hexToInt];
    uint8_t pubKey[100];
    size_t pubKeyLen = 100;
    bool r = true;
    bool compressed;
    if (!ecc_verify_sig_recovery(dHash, (uint8_t *) dSignature.bytes, v, pubKey, &pubKeyLen, &compressed)) {
        r = false;
    } else {
        NSString *strPubKey = [NSData dataWithBytes:pubKey length:pubKeyLen].toHex;
        NSString *addr = addrCreator(strPubKey);
        r = [address isEqualToString:addr];
    }
    ecc_stop();
    [_lock unlock];
    return r;
}


@end
