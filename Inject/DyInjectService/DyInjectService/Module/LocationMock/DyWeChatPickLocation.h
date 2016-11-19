//
//  DyWeChatPickLocation.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/19.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (DyWeChatPickerMethod)

- (id)initWithScene:(unsigned int)arg1 OnlyUseUserLocation:(_Bool)arg2;

@end

@interface DyWeChatPickLocation : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)viewController;

@property (nonatomic, weak, readonly) UIViewController * sourceViewController;

@property (nonatomic, strong) UIViewController * viewController;

@end
