//
//  UserInfo.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/30.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

#pragma mark - Model
+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
	UserInfo *user = [UserInfo new];
	user.ID = [LWUtil getString:dict[@"id"] andDefaultStr:@""];
	user.name = [LWUtil getString:dict[@"name"] andDefaultStr:@""];
	user.group_id = [LWUtil getString:dict[@"group_id"] andDefaultStr:@"3"];
	user.avatar = [LWUtil getString:dict[@"avatar"] andDefaultStr:@""];
	user.phone = [LWUtil getString:dict[@"phone"] andDefaultStr:@""];
	return user;
}

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyWhitelist{
	return @[@"ID",@"group_id",@"name",@"phone",@"avatar"];
}


#pragma mark - SQLiteProtocol
- (NSString *)createTableSql{
	return @"CREATE TABLE IF NOT EXISTS user (id VARCHAR(20), name TEXT, group_id VARCHAR(20), avatar TEXT, phone VARCHAR(20), primary key (id))";
}

- (NSString *)replaceDataSql{
	return @"REPLACE INTO user (id, name, group_id, avatar, phone) values (:id, :name, :group_id, :avatar, :phone)";
}

- (NSString *)deleteDataSql{
	return  @"DELETE FROM user WHERE id = ?";
}

- (NSString *)deleteAllDataSql{
	return  @"DELETE FROM user";
}

@end
