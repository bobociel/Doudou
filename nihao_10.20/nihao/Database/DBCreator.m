//
//  DBCreator.m
//  nihao 数据库创建者
//
//  Created by 刘志 on 15/7/7.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "DBCreator.h"

@implementation DBCreator

//数据库名字,不可修改
static NSString *const dbName = @"nihao.db";

//数据库版本号
static const NSInteger dbVersion = 1.0;

+ (FMDatabase *) getDatabase {
    NSString *dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
    NSLog(@"db path---> %@",dbPath);
    NSFileManager *manager = [NSFileManager defaultManager];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if(![manager fileExistsAtPath:dbPath]) {
        //创建表
        [db open];
        [self createTables:db];
    }
    return db;
}

/**
 *  根据create.sql的语句创建表
 */
+ (void) createTables : (FMDatabase *) db{
    NSString *sqlFilePath = [[NSBundle mainBundle] pathForResource:@"create" ofType:@".sql"];
    NSString *content = [NSString stringWithContentsOfFile:sqlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *sqls = [content componentsSeparatedByString:@";"];
    for(NSString *sql in sqls) {
        [db executeStatements:sql];
    }
}

@end
