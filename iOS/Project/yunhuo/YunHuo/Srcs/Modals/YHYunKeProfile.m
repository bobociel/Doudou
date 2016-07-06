//
//  YHYunKeProfile.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunKeProfile.h"

@implementation YHYunKeProfile

+ (NSString*) createTableSql
{
	return @"create table APVInfo( index integer primary key, phone integer, name text, email text, gender integer, avatarURLStr text)";
}

- (id) initWithResult:(FMResultSet*)result
{
	self = [super init];
	if (self != nil) {
		self.index = [result longLongIntForColumn:@"index"];
		self.phone = [result longLongIntForColumn:@"phone"];
		self.name = [result stringForColumn:@"name"];
		self.email = [result stringForColumn:@"email"];
		self.gender= [result intForColumn:@"gender"];
		self.avatarURLStr = [result stringForColumn:@"avatarURLStr"];
	}
	return self;
}

- (void) saveToDB
{
	FMDatabase *db = [YHDataCache instance].db;
	[[YHDataCache instance] createTableOfClass:@"YHYunKeProfile"];
		
	if ([[YHDataCache instance] recordExisted:self])
	{
		[db executeUpdate:@"update YHYunKeProfile set index = ?, phone = ?, name = ?, email = ?, gender = ?, avatarURLStr = ?",
		 @(self.index), @(self.phone), self.name, self.email, @(self.gender), self.avatarURLStr];
		if ([db hadError])
		{
			NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		}
	}
	else
	{
		[db executeUpdate:@"insert into YHYunKeProfile (index, phone, name, email, gender, avatarURLStr) values (?, ?, ?, ?, ?, ?)",
		  @(self.index), @(self.phone), self.name, self.email, @(self.gender), self.avatarURLStr];
	}
}

- (instancetype) init
{
	if ( self = [super init] )
	{
		self.avatar = [UIImage imageNamed:@"DefaultAvatar"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	EncodeLong(self.phone, aCoder);
	EncodeObject(self.name, aCoder);
	EncodeObject(self.email, aCoder);
	EncodeInt(self.gender, aCoder);
	EncodeObject(self.avatar, aCoder);
}

- (id) initWithCoder:(NSCoder*)aDecoder
{
	if  ( self = [super init] )
	{
		DecodeLong(self.phone, aDecoder);
		DecodeObject(self.name, aDecoder);
		DecodeObject(self.email, aDecoder);
		DecodeInt(self.gender, aDecoder);
		DecodeObject(self.avatar, aDecoder);
	}
	return self;
}

@end
