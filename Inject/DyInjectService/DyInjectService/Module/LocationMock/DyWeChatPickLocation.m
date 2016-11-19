//
//  DyWeChatPickLocation.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/19.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyWeChatPickLocation.h"
#import "NSObject+LocationMock.h"

@implementation DyWeChatPickLocation

- (instancetype)initWithSourceViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _sourceViewController = viewController;
        
        UIViewController * vc = [[NSClassFromString(@"MMPickLocationViewController") alloc]initWithScene:0 OnlyUseUserLocation:NO];
        
        UINavigationController * nai = nil;
//        if ([viewController isKindOfClass:[UINavigationController class]]) {
//            nai = (UINavigationController *)viewController;
//        }else if ([viewController isKindOfClass:[UIViewController class]])
//        {
//            nai = viewController.navigationController;
//        }
//        NSLog(@"nv %@",vc);
        [vc setValue:self forKey:@"delegate"];
        self.viewController = vc;
        if (nai) {
            [nai pushViewController:vc animated:YES];
        }else
        {
            nai = [[NSClassFromString(@"MMUINavigationController") alloc]initWithRootViewController:vc];
            [viewController presentViewController:nai animated:YES completion:nil];
        }
    }
    return self;
}

- (UIBarButtonItem *)onGetRightBarButton
{
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:@"修改" style:0 target:self action:@selector(doneBtnAction)];
    return item;
}

- (void)onCancelSeletctedLocation
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    _sourceViewController = nil;
    self.viewController = nil;
}

- (void)doneBtnAction
{
    NSValue * value = [self.viewController valueForKey:@"_lastSelectedLocation"];
    CLLocationCoordinate2D lastSelectedLocation ;
    [value getValue:&lastSelectedLocation];
    NSLog(@"last %f %f",lastSelectedLocation.latitude, lastSelectedLocation.longitude);
    
    value = [self.viewController valueForKey:@"_firstGetNearLocation"];
    CLLocationCoordinate2D firstGetNearLocation ;
    [value getValue:&firstGetNearLocation];
    NSLog(@"firstGetNearLocation %f %f",firstGetNearLocation.latitude, firstGetNearLocation.longitude);
    
    value = [self.viewController valueForKey:@"_lastDragLocation"];
    CLLocationCoordinate2D lastDragLocation ;
    [value getValue:&lastDragLocation];
    NSLog(@"lastDragLocation %f %f",lastDragLocation.latitude, lastDragLocation.longitude);
    
    [NSObject ___dyMockLocationCoordinate2D:lastSelectedLocation];
    [self onCancelSeletctedLocation];
}

@end
