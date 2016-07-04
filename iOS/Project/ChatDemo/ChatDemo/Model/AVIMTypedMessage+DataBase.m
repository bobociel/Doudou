//
//  AVIMTypedMessage+DataBase.m
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "AVIMTypedMessage+DataBase.h"

@implementation AVIMTypedMessage (DataBase)
- (NSString *)ID
{
	return self.messageId;
}

- (id)modelToJSONObject
{
	NSMutableDictionary *messgaeDict = [NSMutableDictionary dictionary];
	[messgaeDict setObject:self.conversationId forKey:@"conversationId"];
	[messgaeDict setObject:self.messageId forKey:@"messageId"];
	NSData *messgaeData = [NSKeyedArchiver archivedDataWithRootObject:self];
	[messgaeDict setObject:messgaeData forKey:@"data"];
	return messgaeDict;
}

- (NSString *)createTableSql
{
	return @"CREATE TABLE IF NOT EXISTS AVIMTypedMessage (conversationId VARCHAR(20), messageId VARCHAR(20), data BLOB NOT BULL, primary key (messageId))";
}

- (NSString *)replaceDataSql
{
	return @"REPLACE INTO AVIMTypedMessage (conversationId, messageId, data,) VALUES(:conversationId, :messageId, :data )";
}

- (NSString *)deleteDataSql
{
	return @"DELETE FROM AVIMTypedMessage WHERE conversationId = ?";
}

-(NSString *)deleteAllDataSql
{
	return @"DELETE FROM AVIMTypedMessage";
}

@end
