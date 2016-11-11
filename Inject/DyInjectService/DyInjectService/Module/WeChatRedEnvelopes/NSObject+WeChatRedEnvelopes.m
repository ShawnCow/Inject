//
//  NSObject+WeChatRedEnvelopes.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/10.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+WeChatRedEnvelopes.h"
#import "__XXDyInjectRouter.h"
#import "NSObject+__DyInjectSwizzle.h"
#import "XXPacket.h"
#import "XXInfoPacket.h"
#import "XXListenerConnectManager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface NSObject (BaseMsgContentViewController)
// 聊天界面 添加消息节点的方法
- (void)addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3;

//点击红包的时候有一个loading的状态 所以 hook一下 stoploading的时候 的状态
- (void)stopLoading;

//WCPayC2CMessageNodeView 红包点击事件
- (void)onClick;

- (UIView *)view;

//OnOpenRedEnvelopes

- (void)OnOpenRedEnvelopes;


- (int)m_eMsgNodeType;

- (id)m_msgWrap;

- (int)m_uiMessageType;

- (id)m_nsContent;

- (id)m_nsFromUsr;

@end

@interface NSObject (NonUIRedEnvelopes)

- (void)AsyncOnAddMsg:(id)arg1 MsgWrap:(id)arg2;

#pragma mark - ServiceCenter

+ (id)defaultCenter;

- (id)getService:(Class)arg1;

#pragma mark - CContactMgr

- (id)getSelfContact;

- (id)m_nsUsrName;

- (id)getContactDisplayName;

- (id)m_nsHeadImgUrl;

#pragma mark - red manager

- (void)OpenRedEnvelopesRequest:(id)argc;

@end

@implementation NSObject (WeChatRedEnvelopes)

+ (void)load
{
    Class msgClass = NSClassFromString(@"CMessageMgr");
    if (msgClass) {
        [msgClass ___exchangeMethod:@selector(AsyncOnAddMsg:MsgWrap:) withMethod:@selector(DyAsyncOnAddMsg:MsgWrap:)];
    }
//    return;
//    Class msgClass = NSClassFromString(@"BaseMsgContentViewController");//Envelopes
//    if (msgClass) {
//        [msgClass ___exchangeMethod:@selector(addMessageNode:layout:addMoreMsg:) withMethod:@selector(dy_addMessageNode:layout:addMoreMsg:)];
//        [msgClass ___exchangeMethod:@selector(stopLoading) withMethod:@selector(dy_stopLoading)];
//        
//    }else
//    {
//        XXInfoPacket * infoPacket = [[XXInfoPacket alloc]initWithInfo:@"we chat chat msg viewcontroller class is null" module:@"router"];
//        [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:infoPacket];
//    }
}
static BOOL ___dyInjectIsHadRedEnvelopesMsg = NO;

- (void)dy_addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3
{
    NSLog(@"clsss type %@",[arg1 class]);
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"addReceiveMessageNode";
    dic[@"argc"] = [NSString stringWithFormat:@"%@",[arg1 class]];
    XXPacket * p = [[XXPacket alloc]initWithAction:@"wechatredenvelopes" infoDic:dic packetData:nil];
    
    [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:p];
   
    [self dy_addMessageNode:arg1 layout:arg2 addMoreMsg:arg3];
    
    id warpMsg = arg1;
    if ([warpMsg isKindOfClass:NSClassFromString(@"CMessageWrap")]) {
        if ([warpMsg m_uiMessageType] != 49) {
            NSLog(@"warp type not  49");
            return;
        }
    }else
    {
        NSLog(@"message warp is not right");
        return;
    }
    
    NSMutableArray * msgArray = [self valueForKey:@"m_arrMessageNodeData"];
    UITableView * tableView = [self valueForKey:@"m_tableView"];
    if (msgArray == nil || tableView == nil) {
        NSLog(@"get msg array failed");
        return;
    }
    id data = nil;
    for (id tempCheckOb in msgArray) {
        if ([tempCheckOb m_msgWrap] == arg1) {
            data = tempCheckOb;
            break;
        }
    }
    if (!data) {
        NSLog(@"note data is null");
        return;
    }
    if ([msgArray containsObject:data]) {
        NSInteger index = [msgArray indexOfObject:data];
        NSIndexPath * theIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:theIndexPath];
        if (!cell) {
            NSLog(@"cell is null");
            return;
        }
        NSArray * cellContentSubviews = cell.contentView.subviews;
        BOOL isFound = NO;
        for (UIView * tempView in cellContentSubviews) {
            if ([tempView isKindOfClass:NSClassFromString(@"WCPayC2CMessageNodeView")]) {
                isFound = YES;
                [tempView onClick];
                ___dyInjectIsHadRedEnvelopesMsg = YES;
                break;
            }
        }
    }
}

- (void)dy_stopLoading
{
    NSLog(@"hidden loading  ------");
    [self dy_stopLoading];
    if (___dyInjectIsHadRedEnvelopesMsg) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.25 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSArray * checkArray = self.view.window.subviews;
            for (UIView * tempView in checkArray) {
                if ([tempView isKindOfClass:NSClassFromString(@"WCRedEnvelopesReceiveHomeView")]) {
                    [tempView OnOpenRedEnvelopes];
                    break;
                }
            }
        });
    }
}

#pragma mark - --------

- (void)DyAsyncOnAddMsg:(id)arg1 MsgWrap:(id)arg2
{
    NSLog(@"1 %@ 2 %@",[arg1 class],[arg2 class]);
    [self DyAsyncOnAddMsg:arg1 MsgWrap:arg2];
    
    if ([arg2 m_uiMessageType] != 49) {
        return;
    }
    id serviceCenter = [NSClassFromString(@"MMServiceCenter") defaultCenter];
    
    Class contactMgrClass = NSClassFromString(@"CContactMgr");
    id contactManager = [serviceCenter getService:contactMgrClass];
    
    id loginUserContact = [contactManager getSelfContact];
    
    id m_nsFromUsr = [arg2 m_nsFromUsr];
    
    NSString * m_nsContent = [arg2 m_nsContent];
    
    if ([m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound)
    {
        NSString *nativeUrl = m_nsContent;
        NSRange rangeStart = [m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao"];
        if (rangeStart.location != NSNotFound)
        {
            NSUInteger locationStart = rangeStart.location;
            nativeUrl = [nativeUrl substringFromIndex:locationStart];
        }
        
        NSRange rangeEnd = [nativeUrl rangeOfString:@"]]"];
        if (rangeEnd.location != NSNotFound)
        {
            NSUInteger locationEnd = rangeEnd.location;
            nativeUrl = [nativeUrl substringToIndex:locationEnd];
        }
        
        NSString *naUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
        
        NSArray *parameterPairs =[naUrl componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
        for (NSString *currentPair in parameterPairs) {
            NSRange range = [currentPair rangeOfString:@"="];
            if(range.location == NSNotFound)
            continue;
            NSString *key = [currentPair substringToIndex:range.location];
            NSString *value =[currentPair substringFromIndex:range.location + 1];
            [parameters setObject:value forKey:key];
        }
        
        //红包参数
        NSMutableDictionary *params = [@{} mutableCopy];
        
        [params setObject:parameters[@"msgtype"]?:@"null" forKey:@"msgType"];
        [params setObject:parameters[@"sendid"]?:@"null" forKey:@"sendId"];
        [params setObject:parameters[@"channelid"]?:@"null" forKey:@"channelId"];
        
        id getContactDisplayName = [loginUserContact getContactDisplayName];
        id m_nsHeadImgUrl = [loginUserContact m_nsHeadImgUrl];
        [params setObject:getContactDisplayName forKey:@"nickName"];
        [params setObject:m_nsHeadImgUrl forKey:@"headImg"];
        [params setObject:[NSString stringWithFormat:@"%@", nativeUrl]?:@"null" forKey:@"nativeUrl"];
        [params setObject:m_nsFromUsr?:@"null" forKey:@"sessionUserName"];
        NSLog(@"params %@",params);
        id redEnvelopesLogicMgr = [serviceCenter getService:NSClassFromString(@"WCRedEnvelopesLogicMgr")];
        [redEnvelopesLogicMgr OpenRedEnvelopesRequest:params];
    }
}

@end
