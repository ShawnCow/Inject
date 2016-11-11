//
//  XXPacket.h
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@interface XXPacket : NSObject<XXPacketProtocol, NSCoding>

@property (nonatomic, readonly, copy) NSDictionary * dictionary;

@property (nonatomic, readonly, copy) NSString * action;

@property (nonatomic, readonly, copy) NSData * packetData;

@end
