//
//  RMD160Helper.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/4/11.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMD160Helper : NSObject
+ (NSString *)rmd160:(NSString *)hexStr;
@end
