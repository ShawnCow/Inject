//
//  UIViewController+FindFriendEntryViewController.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/19.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "UIViewController+FindFriendEntryViewController.h"
#import "NSObject+__DyInjectSwizzle.h"
#import "NSObject+LocationMock.h"
#import "DyActionSheet.h"
#import "DyWeChatPickLocation.h"

@implementation UIViewController (FindFriendEntryViewController)

+ (void)load
{
    Class vcClass = NSClassFromString(@"FindFriendEntryViewController");
    if (vcClass) {
        [vcClass ___exchangeMethod:@selector(viewDidLoad) withMethod:@selector(FindFriendEntryViewControllerDyViewDidLoad)];
    }
}
static DyWeChatPickLocation  * wechatPickerLocation = nil;

- (void)FindFriendEntryViewControllerDyViewDidLoad
{
    [self FindFriendEntryViewControllerDyViewDidLoad];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:@"模拟定位" style:0 target:self action:@selector(FindFriendEntryViewControllerMockLocation)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)FindFriendEntryViewControllerMockLocation
{
    BOOL isOpenMock = [NSObject mockLocationEnable];
    NSArray * moreOption = nil;
    if (isOpenMock) {
        moreOption = @[@"关闭"];
    }else
    {
        moreOption = @[@"开启"];
    }
    [DyActionSheet showWithTitle:@"模拟定位" moreActions:moreOption completion:^(NSInteger buttonIndex) {
        NSLog(@"button index %d",buttonIndex);
        if (buttonIndex == 1) {
            if (isOpenMock == NO) {
                wechatPickerLocation = [[DyWeChatPickLocation alloc]initWithSourceViewController:self];
                NSLog(@"we %@",wechatPickerLocation);
            }else
            {
                NSLog(@"close");
                [NSObject switchMockLocationEnable:NO];
            }
        }
    }];
}
@end
