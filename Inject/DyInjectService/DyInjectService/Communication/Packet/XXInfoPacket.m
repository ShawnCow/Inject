//
//  XXInfoPacket.m
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXInfoPacket.h"

@implementation XXInfoPacket

- (instancetype)initWithInfo:(NSString *)info
{
    self = [super init];
    if (self) {
        _info = [info copy];
    }
    return self;
}

- (BOOL)packetReadBuffer:(NSData *__autoreleasing *)data bufferInfo:(NSDictionary *__autoreleasing *)bufferInfo
{
    if (data) {
        *data = [self.info dataUsingEncoding:NSUTF8StringEncoding];
    }
    return YES;
}

- (NSDictionary *)packetDictionary
{
    return nil;
}

- (NSString *)packetAction
{
    return @"XXInfoPacketAction";
}

@end
