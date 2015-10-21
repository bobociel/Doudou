//
//  BaseDao.h
//  nihao 执行基本的增删改查操作
//
//  Created by 刘志 on 15/7/7.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMResultSet.h>

@interface BaseDao : NSObject

//查询返回结果
typedef void(^QueryBlock) (FMResultSet *set);

/**
 *  执行一段sql，可用来执行增加，删除，修改操作
 *
 *  @param sql       sql语句
 *  @param arguments sql语句的参数
 *
 *  @return 用来说明sql是否执行成功
 */
- (BOOL) executeSql:(NSString *) sql arguments : (NSDictionary *) arguments;

/**
 *  执行查询操作，返回操作的结果集
 *
 *  @param sql       查询sql语句
 *  @param arguments 查询参数
 *
 *  @return 结果集
 */
- (void) executeQuery : (NSString *) sql arguments : (NSDictionary *) arguments queryBlock : (QueryBlock) queryBlock;

/**
 *  执行多条sql语句，事务操作
 *
 *  @param sql sql语句
 *
 *  @return 是否执行成功
 */
- (BOOL) executeStatements : (NSString *) sql;

/**
 *  关闭数据库
 */
- (void) closeDB;

@end
