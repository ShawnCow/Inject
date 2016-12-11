//
//  DyAlertView.m
//  DyInjectService
//
//  Created by Shawn on 2016/12/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyAlertView.h"

@implementation DyAlertView

+ (void)showWithTitle:(NSString *)title message:(NSString *)message moreActions:(NSArray *)more completion:(DyAlertViewCompletion)completion
{
    DyAlertView * actionSheet = [DyAlertView new];
    actionSheet.title = title;
    actionSheet.message = message;
    actionSheet.mores = more;
    actionSheet.completion = completion;
    [actionSheet show];
}

- (void)show
{
    self.rself = self;
    
    UIAlertView * actionSheet = [[UIAlertView alloc]initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    for (int i = 0; i < self.mores.count; i ++) {
        [actionSheet addButtonWithTitle:self.mores[i]];
    }
    [actionSheet show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completion) {
        self.completion(buttonIndex);
    }
    self.completion = nil;
    self.rself = nil;
}

@end
