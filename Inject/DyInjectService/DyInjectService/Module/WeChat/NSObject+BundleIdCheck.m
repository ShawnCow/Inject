//
//  NSObject+BundleIdCheck.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/19.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+BundleIdCheck.h"

@implementation NSObject (BundleIdCheck)

+ (void)load
{
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSDictionary * dictionary = [[NSBundle mainBundle]infoDictionary];
        if ([dictionary isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary * tempDic = (NSMutableDictionary *)dictionary;
            tempDic[@"CFBundleIdentifier"] = @"com.tencent.xin";
        }
    });
}
@end
