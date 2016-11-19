//
//  UIViewController+WeChatNewTimeLine.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/17.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WeChatNewTimeLine)

+ (void)dyShowNewTimeLineWithImages:(NSArray *)images text:(NSString *)text fromVc:(UIViewController *)fromVc;

+ (void)dyShowNewVideoWithPath:(NSString *)path thumbImage:(UIImage *)thumbImage fromVc:(UIViewController *)fromVc;

+ (void)dyShowNewVideoWithPath:(NSString *)path thumbImage:(UIImage *)thumbImage text:(NSString *)text fromVc:(UIViewController *)fromVc;
@end
