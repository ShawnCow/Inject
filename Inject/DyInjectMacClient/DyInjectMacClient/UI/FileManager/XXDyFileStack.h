//
//  XXDyFileStack.h
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXDyFileStack : NSObject

@property (nonatomic, readonly) NSArray * visiblePaths;

@property (nonatomic,readonly) NSInteger stackCount;

- (void)pushPaths:(NSArray *)paths;

- (NSArray *)pop;

@end
