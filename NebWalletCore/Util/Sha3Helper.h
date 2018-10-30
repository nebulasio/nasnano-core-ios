//
//  Sha3Helper.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/13.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sha3Helper : NSObject
+ (NSString *)sha3256:(NSString *)data;
+ (NSString *)sha3256WithArray:(NSArray<NSString *> *)array;
@end
