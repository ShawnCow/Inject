//
//  __DyBundleManager.h
//  DyInjectService
//
//  Created by Shawn on 2016/10/22.
//  Copyright © 2016年 OneStore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZipArchiveMethod)

-(id) initWithFileManager:(NSFileManager*) fileManager;

-(BOOL) UnzipOpenFile:(NSString*) zipFile;

-(BOOL) UnzipCloseFile;

-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;


@property (nonatomic, readonly) NSArray* unzippedFiles;

@end

@interface __DyBundleManager : NSObject

+ (instancetype)shareBundleManager;

@property (nonatomic, readonly, copy) NSArray * allLoadBundles;

@end
