//
//  XXPacketProtocol.h
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

@protocol XXPacketProtocol <NSObject>

- (NSString *)packetAction;

- (NSDictionary *)packetDictionary;

- (BOOL)packetReadBuffer:(NSData **)data bufferInfo:(NSDictionary **)bufferInfo;

- (void)reset;

@optional

- (id)initWithAction:(NSString *)action infoDic:(NSDictionary *)infoDic packetData:(NSData *)packetData;

@end
