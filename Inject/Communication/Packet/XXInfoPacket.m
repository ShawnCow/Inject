//
//  XXInfoPacket.m
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXInfoPacket.h"

@implementation XXInfoPacket

- (instancetype)initWithInfo:(NSString *)info module:(NSString *)module
{
    self = [super init];
    if (self) {
        _info = [info copy];
        _module = [module copy];
    }
    return self;
}

- (BOOL)packetReadBuffer:(NSData *__autoreleasing *)data bufferInfo:(NSDictionary *__autoreleasing *)bufferInfo
{
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    tempDic[@"type"] = @"info";
    if (self.info) {
        tempDic[@"info"] = self.info;
    }
    if (bufferInfo) {
        *bufferInfo = tempDic;
    }
    return YES;
}

- (NSString *)packetAction
{
    return self.module;
}

- (NSDictionary *)packetDictionary
{
    return nil;
}
- (void)reset
{
}

@end
