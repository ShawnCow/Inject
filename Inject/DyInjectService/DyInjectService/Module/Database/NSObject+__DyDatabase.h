//
//  NSObject+__DyDatabase.h
//  DyInjectService
//
//  Created by Shawn on 2016/11/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (__DyDatabase)

// FMDatabase
- (BOOL)__dysetKey:(NSString*)key;

- (BOOL)__dysetKeyWithData:(NSData *)keyDat;

- (id)__dyexecuteQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args ;

- (BOOL)__dyexecuteUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;

// FMDatabaseQueue

- (void)__dyinDatabase:(void (^)(NSObject * db))block;

@end
