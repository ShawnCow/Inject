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
            return [self currentAllViewInfo];
        }else if ([type isEqualToString:@"rootviewcontroller"])
        {
            return [NSString stringWithFormat:@"%@",[self visibleViewControllerForRootController:[[[UIApplication sharedApplication]keyWindow]rootViewController]]];
        }
        
        return @"success";
    }];
}

/**
 获取当前显示的ViewController 查找显示的viewcontroller 递归查找 最后如果子的viewcontroller为 UIViewController 就返回 如果是NavigationController 会取visibleViewController 如果是 TabBarController 会取selectViewController

 @param viewController 查找的viewcontroller
 @return 显示的viewcontroller
 */
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


static dispatch_semaphore_t lock = nil;

+ (NSArray *)currentAllViewInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    
    NSMutableArray * tempArray = [NSMutableArray array];
    
    if ([NSThread isMainThread])
    {
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        
        NSArray * windows = [[UIApplication sharedApplication]windows];
        for (int i = 0; i < windows.count; i ++) {
            UIWindow * window = windows[i];
            NSDictionary * tempDic = [self infoDicByView:window];
            if (tempDic) {
                [tempArray addObject:tempDic];
            }
        }
        dispatch_semaphore_signal(lock);
    }
    else
    {
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(lock);
        });
        
        NSArray * windows = [[UIApplication sharedApplication]windows];
        for (int i = 0; i < windows.count; i ++) {
            UIWindow * window = windows[i];
            NSDictionary * tempDic = [self infoDicByView:window];
            if (tempDic) {
                [tempArray addObject:tempDic];
            }
        }
        
        dispatch_semaphore_signal(lock);
    }
    
    return tempArray;
}

/**
 将View的信息存储在Dictionary返回
 
 @param view View
 @return view的信息
 */
+ (NSDictionary *)infoDicByView:(UIView *)view
{
    if (!view) {
        return nil;
    }
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    
    UIView * tempSubview = view;
    NSString * viewClassName = NSStringFromClass(tempSubview.class);
    [tempDic setObject:viewClassName forKey:@"ClassName"];
    [tempDic setObject:@(tempSubview.alpha) forKey:@"alpha"];
    [tempDic setObject:@(tempSubview.isHidden) forKey:@"isHidden"];
    [tempDic setObject:NSStringFromCGRect(tempSubview.frame) forKey:@"frame"];
    [tempDic setObject:@(tempSubview.tag) forKey:@"tag"];
    CGRect toWindowFrame = [tempSubview convertRect:tempSubview.bounds toView:tempSubview.window];
    [tempDic setObject:NSStringFromCGRect(toWindowFrame) forKey:@"toWindowFrame"];
    id viewDelegate = [tempSubview valueForKey:@"_viewDelegate"];
    if (viewDelegate) {
        [tempDic setObject:NSStringFromClass([viewDelegate class]) forKey:@"ViewController"];
    }
    
    NSMutableArray * tempArray = [NSMutableArray array];
    NSArray * subviews = [view subviews];
    for (int i = 0; i < subviews.count; i ++) {
        NSDictionary * tempSubDic = [self infoDicByView:subviews[i]];
        if (tempSubDic) {
            [tempArray addObject:tempSubDic];
        }
    }
    if (tempArray.count > 0) {
        tempDic[@"subview"] = tempArray;
    }
    return tempDic;
}

@end
