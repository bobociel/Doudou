//
//  AVIMKeyedConversation+Database.m
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "AVIMKeyedConversation+Database.h"

@implementation AVIMKeyedConversation (Database)
- (NSString *)ID
{
	return self.conversationId;
}

- (id)modelToJSONObject
{
	NSMutableDictionary *messgaeDict = [NSMutableDictionary dictionary];
	[messgaeDict setObject:self.conversationId forKey:@"conversationId"];
	NSData *messgaeData = [NSKeyedArchiver archivedDataWithRootObject:self];
	[messgaeDict setObject:messgaeData forKey:@"data"];
	return messgaeDict;
}

- (NSString *)createTableSql
{
	return @"CREATE TABLE IF NOT EXISTS AVIMKeyedConversation (conversationId VARCHAR(20), data BLOB NOT NULL, primary key (conversationId))";
}

- (NSString *)replaceDataSql
{
	return @"REPLACE INTO AVIMKeyedConversation (conversationId, data BLOB) VALUES(:conversationId, :data)";
}

- (NSString *)deleteDataSql
{
	return @"DELETE FROM AVIMKeyedConversation WHERE conversationId = ? ";
}

- (NSString *)deleteAllDataSql
{
	return @"DELETE FROM AVIMKeyedConversation ";
}

@end

@implementation AVIMConversation (Database)
- (NSString *)ID
{
	return self.conversationId;
}

- (id)modelToJSONObject
{
	NSMutableDictionary *messgaeDict = [NSMutableDictionary dictionary];
	[messgaeDict setObject:self.conversationId forKey:@"conversationId"];
	NSData *messgaeData = [NSKeyedArchiver archivedDataWithRootObject:self.keyedConversation];
	[messgaeDict setObject:messgaeData forKey:@"data"];
	return messgaeDict;
}

- (NSString *)createTableSql
{
	return @"";
}

- (NSString *)replaceDataSql
{
	return @"REPLACE INTO AVIMKeyedConversation (conversationId, data BLOB) VALUES(:conversationId, :data)";
}

- (NSString *)deleteDataSql
{
	return @"";
}

- (NSString *)deleteAllDataSql
{
	return @"";
}

@end
