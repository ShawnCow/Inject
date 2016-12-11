//
//  DyActionSheet.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/17.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DyActionSheetCompletion)(NSInteger buttonIndex);

@interface DyActionSheet : NSObject<UIActionSheetDelegate>

+ (void)showWithTitle:(NSString *)title moreActions:(NSArray *)more completion:(DyActionSheetCompletion)completion;

@property (nonatomic, strong) id rself;//retain self

@property (nonatomic , copy) DyActionSheetCompletion completion;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSArray * mores;

- (void)show;

@end
