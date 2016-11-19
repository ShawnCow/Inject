//
//  NSObject+LocationMock.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/15.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSObject (LocationMock)

+ (void)___dyMockLocationCoordinate2D:(CLLocationCoordinate2D)coordinate;

+ (void)switchMockLocationEnable:(BOOL)enable;

+ (BOOL)mockLocationEnable;

@end
