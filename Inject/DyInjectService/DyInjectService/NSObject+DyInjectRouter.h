//
//  NSObject+DyInjectRouter.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

//为了降低耦合性 如果是独立开发模块 只需要把这个头文件 引入到新的工程,不用添加router的引用 或者编译的时候会产生 class未找到的错误

@interface NSObject (DyInjectRouter)

+ (void)registerDyInjectModuleForAction:(NSString *)action completion:(id (^)(id<XXPacketProtocol>packet))completion;

+ (void)unregisterDyInjectModelForAction:(NSString *)action;

@end
