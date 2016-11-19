//
//  NSObject+WeChatTimeLine.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/15.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+WeChatTimeLine.h"
#import <objc/runtime.h>
#import "NSObject+__DyInjectSwizzle.h"
#import "UIViewController+WeChatNewTimeLine.h"
#import "DyActionSheet.h"
#import "DyDownloadManager.h"

@interface NSObject (WeChatMethod)

//WCDataItem
- (NSArray *)getMediaWraps;
- (id)pathForSightData;
- (id)pathForPreview;

//DownloadMediaWrap
- (id)initWithMediaItem:(id)arg1 downloadType:(int)arg2;
- (UIImage *)resultImage;
//WCDownloadMgr
- (void)doDownloadMediaCDN:(id)arg1;
- (void)onRestore:(id)arg1;

@end

@interface UIView (WeChatMethod)

- (void)initOperateBtn;

- (void)updateCrashProtectedState:(id)arg1 newDataItem:(id)arg2;

@end

@interface UIViewController (WeChatMethod)

- (void)writeOldText:(id)arg1;

@end

@implementation NSObject (WeChatTimeLine)

@end

@implementation UIView (WCTimeLineCellView)

+ (void)load
{
    Class viewClass = NSClassFromString(@"WCTimeLineCellView");
    if (viewClass) {
        [viewClass ___exchangeMethod:@selector(updateCrashProtectedState:newDataItem:) withMethod:@selector(__dyUpdateCrashProtectedState:newDataItem:)];
        [viewClass ___exchangeMethod:@selector(layoutSubviews) withMethod:@selector(dydylayoutSubviews)];
        [viewClass ___exchangeMethod:@selector(onRestore:) withMethod:@selector(dydyonRestore:)];
    }
}

static char * ___WCTimeLineCellViewForwardBtnKey = "___WCTimeLineCellViewForwardBtnKey";

- (UILabel *)__forwardView
{
    UILabel * ____btn = objc_getAssociatedObject(self, ___WCTimeLineCellViewForwardBtnKey);
    if (!____btn) {
        ____btn = [UILabel new];
        ____btn.numberOfLines = 0;
        ____btn.backgroundColor = [UIColor redColor];
        ____btn.font = [UIFont systemFontOfSize:14];
        ____btn.text = @"一键转发";
        ____btn.textAlignment = NSTextAlignmentCenter;
        ____btn.textColor = [UIColor blackColor];
        ____btn.userInteractionEnabled = YES;
        UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(__dyGesTest)];
        [____btn addGestureRecognizer:ges];
        objc_setAssociatedObject(self, ___WCTimeLineCellViewForwardBtnKey, ____btn, OBJC_ASSOCIATION_RETAIN);
    }
    [self.superview addSubview:____btn];
    return ____btn;
}

static char * ___WCTimeLineCellViewDownloadManagerKey = "___WCTimeLineCellViewDownloadManagerKey";

- (void)__dyOneKeyForward
{
    id m_dataItem = [self valueForKey:@"m_dataItem"];
    id contentItem = [m_dataItem valueForKey:@"contentObj"];
    
    NSArray * mediaWraps = [m_dataItem getMediaWraps];

    if (mediaWraps.count > 0) {
        __weak NSObject * ob = self;
        DyDownloadManager * dy_manager = nil;
        if ([[contentItem valueForKey:@"type"] integerValue] == 1)
        {
             dy_manager = [[DyDownloadManager alloc]initWithItems:mediaWraps completion:^(NSArray *images) {
                NSString * title = [m_dataItem valueForKey:@"contentDesc"];
                NSLog(@"title %@",title);
                [UIViewController dyShowNewTimeLineWithImages:images text:title fromVc:[ob valueForKey:@"navigationController"]];
                
            }];
        }else if ( [[contentItem valueForKey:@"type"] integerValue] == 15)
        {
            id firstItemWrap = [mediaWraps firstObject];
            id mediaItem = [firstItemWrap valueForKey:@"mediaItem"];
            NSString * videoPath = [mediaItem pathForSightData];
            NSString * imgPath = [mediaItem pathForPreview];
            UIImage * thumbImg = nil;
            if ([imgPath isKindOfClass:[NSString class]]) {
                thumbImg = [UIImage imageWithContentsOfFile:imgPath];
            }
            if (!thumbImg) {
                NSLog(@"thumber is null");
                return;
            }
            NSString * title = [m_dataItem valueForKey:@"contentDesc"];
            NSLog(@"title %@",title);
            
            [UIViewController dyShowNewVideoWithPath:videoPath thumbImage:thumbImg text:title fromVc:[ob valueForKey:@"navigationController"]];
        }
        
        objc_setAssociatedObject(self, ___WCTimeLineCellViewDownloadManagerKey, dy_manager, OBJC_ASSOCIATION_RETAIN);
    }else
    {
        objc_setAssociatedObject(self, ___WCTimeLineCellViewDownloadManagerKey, nil, OBJC_ASSOCIATION_RETAIN);
        
        NSString * title = [m_dataItem valueForKey:@"contentDesc"];
        NSLog(@"title %@",title);
        [UIViewController dyShowNewTimeLineWithImages:nil text:title fromVc:[self valueForKey:@"navigationController"]];
    }
}

- (void)__dyUpdateCrashProtectedState:(id)arg1 newDataItem:(id)arg2
{
    [self __dyUpdateCrashProtectedState:arg1 newDataItem:arg2];
    [self __updateByItem:arg2];
}

- (void)__updateByItem:(id)arg2
{
    UIView * btn = [self __forwardView];
    UIView * headerView = [self valueForKey:@"m_headImage"];
    if (headerView) {
        btn.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y + headerView.frame.size.height + 5, headerView.frame.size.width, headerView.frame.size.width);
    }else
        btn.frame = CGRectMake(5, 80, 72, 72);
}

- (void)__dyGesTest
{
    id m_dataItem = [self valueForKey:@"m_dataItem"];
    id contentItem = [m_dataItem valueForKey:@"contentObj"];
    NSLog(@"content type %@",[contentItem valueForKey:@"type"]);
    if ([[contentItem valueForKey:@"type"] integerValue] == 1 || [[contentItem valueForKey:@"type"] integerValue] == 15) {
        [DyActionSheet showWithTitle:@"一键发朋友圈" moreActions:@[@"确定"] completion:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self __dyOneKeyForward];
            }
        }];
    }
}

- (void)dydylayoutSubviews
{
    [self dydylayoutSubviews];
    [self __updateByItem:nil];
}

- (void)dydyonRestore:(id)arg1
{
    [self dydyonRestore:arg1];
    [self __updateByItem:nil];
}

@end
