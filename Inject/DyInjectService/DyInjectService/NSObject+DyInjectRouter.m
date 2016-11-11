//
//  NSObject+DyInjectRouter.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+DyInjectRouter.h"
#import "__XXDyInjectRouter.h"
#import "XXInfoPacket.h"
#import "XXListenerConnectManager.h"

@implementation NSObject (DyInjectRouter)

+ (void)registerDyInjectModuleForAction:(NSString *)action completion:(id (^)(id<XXPacketProtocol>))completion
{
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:action completion:completion];
}

+ (void)unregisterDyInjectModelForAction:(NSString *)action
{
    [[__XXDyInjectRouter shareDyInjectRouter]unresiterRouterWithKey:action];
}

@end
