//
//  __DyJsBridge.m
//  DyInjectService
//
//  Created by Shawn on 2016/10/21.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import "__DyJsBridge.h"
#import "__DyJPEngine.h"
#import "NSObject+DyInjectRouter.h"
#import "XXPacket.h"
#import "XXListenerConnectManager.h"

@implementation __DyJsBridge

+ (void)load
{
    [self registerDyInjectModuleForAction:@"jsbridge" completion:^NSString *(id <XXPacketProtocol> aPacket) {
        
        NSDictionary * packet = [aPacket packetDictionary];
        
        NSString * js = [packet objectForKey:@"js"];
        if (!js) {
            return @"js is not exsit";
        }
        
        [__DyJPEngine startEngine];
        [__DyJPEngine handleException:^(NSString *msg) {
            
            NSMutableString * tempInfo = [NSMutableString string];
            [tempInfo appendFormat:@"js patch exception %@",msg];
            NSMutableDictionary * sendDic = [NSMutableDictionary dictionary];
            sendDic[@"info"] = tempInfo;
            sendDic[@"type"] = @"jsexception";
            XXPacket * p = [[XXPacket alloc]initWithAction:@"jsbridge" infoDic:sendDic packetData:nil];
            [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:p];
        }];
        [__DyJPEngine evaluateScript:js];
        
        __DyJsBridge * b = [[__DyJsBridge alloc]init];
        NSString * exeResult = nil;
        
        NSMutableString * resultString = [NSMutableString string];
        
        @try {
            exeResult = [b dyJsMethod];
        } @catch (NSException *exception) {
            exeResult = @"";
            NSMutableString * tempInfo = [NSMutableString string];
            [tempInfo appendFormat:@"js patch exception %@",exception.reason];
            NSMutableDictionary * sendDic = [NSMutableDictionary dictionary];
            sendDic[@"info"] = [NSString stringWithFormat:@"exeResult: dyJsMethod exception %@",exception.reason];
            XXPacket * p = [[XXPacket alloc]initWithAction:@"jsbridge" infoDic:sendDic packetData:nil];
            [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:p];
        } @finally {
            return  @"error";
        }
        if (!exeResult) {
            exeResult = @"unknow";
        }
        [resultString appendFormat:@"%@", exeResult];
        return resultString;
    }];
}

- (NSString *)dyJsMethod
{
    return @"default";
}

@end
