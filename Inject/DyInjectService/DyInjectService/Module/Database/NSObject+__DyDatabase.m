//
//  NSObject+__DyDatabase.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "NSObject+__DyDatabase.h"
#import "__DyDatabaseManager.h"

@implementation NSObject (__DyDatabase)

// FMDatabase

- (BOOL)__dysetKeyWithData:(NSData *)keyDat
{
    NSString * type = [NSString stringWithFormat:@"%s",__FUNCTION__];
    NSArray * parameter = nil;
    if (keyDat) {
        NSString * key = [[NSString alloc]initWithData:keyDat encoding:NSUTF8StringEncoding];
        if (key) {
            parameter = @[key];
        }
    }
//    [[__DyDatabaseManager shareDatabaseManager]hookRecordWithType:type sql:nil parameter:parameter];
    
    // add database point to custom service
    [[__DyDatabaseManager shareDatabaseManager] handleDatabase:self];

    return [self __dysetKeyWithData:keyDat];
}

- (id)__dyexecuteQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args
{
//    NSString * type = [NSString stringWithFormat:@"%s",__FUNCTION__];
    NSArray * parameter = nil;
    if (arrayArgs) {
        parameter = arrayArgs;
    }else if (dictionaryArgs)
    {
        parameter = @[dictionaryArgs];
    }
//    [[__DyDatabaseManager shareDatabaseManager]hookRecordWithType:type sql:sql parameter:parameter];
    
    // add database point to custom service
    [[__DyDatabaseManager shareDatabaseManager] handleDatabase:self];

    return [self __dyexecuteQuery:sql withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
}

- (BOOL)__dyexecuteUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args
{
    // record
    NSString * type = [NSString stringWithFormat:@"%s",__FUNCTION__];
    NSArray * parameter = nil;
    if (arrayArgs) {
        parameter = arrayArgs;
    }else if (dictionaryArgs)
    {
        parameter = @[dictionaryArgs];
    }
    
//    [[__DyDatabaseManager shareDatabaseManager]hookRecordWithType:type sql:sql parameter:parameter];
    
    // add database point to custom service
    [[__DyDatabaseManager shareDatabaseManager] handleDatabase:self];

    return [self __dyexecuteUpdate:sql error:outErr withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
}

// FMDatabaseQueue

- (void)__dyinDatabase:(void (^)(NSObject * db))block
{
    // add database point to custom service
    [[__DyDatabaseManager shareDatabaseManager] handleDatabase:self];

    [self __dyinDatabase:block];
}

@end
