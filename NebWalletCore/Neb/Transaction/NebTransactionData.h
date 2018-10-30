//
//  NebTransactionData.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/10/30.
//  Copyright © 2018 郭平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NebTransaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface NebTransactionData : NSObject

- (instancetype)initWithTransaction:(NebTransaction *)tx;

@property (nonatomic, copy) NSString *sign;

@property (nonatomic, copy, readonly) NSString *txHash;

@property (nonatomic, copy, readonly) NSString *encode;

@end

NS_ASSUME_NONNULL_END
