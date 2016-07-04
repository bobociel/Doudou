//
//  YHDataCache.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHDataCache.h"
#import "FMDB.h"

static YHDataCache* _instance;

@interface YHDataCache()
@end


@implementation YHDataCache

+ (YHDataCache*) instance
{
	@synchronized([YHDataCache class])
	{
		if ( _instance == nil )
		{
			_instance = [[YHDataCache alloc] init];
		}
		return _instance;
	}
}

- (instancetype) init
{
	if ( self = [super init] )
	{
		self.hasCheckedInToday = NO;
		self.profile = [[YHYunKeProfile alloc] init];
		self.projects = [NSMutableArray array];
		self.kaoqinRecords = [NSMutableArray array];
		self.db = [FMDatabase databaseWithPath:self.databasePath];
		
		NSLog(@"Open db %@",self.databasePath);
		if ( ![self.db open] )
		{
			NSLog(@"Open db file failed!");
		}
	}
	return self;
}


- (void) load
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults objectForKey:@"YunHuoDataCacheKey"])
	{
		UnachieverBool(self.hasCheckedInToday);
		UnachieverObject(self.profile);
		UnachieverObject(self.projects);
		UnachieverObject(self.kaoqinRecords);
	}
	else
	{
		[self save];
	}
}

- (void) save
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@1 forKey:@"YunHuoDataCacheKey"];
	AchieverBool(self.hasCheckedInToday);
	AchieverObject(self.profile);
	AchieverObject(self.projects);
	AchieverObject(self.kaoqinRecords);
}

- (NSString *)databasePath
{
	return [NSHomeDirectory() stringByAppendingString:@"/Library/DataCache.db"];
}

- (void) beginTransaction
{
	[self.db beginTransaction];
}

- (void) commitTransaction
{
	[self.db commit];
}

- (void) createTableOfClass:(Class)cls
{
	if ( [self.db tableExists:@"YHYunKeProfile"] )
	{
		return;
	}

	[self.db executeUpdate:[cls createTableSql]];
	if ([self.db hadError])
	{
		NSLog(@"Err %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
	}
}

- (BOOL) recordExisted:(id<YHDBStorage>)record
{
	BOOL isExisted = NO;
	
	NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where index = ?", NSStringFromClass([record class])];
	
	FMResultSet *rs = [self.db executeQuery:sqlStr, @(record.index)];
	if ([rs next])
	{
		isExisted = YES;
	}
	[rs close];
	
	return isExisted;
}
@end
