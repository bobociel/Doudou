//
//  BaseDao.m
//  nihao
//
//  Created by 刘志 on 15/7/7.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseDao.h"
#import "DBCreator.h"

@implementation BaseDao {
    FMDatabase *_db;
}

- (instancetype) init {
    self = [super init];
    if(self) {
        _db = [DBCreator getDatabase];
    }
    return self;
}

- (BOOL) executeSql:(NSString *)sql arguments:(NSDictionary *)arguments {
    if(![_db open]) {
        //数据库未开启，直接返回no
        return NO;
    }
    
    BOOL result = [_db executeUpdate:sql withParameterDictionary:arguments];
    NSLog(@"%@",result ? @"execute sql success" : @"execute sql fail");
    return result;
}

- (void) executeQuery : (NSString *) sql arguments : (NSDictionary *) arguments queryBlock : (QueryBlock) queryBlock {
    if(![_db open]) {
        return;
    }
    FMResultSet *set = [_db executeQuery:sql withParameterDictionary:arguments];
    queryBlock(set);
    [set close];
}

- (BOOL) executeStatements : (NSString *) sql {
    if(![_db open]) {
        return NO;
    }
    return [_db executeStatements:sql];
}

- (void) closeDB {
    if(_db) {
        [_db close];
        _db = nil;
    }
}

- (void) dealloc {
    if(_db) {
        [_db close];
        _db = nil;
    }
}

@end
