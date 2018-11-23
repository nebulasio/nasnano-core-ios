//
//  NebTransactionData.m
//  NebWalletCore
//
//  Created by 郭平 on 2018/10/30.
//  Copyright © 2018 郭平. All rights reserved.
//

#import "NebTransactionData.h"
#import "Transaction.pbobjc.h"
#import "Sha3Helper.h"
#import "Base58Helper.h"
#import "Util.h"
#import "JsonUtil.h"

#define ALG_SECP256K1 1

#define DATA_TYPE_BINARY @"binary"
#define DATA_TYPE_DEPLOY @"deploy"
#define DATA_TYPE_CALL   @"call"

@interface Data(Ext)
@end

@implementation Data(Ext)

+ (Data *)fromTxData:(id)data {
    Data *d = [Data new];
    if (!data) {
        d.type = DATA_TYPE_BINARY;
        d.payload = nil;
        return d;
    }
    if ([data isKindOfClass:NebBinaryData.class]) {
        d.type = DATA_TYPE_BINARY;
    } else if ([data isKindOfClass:NebCallData.class]) {
        d.type = DATA_TYPE_CALL;
    } else if ([data isKindOfClass:NebDeployData.class]) {
        d.type = DATA_TYPE_DEPLOY;
    }
    d.payload = [JsonUtil serialize:data].toData;
    return d;
}

@end


@interface NebTransactionData()
@property (nonatomic, strong) NebTransaction *tx;
@property (nonatomic, strong) Data *data;
@property (nonatomic, assign) UInt64 timestamp;
@end


@implementation NebTransactionData

- (instancetype)initWithTransaction:(NebTransaction *)tx {
    if (self = [super init]) {
        self.tx = tx;
        self.data = [Data fromTxData:tx.data];
        self.timestamp = (UInt64) [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (NSString *)txHash {
    return [Sha3Helper sha3256WithArray:@[
        [Base58Helper hexStringFromBase58:self.tx.from],
        [Base58Helper hexStringFromBase58:self.tx.to],
        [self padData:self.tx.value.decimalToHex len:16],
        [self padData:STR(@(self.tx.nonce)).decimalToHex len:8],
        [self padData:STR(@(self.timestamp)).decimalToHex len:8],
        self.data.data.toHex,
        [self padData:STR(@(self.tx.chainId)).decimalToHex len:4],
        [self padData:self.tx.gasPrice.decimalToHex len:16],
        [self padData:self.tx.gasLimit.decimalToHex len:16]
    ]];
}

- (NSString *)encode {
    Transaction *tx = [Transaction new];
    tx.hash_p = [self txHash].hexToData;
    tx.from = [Base58Helper hexStringFromBase58:self.tx.from].hexToData;
    tx.to = [Base58Helper hexStringFromBase58:self.tx.to].hexToData;
    tx.value = [self padData:self.tx.value.decimalToHex len:16].hexToData;
    tx.nonce = self.tx.nonce;
    tx.timestamp = self.timestamp;
    tx.data_p = self.data;
    tx.chainId = self.tx.chainId;
    tx.gasPrice = [self padData:self.tx.gasPrice.decimalToHex len:16].hexToData;
    tx.gasLimit = [self padData:self.tx.gasLimit.decimalToHex len:16].hexToData;
    tx.alg = ALG_SECP256K1;
    tx.sign = self.sign.hexToData;
    return tx.data.base64EncodedString;
}

- (NSString *)padData:(NSString*)hexData len:(NSInteger)len {
    return [hexData padLeft:@"0" length:len * 2];
}

@end
