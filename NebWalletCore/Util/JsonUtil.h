//
//  JsonUtil.h
//  GpFramework
//
//  Created by 郭平 on 2017/10/3.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ArrayType.h"

@interface JsonUtil : NSObject

+ (NSString *)serialize:(id)data;

+ (id)deserialize:(id)data type:(id)type;

- (instancetype)initWithContent:(id)content;

- (id)findWithType:(id)type path:(NSString *)path;

@end
