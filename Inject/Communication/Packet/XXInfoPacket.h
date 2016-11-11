//
//  XXInfoPacket.h
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@interface XXInfoPacket : NSObject<XXPacketProtocol>

- (instancetype)initWithInfo:(NSString *)info module:(NSString *)module;

@property (nonatomic, copy, readonly) NSString * info;

@property (nonatomic, copy, readonly) NSString * module;

@end
