//
//  __DyDatabaseManager.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "__DyDatabaseManager.h"
#import "NSObject+__DyInjectSwizzle.h"
#import "__DyDatabaseItem.h"
#import "NSObject+__DyDatabase.h"
#import "XXPacket.h"
#import "XXListenerConnectManager.h"
#import "__XXDyInjectRouter.h"
#import "NSObject+DyInjectRouter.h"

@interface NSObject (FMDatabaseMethod)

// FMDatabase
- (BOOL)setKey:(NSString*)key;

- (NSString *)databasePath;

- (BOOL)setKeyWithData:(NSData *)keyDat;

- (id)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args ;

- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;

- (NSString*)lastErrorMessage;

// FMDatabaseQueue

- (id)database;

- (void)inDatabase:(void (^)(NSObject * db))block;

//FMResultSet

- (NSDictionary*)resultDictionary;

- (BOOL)next;

- (NSString*)stringForColumn:(NSString*)columnName;

- (int)columnCount;

- (NSString*)columnNameForIndex:(int)columnIdx;

@end

@interface __DyDatabaseManager ()
{
    NSMutableDictionary * __databaseInfoDic;
}
@end

@implementation __DyDatabaseManager

static __DyDatabaseManager * databasemanager = nil;

+ (void)load
{
    Class databaseClass = NSClassFromString(@"FMDatabase");
    if (databaseClass) {
        databasemanager = [__DyDatabaseManager new];
        [databaseClass ___exchangeMethod:@selector(setKeyWithData:) withMethod:@selector(__dysetKeyWithData:)];
        [databaseClass ___exchangeMethod:@selector(executeUpdate:error:withArgumentsInArray:orDictionary:orVAList:) withMethod:@selector(__dyexecuteUpdate:error:withArgumentsInArray:orDictionary:orVAList:)];
        [databaseClass ___exchangeMethod:@selector(executeQuery:withArgumentsInArray:orDictionary:orVAList:) withMethod:@selector(__dyexecuteQuery:withArgumentsInArray:orDictionary:orVAList:)];
        
        
        [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"database" completion:^id(id<XXPacketProtocol> packet) {
           
            NSDictionary * dictionary = [packet packetDictionary];
            NSString * type = dictionary[@"type"];
            if ([type isEqualToString:@"switchsendrecord"]) {
                databasemanager.sendPacketWhenHandleDatabase = [dictionary[@"on"] boolValue];
                return @"switchsendrecord success";
                
            }else if ([type isEqualToString:@"query"])
            {
                NSString * sql = dictionary[@"sql"];
                NSString * filePath = dictionary[@"path"];
                NSDictionary * resultDic = [databasemanager executeQuerySql:sql inDataBaseFilePath:filePath];
                XXPacket * packet = [[XXPacket alloc]initWithAction:@"database" infoDic:resultDic packetData:nil];
                [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:packet];
            }else if ([type isEqualToString:@"listpath"])
            {
                NSArray * array = [databasemanager allDatabasePath];
                return array;
            }
            
            return @"success";
        }];
    }
}

+ (instancetype)shareDatabaseManager
{
    return databasemanager;
}

- (id)init
{
    self = [super init];
    if (self) {
        __databaseInfoDic = [NSMutableDictionary dictionary];
        _sendPacketWhenHandleDatabase = YES;
    }
    return self;
}

- (void)handleDatabase:(id)databasehandle
{
    NSString * databaseFilePath = nil;
    
    BOOL isQueue = NO;
    
    if ([databasehandle isKindOfClass:NSClassFromString(@"FMDatabase")]) {
        databaseFilePath = [databasehandle databasePath];
    }else if ([databasehandle isKindOfClass:NSClassFromString(@"FMDatabaseQueue")])
    {
        isQueue = YES;
        databaseFilePath = [[databasehandle database]databasePath];
    }
    
    if (!databaseFilePath) {
        return;
    }
    
    __DyDatabaseItem * databaseObj = nil;
    @synchronized (__databaseInfoDic) {
        databaseObj = __databaseInfoDic[databaseFilePath];
    }
    
    if (databaseObj == nil) {
        __DyDatabaseItem * item = [[__DyDatabaseItem alloc]init];
        item.database = databasehandle;
        item.databasePath = databaseFilePath;
        @synchronized (__databaseInfoDic) {
            __databaseInfoDic[databaseFilePath] = item;
        }
        return;
    }
    
    if (databaseObj && databaseObj.database == databasehandle) {
        return;
    }
    if (isQueue && [databaseObj.database isKindOfClass:NSClassFromString(@"FMDatabase")]) {//如果是queue优先保存queue 因为线程安全 减少崩溃
        databaseObj.database = databasehandle;
    }
}

- (NSArray *)allDatabasePath
{
    NSArray * tempArray = nil;
    @synchronized (__databaseInfoDic) {
        tempArray = [__databaseInfoDic allValues];
    }
    NSMutableArray * filePaths = [NSMutableArray array];
    for (__DyDatabaseItem * item in tempArray) {
        if (item.database) {
            if (item.databasePath) {
                [filePaths addObject:item.databasePath];
            }
        }
    }
    return filePaths;
}

- (id)executeQuerySql:(NSString *)sql inDataBaseFilePath:(NSString *)filePath
{
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
    if (!sql || !filePath) {
        resultDic[@"result"] = @"false";
        resultDic[@"reason"] = @"sql or file path is null";
        return resultDic;
    }
    
    resultDic[@"sql"] = sql;
    __DyDatabaseItem * item = nil;
    @synchronized (__databaseInfoDic) {
        item = __databaseInfoDic[filePath];
    }
    if (!item) {
        resultDic[@"result"] = @"false";
        resultDic[@"reason"] = @"database path is not record";
    }else
    {
        if (item.database == nil) {
            resultDic[@"result"] = @"false";
            resultDic[@"reason"] = @"database is dealloc";
        }else
        {
            if ([item.database isKindOfClass:NSClassFromString(@"FMDatabase")]) {
                id resultSet = [item.database __dyexecuteQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:nil];
                if (resultSet) {
                    NSDictionary * queryResultDic = [resultSet resultDictionary];
                    if (queryResultDic) {
                        resultDic[@"result"] = @"true";
                        resultDic[@"info"] = queryResultDic;
                    }else
                    {
                        resultDic[@"result"] = @"true";
                        resultDic[@"info"] =  @"query success but result is null";
                        
                        //如果没有查询成功 可能是查table的语句
                        NSMutableDictionary * tempResult = [NSMutableDictionary dictionary];
                        int allColumne = [resultSet columnCount];
                        while ([resultSet next]) {
                            
                            for (int i = 0 ; i < allColumne; i ++) {
                                NSString * name = [resultSet columnNameForIndex:i];
                                if (name) {
                                    
                                    NSString * tempText = [resultSet stringForColumn:name];
                                    if (tempText) {
                                        [tempResult setObject:tempText forKey:name];
                                    }
                                }
                            }
                        }
                        resultDic[@"result"] = tempResult;
                    }
                }else
                {
                    resultDic[@"result"] = @"false";
                    resultDic[@"reason"] = [NSString stringWithFormat:@"sql execute failed %@",[item.database lastErrorMessage]];
                }
            }else if ([item.database isKindOfClass:NSClassFromString(@"FMDatabaseQueue")])
            {
                resultDic[@"result"] = @"true";
                resultDic[@"info"] = @"database handle is queue, submit execut sql";
                [item.database inDatabase:^(NSObject *db) {
                   
                    NSMutableDictionary * synResultDic = [NSMutableDictionary dictionary];
                    synResultDic[@"sql"] = sql;
                    id __resultSet = [db __dyexecuteQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:nil];
                    if (__resultSet) {
                        NSDictionary * __queryResultDic = [__resultSet resultDictionary];
                        if (__queryResultDic) {
                            synResultDic[@"result"] = @"true";
                            synResultDic[@"info"] = __queryResultDic;
                        }else
                        {
                            synResultDic[@"result"] = @"true";
                            synResultDic[@"info"] =  @"query success but result is null";
                            
                            //如果没有查询成功 可能是查table的语句
                            NSMutableArray * tempResult = [NSMutableArray array];
                            while ([__resultSet next]) {
                                NSString * name = [__resultSet stringForColumn:@"name"];
                                if (name) {
                                    [tempResult addObject:name];
                                }
                            }
                            synResultDic[@"tables"] = tempResult;
                        }
                    }else
                    {
                        synResultDic[@"result"] = @"false";
                        synResultDic[@"reason"] = [NSString stringWithFormat:@"sql execute failed %@",[db lastErrorMessage]];
                    }
                    
                    XXPacket * packet = [[XXPacket alloc]initWithAction:@"database" infoDic:synResultDic packetData:nil];
                    [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:packet];
                }];
            }
        }
    }
    
    return resultDic;
}

- (void)hookRecordWithType:(NSString *)type sql:(NSString *)sql parameter:(NSArray *)parameter
{
    if (self.sendPacketWhenHandleDatabase == NO) {
        return;
    }
    if (!type) {
        return;
    }
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    tempDic[@"type"] = type;
    tempDic[@"sql"] = [NSString stringWithFormat:@"%@",sql];
    tempDic[@"parameter"] = [NSString stringWithFormat:@"%@",parameter];
    XXPacket * packet = [[XXPacket alloc]initWithAction:@"database" infoDic:tempDic packetData:nil];
    [[XXListenerConnectManager currentListenerConnectManager]inQueueWithPacket:packet];
}

@end
