//
//  XXFilePacket.m
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXFilePacket.h"

@interface XXFilePacket ()
{
    NSFileHandle * fileHandle;
    long long didReadLenght;
    long long readLenght;
    long long index;
    NSDictionary * fileInfo;
}
@end

@implementation XXFilePacket

- (instancetype)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        [fileHandle seekToFileOffset:0];
        didReadLenght = 0;
        readLenght = 1024 * 1024 * 2;
        fileInfo = [[NSFileManager defaultManager]attributesOfItemAtPath:self.filePath error:nil];
    }
    return self;
}

- (void)dealloc
{
    [fileHandle closeFile];
}

- (void)reset
{
    didReadLenght = 0;
    index = 0;
    [fileHandle seekToFileOffset:0];
}

- (BOOL)packetReadBuffer:(NSData *__autoreleasing *)data bufferInfo:(NSDictionary *__autoreleasing *)bufferInfo
{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
    NSString * fileName = [self.filePath lastPathComponent];
    if (fileName) {
        infoDic[@"XXFileName"] = fileName;
    }
    if(fileInfo)
    {
        for (NSString * tempKey in fileInfo.allKeys) {
            [infoDic setObject:[NSString stringWithFormat:@"%@",fileInfo[tempKey]] forKey:tempKey];
        }
    }
    infoDic[@"XXFileOffset"] = [NSNumber numberWithLongLong:didReadLenght];

    NSData * readData = [fileHandle readDataOfLength:readLenght];
    *data = readData;
    
    infoDic[@"XXFileDataLenght"] = [NSNumber numberWithLongLong:readData.length];
    
    *bufferInfo = infoDic;
    index ++;
    NSLog(@"current index %@",[NSNumber numberWithLongLong:index]);
    didReadLenght += readData.length;
    if (readData.length == readLenght) {
        infoDic[@"XXFileDataFinish"] = @"false";
        infoDic[@"index"] = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:index]];
        return NO;
    }else
    {
        infoDic[@"XXFileDataFinish"] = @"true";
        infoDic[@"index"] = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:index]];
        [fileHandle closeFile];
    }
    return YES;
}

- (NSString *)packetAction
{
    return @"XXPacketSendFileAction";
}

- (NSDictionary *)packetDictionary
{
    return nil;
}
@end
