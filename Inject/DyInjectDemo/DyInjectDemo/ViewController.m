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

@interface ViewController ()
{
    NSMutableArray * array;
    NSString * docPath ;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    array = [NSMutableArray array];
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [self test1];
    [self test];
    [self test2];
    [self test3];
    [self __test];
}

- (void)__test
{
    [self test1];
    [self test];
    [self test2];
    [self test3];
    [self test1];
    [self test];
    [self test2];
    [self test3];
    [self performSelector:@selector(___test2) withObject:nil afterDelay:1.];
}

- (void)___test2
{
    
    [self performSelectorInBackground:@selector(__test) withObject:nil];
}
- (void)test1
{
    NSString * name = @"test1";
    NSString * filePath = [docPath stringByAppendingPathComponent:name];
    FMDatabase * database = [FMDatabase databaseWithPath:filePath];
    [database open];
    [array addObject:database];
    NSString * shoplistTable = @"create table Shopplist(uuid text, title text, alarmTime text,listStatus integer,shoppinglist text, createdate text, finishdate text, needUpdate text, itemid text, version text, createBy text,updateBy text ,updateTime text, isshare bool)";
    [database executeUpdate:shoplistTable];
    for (int i = 0; i < 10; i ++) {
        NSString *  sql = @"insert into ShopplistDetail(uuid, itemid, title, itemStatus, images, routerUrl, createDate, itemid, version, createBy ,updateBy , updateTime) values(?,?,?,?,?,?,?,?,?,?,?,?)";
        NSMutableArray * p = [NSMutableArray array];
        for (int j = 0; j < 12; j ++) {
            [p addObject:@"1"];
        }
        [database executeQuery:sql withArgumentsInArray:p];
    }
}


- (void)test
{
    NSString * name = @"test";
    NSString * filePath = [docPath stringByAppendingPathComponent:name];
    FMDatabase * database = [FMDatabase databaseWithPath:filePath];
    [database open];
    [array addObject:database];
    NSString * shoplistTable = @"create table Shopplist(uuid text, title text, alarmTime text,listStatus integer,shoppinglist text, createdate text, finishdate text, needUpdate text, itemid text, version text, createBy text,updateBy text ,updateTime text, isshare bool)";
    [database executeUpdate:shoplistTable];
    for (int i = 0; i < 10; i ++) {
        NSString *  sql = @"insert into ShopplistDetail(uuid, itemid, title, itemStatus, images, routerUrl, createDate, itemid, version, createBy ,updateBy , updateTime) values(?,?,?,?,?,?,?,?,?,?,?,?)";
        NSMutableArray * p = [NSMutableArray array];
        for (int j = 0; j < 12; j ++) {
            [p addObject:@"1"];
        }
        [database executeQuery:sql withArgumentsInArray:p];
    }
}


- (void)test2
{
    NSString * name = @"test2";
    NSString * filePath = [docPath stringByAppendingPathComponent:name];
    FMDatabase * database = [FMDatabase databaseWithPath:filePath];
    [database open];
    [array addObject:database];
    NSString * shoplistTable = @"create table Shopplist(uuid text, title text, alarmTime text,listStatus integer,shoppinglist text, createdate text, finishdate text, needUpdate text, itemid text, version text, createBy text,updateBy text ,updateTime text, isshare bool)";
    [database executeUpdate:shoplistTable];
    for (int i = 0; i < 10; i ++) {
        NSString *  sql = @"insert into ShopplistDetail(uuid, itemid, title, itemStatus, images, routerUrl, createDate, itemid, version, createBy ,updateBy , updateTime) values(?,?,?,?,?,?,?,?,?,?,?,?)";
        NSMutableArray * p = [NSMutableArray array];
        for (int j = 0; j < 12; j ++) {
            [p addObject:@"1"];
        }
        [database executeQuery:sql withArgumentsInArray:p];
    }
}


- (void)test3
{
    NSString * name = @"test3";
    NSString * filePath = [docPath stringByAppendingPathComponent:name];
    FMDatabase * database = [FMDatabase databaseWithPath:filePath];
    [database open];
    [array addObject:database];
    NSString * shoplistTable = @"create table Shopplist(uuid text, title text, alarmTime text,listStatus integer,shoppinglist text, createdate text, finishdate text, needUpdate text, itemid text, version text, createBy text,updateBy text ,updateTime text, isshare bool)";
    [database executeUpdate:shoplistTable];
    for (int i = 0; i < 10; i ++) {
        NSString *  sql = @"insert into Shopplist(uuid) values(?)";
        NSMutableArray * p = [NSMutableArray array];
        [p addObject:@"1"];
//        [database executeQuery:sql withArgumentsInArray:p];
        BOOL result = [database executeUpdate:sql values:p error:nil];
        if (result) {
            NSLog(@"result yes");
        }else
            NSLog(@"result no");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
