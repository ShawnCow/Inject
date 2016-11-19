//
//  DyDownloadManager.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/18.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyDownloadManager.h"
#import <UIKit/UIKit.h>

@interface NSObject (MethodDefineInDownloadManager)
//DownloadMediaWrap
- (id)initWithMediaItem:(id)arg1 downloadType:(int)arg2;
- (UIImage *)resultImage;
//WCDownloadMgr
- (void)doDownloadMediaCDN:(id)arg1;
//MMImage
- (id)initWithImage:(UIImage *)arg1;
@end

@implementation DyDownloadManager

- (instancetype)initWithItems:(NSArray *)items completion:(DyDownloadManagerCompletion)completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        id dy_manager = [[NSClassFromString(@"WCDownloadMgr") alloc]init];
        [dy_manager setValue:self forKey:@"m_delegate"];
        self.downloadMgr = dy_manager;
        
        self.downloadItems = [NSMutableArray array];
        self.downloadWarps = [NSMutableArray array];
        
        for (id mediaWarp in items) {
            id mediaItem = [mediaWarp valueForKey:@"mediaItem"];
            id downloadWarps = [[NSClassFromString(@"DownloadMediaWrap") alloc]initWithMediaItem:mediaItem downloadType:1];
            [dy_manager doDownloadMediaCDN:downloadWarps];
            [self.downloadItems addObject:mediaItem];
            [self.downloadWarps addObject:downloadWarps];
        }
    }
    return self;
}

- (void)onDownloadFinish:(id)arg1 downloadType:(int)arg2
{
    NSLog(@"onDownloadFinish %@",arg1);
    if (arg1) {
        NSMutableArray * tempitems = [self downloadItems];
        [tempitems removeObject:arg1];
        if (tempitems.count == 0) {
            NSMutableArray * tempImgs = [NSMutableArray array];
            for (id downloadWarp in [self downloadWarps]) {
                UIImage * tempImg = [downloadWarp resultImage];
                if (tempImg) {
                    UIImage * mImg = [[NSClassFromString(@"MMImage") alloc]initWithImage:tempImg];
                    if (mImg) {
                        [tempImgs addObject:mImg];
                    }
                }else
                {
                    NSLog(@"download wap %@",downloadWarp);
                }
            }
            
            if (self.completion) {
                self.completion (tempImgs);
            }
            self.completion = nil;
        }
    }
}

- (void)onAddDownloadQueue:(id)arg1 downloadType:(int)arg2
{
    NSLog(@"onAddDownloadQueue %@",arg1);
}
- (void)onBeginDownload:(id)arg1 downloadType:(int)arg2
{
    NSLog(@"onBeginDownload %@",arg1);
}
- (void)onCancelDownloadSuccess:(id)arg1 downloadType:(int)arg2
{
    NSLog(@"onCancelDownloadSuccess %@",arg1);
}
- (void)onDownloadMediaProcessChange:(id)arg1 downloadType:(int)arg2 current:(int)arg3 total:(int)arg4
{
    NSLog(@"onDownloadMediaProcessChange %@ %d %d %d",arg1,arg2,arg3,arg4);
}

@end
