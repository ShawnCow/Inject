//
//  NSObject+DyInjectObjectInfo.m
//  DyInjectService
//
//  Created by Shawn on 2016/12/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+DyInjectObjectInfo.h"
#import <objc/runtime.h>

@implementation NSObject (DyInjectObjectInfo)

- (NSDictionary *)_dy_AllPropertyInfo
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:[propertyValue description] forKey:propertyName];
    }
    free(properties);
    return props;
}

@end
