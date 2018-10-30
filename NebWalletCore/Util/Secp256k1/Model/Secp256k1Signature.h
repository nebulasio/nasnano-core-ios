//
//  Secp256k1Signature.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/16.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Secp256k1Signature : NSObject
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *r;
@property (nonatomic, copy) NSString *s;
@property (nonatomic, assign) NSInteger v;
@end
