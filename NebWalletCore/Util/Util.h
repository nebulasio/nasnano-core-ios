//
//  Util.h
//  NebWalletCore
//
//  Created by 郭平 on 2018/10/29.
//  Copyright © 2018 郭平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Ext.h"
#import "NSString+Codes.h"
#import "NSString+Security.h"
#import "NSData+Codes.h"
#import "NSData+Security.h"
#import "JsonUtil.h"
#import "ArrayType.h"

#define STRING(format, args...) [NSString stringWithFormat:format, ##args]
#define STR(a)                  [NSString stringWithFormat:@"%@",(a)]
