//
//  __DyViewManager.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "__DyViewManager.h"
#import <UIKit/UIKit.h>
#import "__XXDyInjectRouter.h"

@implementation __DyViewManager

+ (void)load
{
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"viewmanager" completion:^id(id<XXPacketProtocol> packet) {
        
        NSDictionary * dic = [packet packetDictionary];
        NSString * type = dic[@"type"];
        if ([type isEqualToString:@"view"]) {
            return [self allViews];
        }else if ([type isEqualToString:@"rootviewcontroller"])
        {
            return [NSString stringWithFormat:@"%@",[self visibleViewControllerForRootController:[[[UIApplication sharedApplication]keyWindow]rootViewController]]];
        }
        
        return @"success";
    }];
}

+ (NSArray *)allViews
{
    NSMutableArray * tempArray = [NSMutableArray array];
    NSArray * windows = [[UIApplication sharedApplication]windows];
    for (int i = 0; i < windows.count; i ++) {
        UIWindow * window = windows[i];
        NSArray * array = [self subviewsWithView:window];
        NSString * key = [NSString stringWithFormat:@"<%@:%p>",window.class,window];
        [tempArray addObject:[NSDictionary dictionaryWithObject:array forKey:key]];
    }
    return tempArray;
}

+ (NSArray *)subviewsWithView:(UIView *)view
{
    NSMutableArray * tempArray = [NSMutableArray array];
    for (int i = 0; i < view.subviews.count; i ++) {
        UIView * tempView = view.subviews[i];
        NSString * key = [NSString stringWithFormat:@"<%@:%p>",[tempView class],tempView];
        NSDictionary * dic = [NSDictionary dictionaryWithObject:[self subviewsWithView:tempView] forKey:key];
        [tempArray addObject:dic];
    }
    return tempArray;
}

+ (UIViewController *)visibleViewControllerForRootController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self visibleViewControllerForRootController:[(UINavigationController *)viewController visibleViewController]];
    }else if ([viewController isKindOfClass:[UITabBarController class]])
    {
        return  [self visibleViewControllerForRootController:[(UITabBarController *)viewController selectedViewController]];
    }else
        return viewController;
}

@end
