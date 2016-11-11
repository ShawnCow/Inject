//
//  __DyTest.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "__DyTest.h"
#import "NSObject+DyInjectRouter.h"

@implementation __DyTest

+ (void)load
{
    [self registerDyInjectModuleForAction:@"test" completion:^id(id <XXPacketProtocol> packet) {
        return @"test";
    }];
}

@end
