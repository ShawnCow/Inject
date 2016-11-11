//
//  __XXDyInjectRouter.h
//  DyInjectService
//
//  Created by Shawn on 2016/10/20.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@class __XXDyInjectRouterItem;

typedef id (^XXDyInjectBlock)(id <XXPacketProtocol> packet);

@interface __XXDyInjectRouter : NSObject

+ (instancetype)shareDyInjectRouter;

@property (nonatomic, readonly, copy) NSArray * items;

- (id)routerWithKey:(NSString *)key parameter:(id<XXPacketProtocol>)parameter;

- (BOOL)canRouterForKey:(NSString *)key;

- (__XXDyInjectRouterItem *)registerRouterWithKey:(NSString *)key completion:(XXDyInjectBlock)completion;

- (__XXDyInjectRouterItem *)unresiterRouterWithKey:(NSString *)key;

- (__XXDyInjectRouterItem *)itemForKey:(NSString *)key;

@end

@interface __XXDyInjectRouterItem : NSObject

- (instancetype)initWithKey:(NSString *)key;

@property (nonatomic, readonly, copy) NSString * key;

@property (nonatomic, copy) XXDyInjectBlock block;

@end
