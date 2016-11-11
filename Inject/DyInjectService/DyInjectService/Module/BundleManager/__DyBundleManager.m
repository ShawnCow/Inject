//
//  __DyBundleManager.m
//  DyInjectService
//
//  Created by Shawn on 2016/10/22.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import "__DyBundleManager.h"
#import "NSObject+DyInjectRouter.h"

@interface __DyBundleManager ()
{
    NSMutableArray * bundles;
}
@end

@implementation __DyBundleManager

+ (void)load
{
    [__DyBundleManager shareBundleManager];
    
    [self registerDyInjectModuleForAction:@"bundlemanager" completion:^NSString *(id <XXPacketProtocol> aPacket) {
       
        NSDictionary * packet = [aPacket packetDictionary];
        
        Class unzipClass = NSClassFromString(@"ZipArchive");
        if (!unzipClass) {
            return @"app not contain ZipArchive class";
        }
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * docPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString * dylibPath = [docPath stringByAppendingPathComponent:@"__dybundlepath"];
        [fileManager createDirectoryAtPath:dylibPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
        
        NSArray * zipData = packet[@"zips"];
        
        for (NSDictionary * tempDic in zipData) {
            NSString * fileName = [[tempDic allKeys]firstObject];
            if (!fileName) {
                continue;
            }
        
            NSData * data = tempDic[fileName];
            NSString * theFilePath = [dylibPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".zip"]];
            [data writeToFile:theFilePath atomically:YES];
            NSObject * object = [[NSClassFromString(@"ZipArchive") alloc]initWithFileManager:fileManager];
            if ([object UnzipOpenFile:theFilePath]) {
                
                NSString * frameworkPath = nil;
                [object UnzipFileTo:dylibPath overWrite:YES];
                frameworkPath = [dylibPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".framework"]];
                if (!frameworkPath) {
                    resultDic[fileName] = @" unzip success, not found frameowork";
                }else
                {
                    if ([[__DyBundleManager shareBundleManager]loadBundleWithPath:frameworkPath]) {
                         resultDic[fileName] = @"unzip success, not found frameowork";
                    }else
                        resultDic[fileName] = @"framework load success";
                }
            }
            [object UnzipCloseFile];
            object = nil;
            [fileManager removeItemAtPath:theFilePath error:nil];
        }
        
        if (resultDic.count == 0) {
            return @"not handle";
        }else
            return resultDic.description;
    }];
}


+ (instancetype)shareBundleManager
{
    static __DyBundleManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[__DyBundleManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        bundles = [NSMutableArray array];
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString * dylibPath = [docPath stringByAppendingPathComponent:@"__dybundlepath"];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSArray * contents = [fileManager contentsOfDirectoryAtPath:dylibPath error:nil];
        for (NSString * fileName in contents) {
            [self loadBundleWithPath:[dylibPath stringByAppendingPathComponent:fileName]];
        }
    }
    return self;
}

- (NSArray *)allLoadBundles
{
    NSArray * tempArray = nil;
    @synchronized (bundles) {
        tempArray = [bundles copy];
    }
    return tempArray;
}

- (BOOL)loadBundleWithPath:(NSString *)path
{
    NSBundle * bunle = [NSBundle bundleWithPath:path];
    if ([bunle load]) {
        @synchronized (bundles) {
            [bundles addObject:bunle];
        }
        return YES;
    }else
        return NO;
}

- (BOOL)unloadBundle:(NSBundle *)bundle
{
    if ([bundle unload]) {
        @synchronized (bundles) {
            [bundles removeObject:bundle];
        }
        return YES;
    }
    return NO;
}
@end
