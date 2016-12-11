//
//  DyRevealView.h
//  DyViewManager
//
//  Created by Shawn on 2016/12/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//


#import <CoreFoundation/CoreFoundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#   define DyView                                      UIView
#else
#import <AppKit/AppKit.h>
#   define DyView                                      NSView
#endif

@interface DyRevealView : DyView

@property (copy) NSArray * viewInfoDictionarys;

@end
