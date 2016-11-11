//
//  __DyDatabaseManager.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface __DyDatabaseManager : NSObject

/**
 database manager 是基于  FMDatabase 做监听 如果宿主app没有添加这个库功能暂不可用

 @return nil 没有实现
 */
+ (instancetype)shareDatabaseManager;

@property (nonatomic) BOOL sendPacketWhenHandleDatabase; //YES 如果宿主app发生对app的操作都会自动发送给监控端 如果为 NO 就不会发送 可以通过监控端配置

- (void)handleDatabase:(id)databasehandle;

- (id)executeQuerySql:(NSString *)sql inDataBaseFilePath:(NSString *)filePath;

- (void)hookRecordWithType:(NSString *)type sql:(NSString *)sql parameter:(NSArray *)parameter;
@end
