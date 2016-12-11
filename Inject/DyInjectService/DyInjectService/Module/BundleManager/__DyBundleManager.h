//
//  __DyBundleManager.h
//  DyInjectService
//
//  Created by Shawn on 2016/10/22.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZipArchiveMethod)

-(BOOL) UnzipOpenFile:(NSString*) zipFile;

-(BOOL) UnzipCloseFile;

-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;

@property (nonatomic, readonly) NSArray* unzippedFiles;

@end

/**
 动态库如果在真机上也是需要签名的 如果调用远程加载bundle一定要提前对动态库签名
 */
@interface __DyBundleManager : NSObject

+ (instancetype)shareBundleManager;

@property (nonatomic, readonly, copy) NSArray * allLoadBundles;

@end
