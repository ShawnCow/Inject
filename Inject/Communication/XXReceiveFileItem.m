//
//  XXReceiveFileItem.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXReceiveFileItem.h"
#import "XXPacket.h"

@interface XXReceiveFileItem ()
{
    NSFileHandle * fileHandle;
}
@end

@implementation XXReceiveFileItem

- (instancetype)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    return self;
}

- (BOOL)addFilePacket:(id <XXPacketProtocol>)filePacket
{
    NSDictionary * fileInfo = nil;
    while (YES) {
        NSData * tempData = nil;
        NSDictionary * tempFileInfo = nil;
        if ([filePacket packetReadBuffer:&tempData bufferInfo:&tempFileInfo]) {
            if (!fileInfo) {
                fileInfo = tempFileInfo;
            }
            [fileHandle writeData:tempData];
            [fileHandle synchronizeFile];
            break;
        }
        if (!tempData || tempData.length == 0) {
            break;
        }
    }
    
    if ([[fileInfo objectForKey:@"XXFileDataFinish"] isEqualToString:@"true"]) {
        [fileHandle closeFile];
        return YES;
    }
    return NO;
}

@end
