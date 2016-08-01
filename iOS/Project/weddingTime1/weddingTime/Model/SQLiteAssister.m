//
//  SQLiteAssister.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "SQLiteAssister.h"
#import <FMDB.h>

#define QUERY_USERINFO_SQL @"SELECT * from user where id = ? "

#define QUERY_FIND_SQL @"SELECT * FROM find WHERE city_id=? AND update_time<? ORDER BY update_time DESC LIMIT ?"
#define QUERY_FINDALLCITY_SQL @"SELECT * FROM find WHERE  update_time<? ORDER BY update_time DESC LIMIT ?"

#define COLUMN_NAME_ID            @"ID"

#define COLUMN_NAME_POSTTD        @"post_id"
#define COLUMN_NAME_CITYID        @"city_id"
#define COLUMN_NAME_UPDATETIME    @"update_time"
#define COLUMN_NAME_TYPE          @"type"
#define COLUMN_NAME_TITLE         @"title"
#define COLUMN_NAME_CONTENT       @"content"
#define COLUMN_NAME_SUPPLIERID    @"supplier_id"
#define COLUMN_NAME_TAG           @"tag"
#define COLUMN_NAME_PATH          @"path"
#define COLUMN_NAME_COUNTS        @"counts"

#define COLUMN_NAME_GROUPID       @"group_id"
#define COLUMN_NAME_NAME          @"name"
#define COLUMN_NAME_AVATAR        @"avatar"
#define COLUMN_NAME_PHONE         @"phone"

@interface SQLiteAssister ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase *personDB;
@end

@implementation SQLiteAssister

+(instancetype)sharedInstance {
    static SQLiteAssister *_persister = nil;
    if (nil == _persister) {
        _persister = [[SQLiteAssister alloc] init];
    }
    return _persister;
}

#pragma mark - INIT DATABASE
- (NSString *)dbFindPath {
	NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *result = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"DataCache.db"]];
	return result;
}

- (NSString *)dbPersonalPath{
	NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *result = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"PersonalDataCache_%@.db",[UserInfoManager instance].userId_self]];
	return result;
}

- (NSString *)dbFindPathBefore {
	NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *result = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"find_cache10.sql"]];
	return result;
}

- (void)loadDataBaseCustom
{
	if([[NSFileManager defaultManager] fileExistsAtPath:[self dbFindPathBefore]]){
		BOOL rs = [[NSFileManager defaultManager] removeItemAtPath:[self dbFindPathBefore] error:nil];
		if(rs) NSLog(@"delete oldFind success"); else NSLog(@"delete oldFind failure");
	}
	_dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self dbFindPath]];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL rs = [db executeUpdate:[[FindItemModel new] createTableSql]];
		if(rs) NSLog(@"create table success"); else NSLog(@"create table failure");
    }];
}

- (void)loadDataBasePersonal
{
	_personDB = [FMDatabase databaseWithPath:[self dbPersonalPath]];
	[_personDB open];
	 BOOL rs =[_personDB executeUpdate:[[UserInfo new] createTableSql]];
	if(rs) NSLog(@"create table success"); else NSLog(@"create table failure");
	[_personDB close];
}

#pragma mark - INSERT UPDATE DELETE OPERATION
- (void)pushItem:(NSObject <SQLiteProtocol> *)model
{
	if([model isKindOfClass:[FindItemModel class]])
	{
		[_dbQueue inDatabase:^(FMDatabase *db) {
			BOOL rs = [db executeUpdate:[model replaceDataSql] withParameterDictionary:[model modelToJSONObject]];
			if(rs) NSLog(@"replace data success"); else NSLog(@"replace data failure");
		}];
	}else{
		[_personDB open];
		BOOL rs = [_personDB executeUpdate:[model replaceDataSql] withParameterDictionary:[model modelToJSONObject]];
		if(rs) NSLog(@"replace data success"); else NSLog(@"replace data failure");
		[_personDB close];
	}
}

- (void)deleteItem:(NSObject <SQLiteProtocol> *)model
{
	if([model isKindOfClass:[FindItemModel class]]){
		[_dbQueue inDatabase:^(FMDatabase *db) {
			BOOL rs = [db executeUpdate:[model deleteDataSql] withArgumentsInArray:@[model.ID]];
			if(rs) NSLog(@"delete data success"); else NSLog(@"delete data failure");
		}];
	}else{
		[_personDB open];
		BOOL rs = [_personDB executeUpdate:[model deleteDataSql] withArgumentsInArray:@[model.ID]];
		if(rs) NSLog(@"replace data success"); else NSLog(@"replace data failure");
		[_personDB close];
	}
}

#pragma mark - GET CUSTOM DATA
//获得发现
- (void)pullItemsForAllCityWithtimestamp:(int64_t)timestamp limit:(int)limit callback:(void (^)(NSArray *, NSError *))block
{
	NSMutableArray *result = [NSMutableArray array];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet* rs = [db executeQuery:QUERY_FINDALLCITY_SQL withArgumentsInArray:@[@(timestamp), @(limit)]];
		while ([rs next]) {
			FindItemModel *item  = [[FindItemModel alloc] init];
			item.ID = [rs stringForColumn:COLUMN_NAME_ID];
			item.post_id = [rs stringForColumn:COLUMN_NAME_POSTTD];
			item.city_id = [rs stringForColumn:COLUMN_NAME_CITYID];
			item.update_time = [rs longLongIntForColumn:COLUMN_NAME_UPDATETIME];
			item.type = [rs doubleForColumn:COLUMN_NAME_TYPE];
			item.title = [rs stringForColumn:COLUMN_NAME_TITLE];
			item.content = [rs stringForColumn:COLUMN_NAME_CONTENT];
			item.supplier_id = [rs stringForColumn:COLUMN_NAME_SUPPLIERID];
			item.tag = [rs stringForColumn:COLUMN_NAME_TAG];
			item.path = [rs stringForColumn:COLUMN_NAME_PATH];
			item.counts = [rs stringForColumn:COLUMN_NAME_COUNTS];
			[result addObject:item];
		};
		[rs close];
	}];

	block(result,nil);
}

- (void)pullItemsForCityId:(NSString *)cityId timestamp:(int64_t)timestamp limit:(int)limit callback:(void (^)(NSArray *, NSError *))block {

	NSMutableArray *result = [NSMutableArray array];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet* rs = [db executeQuery:QUERY_FIND_SQL withArgumentsInArray:@[cityId,@(timestamp), @(limit)]];
		while ([rs next]) {
			FindItemModel *item  = [[FindItemModel alloc] init];
			item.ID = [rs stringForColumn:COLUMN_NAME_ID];
			item.post_id = [rs stringForColumn:COLUMN_NAME_POSTTD];
			item.city_id = [rs stringForColumn:COLUMN_NAME_CITYID];
			item.update_time = [rs longLongIntForColumn:COLUMN_NAME_UPDATETIME];
			item.type = [rs doubleForColumn:COLUMN_NAME_TYPE];
			item.title = [rs stringForColumn:COLUMN_NAME_TITLE];
			item.content = [rs stringForColumn:COLUMN_NAME_CONTENT];
			item.supplier_id = [rs stringForColumn:COLUMN_NAME_SUPPLIERID];
			item.tag = [rs stringForColumn:COLUMN_NAME_TAG];
			item.path = [rs stringForColumn:COLUMN_NAME_PATH];
			item.counts = [rs stringForColumn:COLUMN_NAME_COUNTS];
			[result addObject:item];
		};
		[rs close];
	}];

	block(result, nil);
}

#pragma mark -GET PERSON DATA

- (UserInfo *)pullUserInfo:(NSString *)ID
{
	if(!ID){ return nil;}
	[_personDB open];
    UserInfo *user = [[UserInfo alloc] init];
	FMResultSet *rs = [_personDB executeQuery:QUERY_USERINFO_SQL withArgumentsInArray:@[ID]];
	if([rs next]) {
		user.ID = [rs stringForColumn:COLUMN_NAME_ID];
		user.name = [rs stringForColumn:COLUMN_NAME_NAME];
		user.group_id = [rs stringForColumn:COLUMN_NAME_GROUPID];
		user.phone = [rs stringForColumn:COLUMN_NAME_PHONE];
		user.avatar = [rs stringForColumn:COLUMN_NAME_AVATAR];
	}
	[rs close];
	[_personDB close];
    return user;
}

@end

//		NSString *sql = @"SELECT sql FROM sqlite_master ;";
//		FMResultSet *rss = [db executeQuery:sql];
//		while([rss next]){
//			NSLog(@"%@",[rss stringForColumn:@"sql"]);
//		}

