//
//  __XXDyInjectRouter.m
//  DyInjectService
//
//  Created by Shawn on 2016/10/20.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import "__XXDyInjectRouter.h"

@interface __XXDyInjectRouter ()
{
    NSMutableDictionary * _routerDictionary;
}
@end

@implementation __XXDyInjectRouter

+ (instancetype)shareDyInjectRouter
{
    static __XXDyInjectRouter * router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[__XXDyInjectRouter alloc]init];
    });
    return router;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _routerDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)items
{
    NSArray * tempArray = nil;
    @synchronized (_routerDictionary) {
        tempArray = [[_routerDictionary allValues] copy];
    }
    return tempArray;
}

- (id)routerWithKey:(NSString *)key parameter:(id<XXPacketProtocol>)parameter
{
    __XXDyInjectRouterItem * item = [self itemForKey:key];
    if (item.block) {
        return item.block(parameter);
    }
    return nil;
}

- (BOOL)canRouterForKey:(NSString *)key
{
    @synchronized (_routerDictionary) {
        if ([_routerDictionary.allKeys containsObject:key]) {
            return YES;
        }
    }
    return NO;
}

- (__XXDyInjectRouterItem *)registerRouterWithKey:(NSString *)key completion:(XXDyInjectBlock)completion
{
    if (!key) {
        return nil;
    }
    __XXDyInjectRouterItem * item = [self itemForKey:key];
    if (!item) {
        item = [[__XXDyInjectRouterItem alloc]initWithKey:key];
        @synchronized (_routerDictionary) {
            _routerDictionary[key] = item;
        }
    }
    item.block = completion;
    return item;
}

- (__XXDyInjectRouterItem *)unresiterRouterWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    __XXDyInjectRouterItem * item = [self itemForKey:key];
    if (item) {
        @synchronized (_routerDictionary) {
            [_routerDictionary removeObjectForKey:key];
        }
    }
    return item;
}

- (__XXDyInjectRouterItem *)itemForKey:(NSString *)key
{
    __XXDyInjectRouterItem * item = nil;
    @synchronized (_routerDictionary) {
        item = _routerDictionary[key];
    }
    return item;
}

@end

@implementation __XXDyInjectRouterItem

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = [key copy];
    }
    return self;
}

@end
