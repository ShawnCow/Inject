//
//  XXReceiveFileService.h
//  DyInjectService
//
//  Created by Shawn on 2016/10/22.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

typedef NS_ENUM(NSInteger, DyInjectFileServicePathType)
{
    DyInjectFileServicePathTypeDocument,
    DyInjectFileServicePathTypeBundle,
    DyInjectFileServicePathTypeCache,
};

@interface XXReceiveFileService : NSObject

+ (NSArray *)contentWithSubPath:(NSString *)subPath type:(DyInjectFileServicePathType)type;

+ (NSString *)pathWithSubPath:(NSString *)subPath type:(DyInjectFileServicePathType)type;

+ (instancetype)defaultDyInjectFileService;

- (void)addFilePacket:(id<XXPacketProtocol>)packet;

- (NSArray *)allItems;

@end
