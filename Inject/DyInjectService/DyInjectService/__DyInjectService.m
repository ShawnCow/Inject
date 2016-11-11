//
//  __DyInjectService.m
//  DyInjectService
//
//  Created by Shawn on 2016/10/20.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import "__DyInjectService.h"
#import "XXListenerConnectManager.h"
#import "__XXDyInjectRouter.h"
#import "XXInfoPacket.h"
#import "XXPacket.h"

#define ____DyInjectServiceVersion      @"0.0.1"

@interface __DyInjectService ()<XXListenerConnectManagerDelegate>
{
    dispatch_queue_t actionQueue;
}
@end

@implementation __DyInjectService

+ (void)load
{
    [__DyInjectService shareInjectService];
}

+ (NSString *)version
{
    return ____DyInjectServiceVersion;
}

+ (instancetype)shareInjectService
{
    static dispatch_once_t once;
    static __DyInjectService * service;
    dispatch_once(&once, ^{
        service = [[self alloc] init];
    });
    return service;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"DyInjectService version %@",____DyInjectServiceVersion);
        
        NSString * bundeId = [[NSBundle mainBundle] bundleIdentifier];
        if (!bundeId) {
            bundeId = @"com.test.test";
        }
        NSString * queueName = [NSString stringWithFormat:@"com.shawn.dyinjectservice.%p",self];
        actionQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        
        [[XXListenerConnectManager currentListenerConnectManager]startWithKey:bundeId];
        [XXListenerConnectManager currentListenerConnectManager].delegate = self;
    }
    return self;
}

#pragma mark - 

- (void)deviceConnectManager:(XXDeviceConnectManager *)deviceConnectionManager didReceivePacket:(id<XXPacketProtocol>)packet
{
    // 为了防止在主线程会影响宿主 app的性能 所以用线程执行
    dispatch_async(actionQueue, ^{
        
        __XXDyInjectRouter * router = [__XXDyInjectRouter shareDyInjectRouter];
        if ([router canRouterForKey:[packet packetAction]]) {
            id result = nil;
            @try {
                result = [router routerWithKey:[packet packetAction] parameter:packet];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            if (result) {
                NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];
                if ([result isKindOfClass:[NSString class]]) {
                    resultDictionary[@"result"] = result;
                }else if ([result isKindOfClass:[NSDictionary class]])
                {
                    if ([self containNotSupportDataForDictionary:result]) {
                        resultDictionary[@"result"] = [NSString stringWithFormat:@"%@",result];
                    }else
                        resultDictionary[@"result"] = result;
                }else if ([result isKindOfClass:[NSArray class]])
                {
                    if ([self containNotSupportDataForArray:result]) {
                        resultDictionary[@"result"] = [NSString stringWithFormat:@"%@",result];
                    }else
                        resultDictionary[@"result"] = result;
                }else
                {
                    resultDictionary[@"result"] = [NSString stringWithFormat:@"%@",result];
                }
                resultDictionary[@"type"] = @"callresult";
                XXPacket * infoPacket = [[XXPacket alloc]initWithAction:[packet packetAction] infoDic:resultDictionary packetData:nil];
                [deviceConnectionManager inQueueWithPacket:infoPacket];
            }else
            {
                XXInfoPacket * infoPacket = [[XXInfoPacket alloc]initWithInfo:[NSString stringWithFormat:@"%@ did finish",[packet packetAction]] module:[packet packetAction]];
                [deviceConnectionManager inQueueWithPacket:infoPacket];
            }
        }else
        {
            XXInfoPacket * infoPacket = [[XXInfoPacket alloc]initWithInfo:[NSString stringWithFormat:@"router module can not jump %@",[packet packetAction]] module:[packet packetAction]];
            [deviceConnectionManager inQueueWithPacket:infoPacket];
        }
    });
   
}

- (BOOL)containNotSupportDataForDictionary:(NSDictionary *)dictionary
{
    NSArray * allKey = [dictionary allKeys];
    if ([self containNotSupportDataForArray:allKey]) {
        return YES;
    }
    NSArray * allValue = [dictionary allValues];
    if ([self containNotSupportDataForArray:allValue]) {
        return YES;
    }
    return NO;
}

- (BOOL)containNotSupportDataForArray:(NSArray *)array
{
    for (id obj in array) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([self containNotSupportDataForDictionary:obj]) {
                return YES;
            }
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            if ([self containNotSupportDataForArray:obj]) {
                return YES;
            }
        }
        
        if ([obj isKindOfClass:[NSString class]] == NO) {
            return YES;
        }
    }
    return NO;
}

@end
