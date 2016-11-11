//
//  XXDyFileStack.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXDyFileStack.h"

@interface XXDyFileStack ()
{
    NSMutableArray * stackArray;
}
@end

@implementation XXDyFileStack

- (instancetype)init
{
    self = [super init];
    if (self) {
        stackArray = [NSMutableArray array];
        NSArray * firstItem = @[@"Document",@"Bundle",@"Cache"];
        [self pushPaths:firstItem];
    }
    return self;
}

- (void)pushPaths:(NSArray *)paths
{
    [stackArray addObject:paths];
}

- (NSArray *)pop
{
    NSArray * paths = [stackArray lastObject];
    [stackArray removeLastObject];
    return paths;
}

- (NSArray *)visiblePaths
{
    return [stackArray lastObject];
}

- (NSInteger)stackCount
{
    return stackArray.count;
}

@end
