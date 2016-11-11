//
//  XXPacket.m
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXPacket.h"

@implementation XXPacket

- (instancetype)initWithAction:(NSString *)action infoDic:(NSDictionary *)infoDic packetData:(NSData *)packetData
{
    self = [super init];
    if (self) {
        _dictionary = [infoDic copy];
        _action = [action copy];
        _packetData = [_packetData copy];
    }
    return self;
}

- (BOOL)packetReadBuffer:(NSData *__autoreleasing *)data bufferInfo:(NSDictionary *__autoreleasing *)bufferInfo
{
    if (data) {
        *data = self.packetData;
    }
    if (bufferInfo) {
        *bufferInfo = self.dictionary;
    }
    return YES;
}

- (NSDictionary *)packetDictionary
{
    return self.dictionary;
}

- (NSString *)packetAction
{
    return self.action;
}

@end
