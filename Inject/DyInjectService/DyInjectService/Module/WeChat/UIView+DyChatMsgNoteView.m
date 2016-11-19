//
//  UIView+DyChatMsgNoteView.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/19.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "UIView+DyChatMsgNoteView.h"
#import "UIImage+MMImage.h"
#import "UIViewController+WeChatNewTimeLine.h"
#import "NSObject+__DyInjectSwizzle.h"

@interface NSObject (msgnotemethod)

- (void)commonInit;
//
+ (id)getMsgImg:(id)arg1;
+ (id)GetPathOfMesVideoWithMessageWrap:(id)arg1;
+ (id)getMaskedVideoMsgImgThumb:(id)arg1;

//
- (UIViewController *)getViewController;

//
- (NSString *)m_nsContent;

//
- (BOOL)IsImgMsg;
- (BOOL)IsTextMsg;
- (_Bool)IsVideoMsg;
- (id)GetThumb;
//

- (void)showOperationMenuWithoutDelete:(id)arg1 CanBeForward:(_Bool)arg2;



@end

@implementation UIView (DyChatMsgNoteView)

+ (void)load
{
    Class viewClass = NSClassFromString(@"BaseMessageNodeView");
    if (viewClass) {
        [viewClass ___exchangeMethod:@selector(showOperationMenuWithoutDelete:CanBeForward:) withMethod:@selector(dyBaseMessageNodeViewShowOperationMenuWithoutDelete:CanBeForward:)];
    }
}

- (void)dyChatMsgNoteViewShareToTimeline
{
    
    id msgwrap = [self valueForKey:@"m_oMessageWrap"];
    id chatMsgViewDelegate = [self valueForKey:@"m_delegate"];
    UIViewController * vc = [chatMsgViewDelegate getViewController];
    if ([self isKindOfClass:NSClassFromString(@"ImageMessageNodeView")]) {
        UIImage * msgContentImg = [NSClassFromString(@"CMessageWrap") getMsgImg:msgwrap];
        id mmimage = [[NSClassFromString(@"MMImage") alloc]initWithImage:msgContentImg];
        [mmimage commonInit];
        NSArray * imgArray = nil;
        if (mmimage) {
            imgArray = @[mmimage];
        }
        [UIViewController dyShowNewTimeLineWithImages:imgArray text:nil fromVc:vc];
    }else if ([self isKindOfClass:NSClassFromString(@"TextMessageNodeView")])
    {
        NSString * msgContent = [msgwrap m_nsContent];
        [UIViewController dyShowNewTimeLineWithImages:nil text:msgContent fromVc:vc];
    }else if ([self isKindOfClass:NSClassFromString(@"ShortVideoMessageNodeView")])
    {
        //
        NSLog(@"is ShortVideoMessageNodeView");
        NSString * videoPath = [NSClassFromString(@"CMessageWrap") GetPathOfMesVideoWithMessageWrap:msgwrap];
        NSLog(@"did get video path %@",videoPath);
//        UIImage * thumbImg = [NSClassFromString(@"CMessageWrap") getMaskedVideoMsgImgThumb:msgwrap];
        UIImage * thumbImg = [(UIImageView *)[self valueForKey:@"m_thumbImg"] image];//m_thumbImg
        if (!thumbImg) {
            thumbImg = [msgwrap GetThumb];
            if (![thumbImg isKindOfClass:[UIImage class]]) {
                thumbImg = nil;
            }
        }
        if (!thumbImg) {
            NSLog(@"get thumb image failed");
            return;
        }
        NSLog(@"did get thumb image %@",thumbImg);
        [UIViewController dyShowNewVideoWithPath:videoPath thumbImage:thumbImg fromVc:vc];
    }
}

- (void)dyBaseMessageNodeViewShowOperationMenuWithoutDelete:(id)arg1 CanBeForward:(_Bool)arg2
{
    id msgwrap = [self valueForKey:@"m_oMessageWrap"];
    
    if([msgwrap IsTextMsg] || [msgwrap IsImgMsg] || [msgwrap IsVideoMsg]){
        if ([msgwrap IsVideoMsg]) {
            NSLog(@"self %@",self);
        }
        NSMutableArray *menuarray = [[NSMutableArray alloc]initWithArray:arg1];
        UIMenuItem *menu_timeline = [[UIMenuItem alloc] initWithTitle:@"朋友圈" action:@selector(dyChatMsgNoteViewShareToTimeline)];
        [menuarray insertObject:menu_timeline atIndex:0];
        [self dyBaseMessageNodeViewShowOperationMenuWithoutDelete:menuarray CanBeForward:arg2];
    }else
    {
        [self dyBaseMessageNodeViewShowOperationMenuWithoutDelete:arg1 CanBeForward:arg2];
    }
}

@end
