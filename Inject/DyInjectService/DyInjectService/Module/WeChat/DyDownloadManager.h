//
//  DyDownloadManager.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/18.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DyDownloadManagerCompletion)(NSArray * images);

@interface DyDownloadManager : NSObject

@property (nonatomic, strong) NSMutableArray * downloadItems;
@property (nonatomic, strong) NSMutableArray * downloadWarps;
@property (nonatomic, strong) id downloadMgr;
@property (nonatomic, copy) DyDownloadManagerCompletion completion;

- (instancetype)initWithItems:(NSArray *)items completion:(DyDownloadManagerCompletion)completion;

@end
