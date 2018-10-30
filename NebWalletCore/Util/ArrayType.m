//
//  ArrayType.m
//  GpFramework
//
//  Created by 郭平 on 2017/11/2.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import "ArrayType.h"

@implementation ArrayType
- (instancetype)initWithClass:(Class)clazz {
    if (self = [super init]) {
        self.clazz = clazz;
    }
    return self;
}
@end
