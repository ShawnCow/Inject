//
//  UIImage+MMImage.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/18.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "UIImage+MMImage.h"
#import "NSObject+__DyInjectSwizzle.h"


@implementation UIImage (MMImage)

+ (void)load
{
    Class imgClass = NSClassFromString(@"MMImage");
    if (imgClass) {
        [imgClass ___exchangeMethod:@selector(initWithImage:) withMethod:@selector(dyInitWithImage:)];
    }
}

- (id)dyInitWithImage:(id)arg1
{
    NSLog(@"dyInitWithImage type %@",[arg1 class]);
    return [self dyInitWithImage:arg1];
}

@end
