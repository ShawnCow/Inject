//
//  XXReceiveFileItem.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@interface XXReceiveFileItem : NSObject

@property (nonatomic, copy, readonly) NSString * filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;

// return YES finish receive data and close wirte file

- (BOOL)addFilePacket:(id<XXPacketProtocol>)filePacket;

@end
