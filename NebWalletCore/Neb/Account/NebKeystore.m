//
//  EthKeystore.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/12.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "NebKeystore.h"
#import "KDFHelper.h"
#import "Sha3Helper.h"
#import "Util.h"

#define VERSION3 3
#define VERSION_CURRENT 4

@implementation NebKeystoreCipherParams
@end


@implementation NebKeystoreKdfParams
@end


@implementation NebKeystoreCrypto
- (BOOL)isScrypt {
    return [self.kdf.lowercaseString isEqualToString:@"scrypt"];
}
@end


@implementation NebKeystore

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"keyId": @"id" };
}

+ (NebKeystore *)fromJson:(NSString *)json {
    return [JsonUtil deserialize:json type:NebKeystore.class];
}

+ (NebKeystore *)fromPrivateKey:(NSString *)privateKey pwd:(NSString *)pwd {
    NebKeystore *keystore = [NebKeystore new];
    keystore.keyId = [NSString newUUID].lowercaseString;
    keystore.version = VERSION_CURRENT;
    
    NebKeystoreCrypto *crypto = [NebKeystoreCrypto new];
    crypto.machash = @"sha3256";
    
    NebKeystoreKdfParams *kdfparams = [NebKeystoreKdfParams new];
    kdfparams.salt = [NSData randomDataWithLen:32].toHex;
    kdfparams.dklen = 32;
    
    crypto.kdf = @"script";
    kdfparams.n = 4096;
    kdfparams.r = 8;
    kdfparams.p = 1;
    
    crypto.kdfparams = kdfparams;
    
    crypto.cipher = @"aes-128-ctr";
    NebKeystoreCipherParams *cparams = [NebKeystoreCipherParams new];
    cparams.iv = [NSData randomDataWithLen:16].toHex;
    crypto.cipherparams = cparams;
    
    keystore.crypto = crypto;
    
    NSString *derivedKey = [keystore derivedKeyWithPwd:pwd];
    NSData *privateKeyData = [privateKey hexToData];
    NSData *ivData = [keystore.crypto.cipherparams.iv hexToData];
    NSData *keyData = [[derivedKey substringToIndex:32] hexToData];
    NSError *error;
    NSData *ciphertextData =
    [self
     cryptData:privateKeyData operation:kCCEncrypt mode:kCCModeCTR algorithm:kCCAlgorithmAES
     padding:ccNoPadding keyLength:kCCKeySizeAES128
     iv:ivData key:keyData error:&error];
    if (error) {
        return nil;
    }
    crypto.ciphertext = ciphertextData.toHex;
    NSString *str = STRING(@"%@%@%@%@", [derivedKey substringWithRange:NSMakeRange(32, 32)], crypto.ciphertext, cparams.iv, crypto.cipher.toData.toHex);
    crypto.mac = [Sha3Helper sha3256:str];
    
    return keystore;
}

- (BOOL)check {
    return !(
        !self.crypto ||
        !self.crypto.kdf ||
        !self.crypto.kdfparams ||
        (self.crypto.isScrypt && ![NSString isEmpty:self.crypto.kdfparams.prf] && ![@"hmac-sha256" isEqualToString:self.crypto.kdfparams.prf]) ||
        !self.crypto.mac ||
        !self.crypto.cipher ||
        !self.crypto.ciphertext ||
        !self.crypto.cipherparams);
}

- (NSString *)privateKeyWithPwd:(NSString *)pwd {
    if (![self check]) {
        return nil;
    }
    NSString *derivedKey = [self derivedKeyWithPwd:pwd];
    NSString *str = STRING(@"%@%@", [derivedKey substringFromIndex:derivedKey.length - 32], self.crypto.ciphertext);
    if (self.version == VERSION_CURRENT) {
        str = STRING(@"%@%@%@", str, self.crypto.cipherparams.iv, self.crypto.cipher.toData.toHex);
    }
    NSString *m = [Sha3Helper sha3256:str];
    if (![self.crypto.mac isEqualToString:m]) {
        return nil;
    }
    NSData *ciphertextData = [self.crypto.ciphertext hexToData];
    NSData *ivData = [self.crypto.cipherparams.iv hexToData];
    NSData *keyData = [[derivedKey substringToIndex:32] hexToData];
    NSError *error;
    NSData *privateKeyData =
    [NebKeystore
     cryptData:ciphertextData operation:kCCDecrypt mode:kCCModeCTR algorithm:kCCAlgorithmAES
     padding:ccNoPadding keyLength:kCCKeySizeAES128
     iv:ivData key:keyData error:&error];
    if (error) {
        return nil;
    }
    return privateKeyData.toHex;
}

- (NSString *)json {
    return [JsonUtil serialize:self];
}


#pragma mark - private

- (NSString *)derivedKeyWithPwd:(NSString *)pwd {
    if (self.crypto.isScrypt) {
        return [KDFHelper
                kdfWithScryptSalt:self.crypto.kdfparams.salt pwd:pwd
                n:self.crypto.kdfparams.n r:self.crypto.kdfparams.r p:self.crypto.kdfparams.p
                len:self.crypto.kdfparams.dklen];
    } else {
        return [KDFHelper
                kdfWithPBKDF2Salt:self.crypto.kdfparams.salt pwd:pwd
                rounds:self.crypto.kdfparams.c len:self.crypto.kdfparams.dklen
                prf:kCCPRFHmacAlgSHA256];
    }
}

+ (NSData *)cryptData:(NSData *)dataIn
            operation:(CCOperation)operation  // kCC Encrypt, Decrypt
                 mode:(CCMode)mode            // kCCMode ECB, CBC, CFB, CTR, OFB, RC4, CFB8
            algorithm:(CCAlgorithm)algorithm  // CCAlgorithm AES DES, 3DES, CAST, RC4, RC2, Blowfish
              padding:(CCPadding)padding      // cc NoPadding, PKCS7Padding
            keyLength:(size_t)keyLength       // kCCKeySizeAES 128, 192, 256
                   iv:(NSData *)iv            // CBC, CFB, CFB8, OFB, CTR
                  key:(NSData *)key
                error:(NSError **)error {
    if (key.length != keyLength) {
        NSLog(@"CCCryptorArgument key.length: %lu != keyLength: %zu", (unsigned long)key.length, keyLength);
        if (error) {
            *error = [NSError errorWithDomain:@"kArgumentError key length" code:key.length userInfo:nil];
        }
        return nil;
    }
    size_t dataOutMoved = 0;
    size_t dataOutMovedTotal = 0;
    CCCryptorStatus ccStatus = 0;
    CCCryptorRef cryptor = NULL;
    ccStatus = CCCryptorCreateWithMode(operation, mode, algorithm,
                                       padding,
                                       iv.bytes, key.bytes,
                                       keyLength,
                                       NULL, 0, 0, // tweak XTS mode, numRounds
                                       kCCModeOptionCTR_BE, // CCModeOptions
                                       &cryptor);
    if (cryptor == 0 || ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorCreate status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kCreateError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    size_t dataOutLength = CCCryptorGetOutputLength(cryptor, dataIn.length, true);
    NSMutableData *dataOut = [NSMutableData dataWithLength:dataOutLength];
    char *dataOutPointer = (char *)dataOut.mutableBytes;
    ccStatus = CCCryptorUpdate(cryptor,
                               dataIn.bytes, dataIn.length,
                               dataOutPointer, dataOutLength,
                               &dataOutMoved);
    dataOutMovedTotal += dataOutMoved;
    if (ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorUpdate status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kUpdateError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    ccStatus = CCCryptorFinal(cryptor,
                              dataOutPointer + dataOutMoved, dataOutLength - dataOutMoved,
                              &dataOutMoved);
    if (ccStatus != kCCSuccess) {
        NSLog(@"CCCryptorFinal status: %d", ccStatus);
        if (error) {
            *error = [NSError errorWithDomain:@"kFinalError" code:ccStatus userInfo:nil];
        }
        CCCryptorRelease(cryptor);
        return nil;
    }
    CCCryptorRelease(cryptor);
    dataOutMovedTotal += dataOutMoved;
    dataOut.length = dataOutMovedTotal;
    return dataOut;
}

@end
