//
//  XXReceiveFileService+ListenerFileService.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXReceiveFileService+ListenerFileService.h"
#import "__XXDyInjectRouter.h"
#import "XXPacketProtocol.h"
#import "XXFilePacket.h"
#import "XXListenerConnectManager.h"

@implementation XXReceiveFileService (ListenerFileService)

+ (void)load
{   
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"filemanager" completion:^id (id <XXPacketProtocol> aPacket) {
        NSDictionary * packet = [aPacket packetDictionary];
        NSString * action = packet[@"type"];
        if ([action isEqualToString:@"show"]) {
            NSString * subPath = packet[@"subpath"];
            NSInteger pathType = [packet[@"pathtype"] integerValue];
            return [self contentWithSubPath:subPath type:pathType];
        }else if ([action isEqualToString:@"move"])
        {
            NSString * f_subpath = packet[@"f_subpath"];
            NSInteger f_pathType = [packet[@"f_pathtype"] integerValue];
            NSString * t_subpath = packet[@"t_subpath"];
            NSInteger t_pathType = [packet[@"t_pathtype"] integerValue];
            NSString * o_Path = [self pathWithSubPath:f_subpath type:f_pathType];
            NSString * n_path = [self pathWithSubPath:t_subpath type:t_pathType];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSError * error = nil;
            BOOL result = [fileManager moveItemAtPath:o_Path toPath:n_path error:&error];
            NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
            tempDic[@"type"] = @"move";
            if (result) {
                tempDic[@"from"] = o_Path;
                tempDic[@"to"] = n_path;
            }else
            {
                tempDic[@"failed"] = error.localizedDescription;
            }
            return tempDic;
            
        }else if ([action isEqualToString:@"delete"])
        {
            NSString * subPath = packet[@"subpath"];
            NSInteger pathType = [packet[@"pathtype"] integerValue];
            NSString * filePath = [self pathWithSubPath:subPath type:pathType];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSError * error = nil;
            BOOL result = [fileManager removeItemAtPath:filePath error:&error];
            NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
            tempDic[@"type"] = @"delete";
            if (result) {
                tempDic[@"result"] = @"success";
            }else
            {
                tempDic[@"result"] = @"failed";
                tempDic[@"reason"] = error.localizedDescription;
            }
            return tempDic;
        }else if ([action isEqualToString:@"copyfiletome"])
        {
            NSString * subPath = packet[@"subpath"];
            NSInteger pathType = [packet[@"pathtype"] integerValue];
            NSString * filePath = [self pathWithSubPath:subPath type:pathType];
            XXFilePacket * filePacket = [[XXFilePacket alloc]initWithFilePath:filePath];
            [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:filePacket];
        }
        
        return @"unknow";
    }];
    
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"XXPacketSendFileAction" completion:^NSString *(id <XXPacketProtocol> packet) {
        
        [[XXReceiveFileService defaultDyInjectFileService]addFilePacket:packet];
        return @"file send is OK";
    }];
}

@end
