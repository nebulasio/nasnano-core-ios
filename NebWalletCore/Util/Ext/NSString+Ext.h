#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define STRING(format, args...) [NSString stringWithFormat:format, ##args]
#define STR(a)                  [NSString stringWithFormat:@"%@",(a)]

@interface NSString(Ext)

+ (BOOL)isEmpty:(NSString *)str;

+ (NSString *)newUUID;

- (BOOL)match:(NSString *)reg;

- (NSArray<NSString *> *)matches:(NSString *)reg;

//字符替换
- (NSString *)stringByReplaceString:(NSString *)rs withCharacter:(char)c;

//去空格
- (NSString *)trim;

//去两端指定字符
- (NSString *)trimWithChars:(NSString *)chars;

//去左端指定字符
-(NSString*)trimStartWithChars:(NSString*)characters;

//去右端指定字符
-(NSString*)trimEndWithChars:(NSString*)characters;

// 去掉字符中间的连续多个空格, 只保留一个.
- (NSString *)stringByTrimmingWhitespace;

- (BOOL)containsString:(NSString *)string;

- (NSString *)padLeft:(NSString *)ch length:(NSInteger)length;

- (NSString *)padRight:(NSString *)ch length:(NSInteger)length;

- (void)copyToPasteboard;

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size;

@end
