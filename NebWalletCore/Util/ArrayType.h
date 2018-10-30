//
//  ArrayType.h
//  GpFramework
//
//  Created by 郭平 on 2017/11/2.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ARRAYTYPE(clazz) [[ArrayType alloc] initWithClass:clazz]

@interface ArrayType : NSObject
- (instancetype)initWithClass:(Class)clazz;
@property (nonatomic, weak) Class clazz;
@end
