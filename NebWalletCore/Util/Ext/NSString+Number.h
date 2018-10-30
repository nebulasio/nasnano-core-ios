//
//  NSString+Number.h
//  GpFramework
//
//  Created by 郭平 on 2018/2/8.
//  Copyright © 2018年 nebulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Number)

// 加（必须十进制格式）
- (NSString *)addNumber:(NSString *)number;

// 减（必须十进制格式）
- (NSString *)subNumber:(NSString *)number;

// 乘（必须十进制格式）
- (NSString *)mulNumber:(NSString *)number;

// 乘10的n次方（必须十进制格式）
- (NSString *)mulPower10:(NSInteger)n;

// 除以10的n次方（必须十进制格式）
- (NSString *)divPower10:(NSInteger)n;

// 比较大小 (必须十进制格式)
- (NSComparisonResult)compareNumber:(NSString *)number;

// 去多余的0
- (NSString *)trimNumber;


/**
 格式化数字
 @param precision 保留小数位数
 @param minDecimalLen 最短小数位数（即使最后位是0）
 @param withoutZero 保留小数位数是否跳过小数部分开始的0
 @return 格式化后的数字
 */
- (NSString *)displayNumberWithPrecision:(NSInteger)precision minDecimalLen:(NSInteger)minDecimalLen withoutZero:(BOOL)withoutZero;

// 保留number位小数（不四舍五入，只舍）
- (NSString *)roundNumber:(NSInteger)number;

// 格式化数字，千分位，最短长度小数（即使最后位是0）
- (NSString *)formatNumber:(NSInteger)minDecimalLen;

@end
