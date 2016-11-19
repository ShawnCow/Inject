//
//  NSObject+LocationMock.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/15.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+LocationMock.h"
#import "NSObject+__DyInjectSwizzle.h"

@interface NSObject (DyLocationMockPrivate)

- (CLLocationCoordinate2D)coordinate;

@end

@implementation NSObject (LocationMock)

static BOOL mockLocationEnable = NO;
static CLLocationCoordinate2D mockLocationCoordinate2D;

+ (void)load
{
    Class locationClass = NSClassFromString(@"CLLocation");
    if (locationClass) {
        [locationClass ___exchangeMethod:@selector(coordinate) withMethod:@selector(___dyLocationCoordinate)];
    }
}

- (CLLocationCoordinate2D)___dyLocationCoordinate
{
    if (mockLocationEnable) {
        return mockLocationCoordinate2D;
    }else
        return [self ___dyLocationCoordinate];
}

+ (void)___dyMockLocationCoordinate2D:(CLLocationCoordinate2D)coordinate
{
    mockLocationEnable = YES;
    mockLocationCoordinate2D = coordinate;
}

+ (void)switchMockLocationEnable:(BOOL)enable
{
    mockLocationEnable = enable;
}

+ (BOOL)mockLocationEnable
{
    return mockLocationEnable;
}

@end
