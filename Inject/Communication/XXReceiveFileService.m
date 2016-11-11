//
//  XXReceiveFileService.m
//  DyInjectService
//
//  Created by Shawn on 2016/10/22.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import "XXReceiveFileService.h"
#import "XXListenerConnectManager.h"
#import "XXReceiveFileItem.h"
#import "XXPacket.h"

@interface XXReceiveFileService ()
{
    NSMutableDictionary * __handingFileItems;
    dispatch_queue_t fileHandleQueue;
}
@end

@implementation XXReceiveFileService

+ (NSArray *)contentWithSubPath:(NSString *)subPath type:(DyInjectFileServicePathType)type
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [self pathWithSubPath:subPath type:type];
    NSArray * array = [fileManager contentsOfDirectoryAtPath:fullPath error:nil];
    return array;
}

+ (NSString *)pathWithSubPath:(NSString *)subPath type:(DyInjectFileServicePathType)type
{
    NSString * rootPath = nil;
    if (type == DyInjectFileServicePathTypeBundle) {
        rootPath = [NSBundle mainBundle].bundlePath;
    }else if (type == DyInjectFileServicePathTypeDocument)
    {
        rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }else if (type == DyInjectFileServicePathTypeCache)
    {
        rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    }
    
    NSString * fullPath = nil;
    if (subPath) {
        fullPath = [rootPath stringByAppendingPathComponent:subPath];
    }else
        fullPath = rootPath;
    return fullPath;
}

+ (instancetype)defaultDyInjectFileService
{
    static XXReceiveFileService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[XXReceiveFileService alloc]init];
    });
    return service;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __handingFileItems = [NSMutableDictionary dictionary];
        NSString * queueName = [NSString stringWithFormat:@"com.shawn.dyinjectservice.filehande.%p",self];
        fileHandleQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addFilePacket:(id<XXPacketProtocol>)packet
{
    dispatch_async(fileHandleQueue, ^{
        NSString * fileName = packet.packetDictionary[@"XXFileName"];
        if (fileName) {
            XXReceiveFileItem * item = nil;
            @synchronized (__handingFileItems) {
                item = __handingFileItems[fileName];
            }
            BOOL isNew = NO;
            if (!item) {
                isNew = YES;
                NSString * filePath = [[self class]pathWithSubPath:fileName type:DyInjectFileServicePathTypeCache];
                item = [[XXReceiveFileItem alloc]initWithFilePath:filePath];
            }
            if([item addFilePacket:packet])
            {
                if (isNew == NO) {
                    @synchronized (__handingFileItems) {
                        [__handingFileItems removeObjectForKey:fileName];
                    }
                }
                NSFileManager * fileManager = [NSFileManager defaultManager];
                NSString * toFilePath = [[self class]pathWithSubPath:fileName type:DyInjectFileServicePathTypeDocument];
                [fileManager removeItemAtPath:toFilePath error:nil];
                [fileManager moveItemAtPath:item.filePath toPath:toFilePath error:nil];
            }else
            {
                if (isNew) {
                    @synchronized (__handingFileItems) {
                        __handingFileItems[fileName] = item;
                    }
                }
            }
        }
    });
}

- (NSArray *)allItems
{
    NSArray * tempArray = nil;
    @synchronized (__handingFileItems) {
        tempArray = [__handingFileItems copy];
    }
    return tempArray;
}

@end
