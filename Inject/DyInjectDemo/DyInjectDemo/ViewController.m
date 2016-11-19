//
//  ViewController.m
//  DyInjectDemo
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "DyActionSheet.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
{
    NSMutableArray * array;
    NSString * docPath ;
     CLLocationCoordinate2D _location;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _location = CLLocationCoordinate2DMake(40, 116);
    
    NSValue * tempValue = [self valueForKey:@"_location"];
    CLLocationCoordinate2D tempCoord ;
    [tempValue getValue:&tempCoord];
    
    // Do any additional setup after loading the view, typically from a nib.
    array = [NSMutableArray array];
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    [DyActionSheet showWithTitle:@"test" moreActions:@[@"1",@"2"] completion:^(NSInteger buttonIndex) {
        NSLog(@"button %d",buttonIndex);
    }];
}

@end
