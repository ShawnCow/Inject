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
        _packetData = [packetData copy];
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

- (NSString *)packetAction
{
    return self.action;
}

- (NSDictionary *)packetDictionary
{
    return self.dictionary;
}

- (void)reset
{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    _action = [aDecoder decodeObjectForKey:@"action"];
    _dictionary = [aDecoder decodeObjectForKey:@"dictionary"];
    _packetData = [aDecoder decodeObjectForKey:@"data"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.dictionary forKey:@"dictionary"];
    [aCoder encodeObject:self.packetData forKey:@"data"];
}

@end
