//
//  DyActionSheet.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/17.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyActionSheet.h"

@implementation DyActionSheet

+ (void)showWithTitle:(NSString *)title moreActions:(NSArray *)more completion:(DyActionSheetCompletion)completion
{
    DyActionSheet * actionSheet = [DyActionSheet new];
    actionSheet.title = title;
    actionSheet.mores = more;
    actionSheet.completion = completion;
    [actionSheet show];
}

- (void)show
{
    self.rself = self;
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:self.title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (int i = 0; i < self.mores.count; i ++) {
        [actionSheet addButtonWithTitle:self.mores[i]];
    }
    [actionSheet showInView:[[UIApplication sharedApplication]keyWindow]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completion) {
        self.completion(buttonIndex);
    }
    self.completion = nil;
    self.rself = nil;
}

- (void)dealloc
{
    NSLog(@"");
}

@end
