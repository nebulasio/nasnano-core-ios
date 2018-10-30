//
//  JsonUtil.m
//  GpFramework
//
//  Created by 郭平 on 2017/10/3.
//  Copyright © 2017年 nebulas. All rights reserved.
//

#import "JsonUtil.h"
#import "NSString+Ext.h"
#import <YYModel/YYModel.h>

@interface JsonUtil() {
    NSDictionary *_dic;
}
@end

@implementation JsonUtil

+ (NSString *)serialize:(id)data {
    return [data yy_modelToJSONString];
}

+ (id)deserialize:(id)data type:(id)type {
    if (!data) {
        return nil;
    }
    if (type == NSString.class) {
        return STR(data);
    } else if (type == NSNumber.class) {
        return [NSNumber numberWithDouble:[STR(data) doubleValue]];
    } else if ([type isKindOfClass:ArrayType.class]) {
        ArrayType *arrayType = (ArrayType *)type;
        NSArray *v = nil;
        if ([data isKindOfClass:NSArray.class]) {
            v = (NSArray *)data;
        } else if ([data isKindOfClass:NSString.class]) {
            NSData *d = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
            v = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:NULL];
        }
        if (!v) {
            return nil;
        }
        NSMutableArray *r = [[NSMutableArray alloc] initWithCapacity:v.count];
        if (arrayType.clazz == NSNumber.class) {
            for (id i in v) {
                [r addObject:[NSNumber numberWithDouble:[STR(i) doubleValue]]];
            }
        } else if (arrayType.clazz == NSString.class) {
            for (id i in v) {
                [r addObject:STR(i)];
            }
        } else {
            for (id i in v) {
                NSObject *o = [arrayType.clazz new];
                BOOL b = [o yy_modelSetWithDictionary:i];
                if (b) {
                    [r addObject:o];
                }
            }
        }
        return r;
    } else if(type == NSDictionary.class) {
        if ([data isKindOfClass:NSString.class]) {
            NSData *d = [data dataUsingEncoding:NSUTF8StringEncoding];
            return [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
        } else if ([data isKindOfClass:NSDictionary.class]) {
            return data;
        } else {
            return nil;
        }
    } else {
        id r = nil;
        if ([data isKindOfClass:NSString.class]) {
            r = [(Class)type new];
            [r yy_modelSetWithJSON:(NSString *)data];
        } else if ([data isKindOfClass:NSDictionary.class]) {
            r = [(Class)type new];
            [r yy_modelSetWithDictionary:(NSDictionary *)data];
        }
        return r;
    }
}

- (instancetype)initWithContent:(id)content {
    if (self = [super init]) {
        if ([content isKindOfClass:NSString.class]) {
            NSData *d = [(NSString *)content dataUsingEncoding:NSUTF8StringEncoding];
            _dic = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:NULL];
        } else if ([content isKindOfClass:NSDictionary.class]) {
            _dic = content;
        } else {
            @throw [[NSException alloc] initWithName:@"JsonFinder" reason:@"params error" userInfo:nil];
        }
    }
    return self;
}

- (id)findWithType:(id)type path:(NSString *)path {
    NSObject *v = _dic;
    if (v && ![NSString isEmpty:path]) {
        NSArray *ps = [path componentsSeparatedByString:@"."];
        for (NSString *p in ps) {
            v = [self valueWithFieldName:p obj:v];
            if (!v) {
                break;
            }
        }
    }
    if (!v) {
        return nil;
    }
    return [JsonUtil deserialize:v type:type];
}

- (id)valueWithFieldName:(NSString *)fieldName obj:(id)obj {
    if (![obj isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    return ((NSDictionary *)obj)[fieldName];
}

@end
