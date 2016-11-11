//
//  XXFilePacket.h
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@interface XXFilePacket : NSObject<XXPacketProtocol>

- (instancetype)initWithFilePath:(NSString *)filePath;

@property (nonatomic, copy, readonly) NSString * filePath;

@end
