//
//  EthTransaction.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/6/11.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NebBinaryData : NSObject
@property (nonatomic, strong) NSData *Data;
@end

@interface NebCallData : NSObject
@property (nonatomic, copy) NSString *Function;
@property (nonatomic, copy) NSString *Args;
@end

@interface NebDeployData : NSObject
@property (nonatomic, copy) NSString *SourceType;
@property (nonatomic, copy) NSString *Source;
@property (nonatomic, copy) NSString *Args;
@end

@interface NebTransaction : NSObject
@property (nonatomic, assign) UInt32 chainId;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) UInt64 nonce;
/**
 NebBinaryData or NebCallData or NebDeployData
 */
@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSString *gasPrice;
@property (nonatomic, copy) NSString *gasLimit;
@end
