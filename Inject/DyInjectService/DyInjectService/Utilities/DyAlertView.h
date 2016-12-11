//
//  DyAlertView.h
//  DyInjectService
//
//  Created by Shawn on 2016/12/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DyAlertViewCompletion)(NSInteger buttonIndex);

@interface DyAlertView : NSObject<UIAlertViewDelegate>

+ (void)showWithTitle:(NSString *)title message:(NSString *)message moreActions:(NSArray *)more completion:(DyAlertViewCompletion)completion;

@property (nonatomic, strong) id rself;//retain self

@property (nonatomic , copy) DyAlertViewCompletion completion;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * message;

@property (nonatomic, copy) NSArray * mores;

- (void)show;

@end
