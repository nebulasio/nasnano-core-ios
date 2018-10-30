#import "NSString+Ext.h"
#import "NSData+Codes.h"
#import <UIKit/UIKit.h>

@implementation NSString(Ext)

+ (BOOL)isEmpty:(NSString *)str {
    return !str || [str trim].length == 0;
}

+ (NSString *)newUUID {
    CFUUIDRef u = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, u);
    CFRelease(u);
    return (__bridge NSString *)s;
}

- (BOOL)match:(NSString *)reg {
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [p evaluateWithObject:self];
}

- (NSArray<NSString *> *)matches:(NSString *)reg {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            NSString *component = [self substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

- (NSString *)stringByReplaceString:(NSString *)rs withCharacter:(char)c {
    NSMutableString *ms = [NSMutableString stringWithCapacity:[self length]];
    int l = (int) [self length];
    NSRange range;
    NSString *tmps;
    for (int i = 0; i < l;) {
        tmps = [self substringFromIndex:i];
        range = [tmps rangeOfString:rs];
        if (range.length > 0) {
            [ms appendFormat:@"%@%c", [tmps substringToIndex:range.location], c];
            i += range.location + range.length;
        } else {
            [ms appendString:tmps];
            break;
        }

    }
    return ms;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimWithChars:(NSString *)chars {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:chars];
    return [self stringByTrimmingCharactersInSet:set];
}

-(NSString*)trimStartWithChars:(NSString*)characters {
    NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:characters] invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:set];
    if(range.location == NSNotFound) {
        return @"";
    } else if(range.location != 0) {
        return [self substringFromIndex:range.location];
    } else {
        return self;
    }
}

-(NSString*)trimEndWithChars:(NSString*)characters {
    NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:characters] invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    if(range.location == NSNotFound) {
        return @"";
    } else if(range.location + range.length != self.length) {
        return [self substringToIndex:range.location + range.length];
    } else {
        return self;
    }
}

- (NSString *)stringByTrimmingWhitespace {
    NSMutableString *ms = [NSMutableString stringWithString:self];
    unichar preChar = ' ';
    unichar ch;
    int size = (int) self.length;
    for (int i = 0; i < size;) {
        ch = [ms characterAtIndex:i];
        if (' ' == preChar && ' ' == ch) {
            [ms deleteCharactersInRange:NSMakeRange(i, 1)];
            size--;
        } else if ('\n' == ch) {
            [ms deleteCharactersInRange:NSMakeRange(i, 1)];
            size--;
        } else {
            i++;
            preChar = ch;
        }
    }
    return ms;
}

- (NSString *)escapeHtml {
    NSMutableString *encoded = [NSMutableString stringWithString:self];
    // @"&amp;"
    NSRange range = [self rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"&"
                                 withString:@"&amp;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    // @"&lt;"
    range = [self rangeOfString:@"<"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"<"
                                 withString:@"&lt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    // @"&gt;"
    range = [self rangeOfString:@">"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@">"
                                 withString:@"&gt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    return encoded;
}

- (BOOL)containsString:(NSString *)string {
    return !NSEqualRanges([self rangeOfString:string], NSMakeRange(NSNotFound, 0));
}

- (NSString *)padLeft:(NSString *)ch length:(NSInteger)length {
    NSMutableString *r = [[NSMutableString alloc] initWithString:self];
    while (r.length < length) {
        [r insertString:[NSString stringWithFormat:@"%@", ch] atIndex:0];
    }
    return r;
}

- (NSString *)padRight:(NSString *)ch length:(NSInteger)length {
    NSMutableString *r = [[NSMutableString alloc] initWithString:self];
    while (r.length < length) {
        [r appendFormat:@"%@", ch];
    }
    return r;
}


#pragma mark - ui

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size {
    CGSize expectedLabelSize = CGSizeZero;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

- (void)copyToPasteboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self;
}

@end
