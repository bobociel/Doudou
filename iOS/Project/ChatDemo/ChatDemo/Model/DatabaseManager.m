//
//  SQLiteAssister.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "DatabaseManager.h"
#import <FMDB.h>

#define QUERY_ALLCONVERSATION_SQL @"SELECT * from AVIMKeyedConversation "

#define QUERY_USERINFO_SQL @"SELECT * from user where id = ? "
#define QUERY_FIND_SQL @"SELECT * FROM find WHERE city_id=? AND update_time<? ORDER BY update_time DESC LIMIT ?"
#define QUERY_FINDALLCITY_SQL @"SELECT * FROM find WHERE  update_time<? ORDER BY update_time DESC LIMIT ?"

#define COLUMN_NAME_ID            @"ID"

#define COLUMN_NAME_POSTTD        @"post_id"
#define COLUMN_NAME_CITYID        @"city_id"
#define COLUMN_NAME_UPDATETIME    @"update_time"
#define COLUMN_NAME_DISCOVERTYPE  @"discover_type"
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

#define COLUMN_NAME_CONVERSATIONID @"conversationId"
#define COLUMN_NAME_DATA           @"data"

@interface DatabaseManager ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase *personDB;
@end

@implementation DatabaseManager

+(instancetype)manager {
    static DatabaseManager *_persister = nil;
    if (nil == _persister) {
        _persister = [[DatabaseManager alloc] init];
    }
    return _persister;
}

#pragma mark - INIT DATABASE
- (NSString *)dbFindPath {
	NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *result = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"DataCache.db"]];
	return result;
}

- (NSString *)dbPersonalPathWithID:(NSString *)personID{
	NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *result = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"PersonalDataCache_%@.db",personID]];
	return result;
}

- (void)loadDataBaseCustom
{
	//
}

- (void)loadDataBasePersonalID:(NSString *)ID
{
	_dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self dbPersonalPathWithID:ID]];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		BOOL rs = [db executeUpdate:[[AVIMKeyedConversation new] createTableSql]];
		if(rs) NSLog(@""); else NSLog(@"create table AVIMKeyedConversation failure");
		rs = [db executeUpdate:[[AVIMTextMessage new] createTableSql]];
		if(rs) NSLog(@""); else NSLog(@"create table AVIMTextMessage failure");
	}];

//	_personDB = [FMDatabase databaseWithPath:[self dbPersonalPath]];
//	[_personDB open];
//	 BOOL rs =[_personDB executeUpdate:[[UserInfo new] createTableSql]];
//	if(rs) NSLog(@"create table success"); else NSLog(@"create table failure");
//	[_personDB close];
}

#pragma mark - INSERT UPDATE DELETE OPERATION
- (void)replaceItem:(NSObject <DatabaseProtocol> *)model
{
	[_dbQueue inDatabase:^(FMDatabase *db) {
		BOOL rs = [db executeUpdate:[model replaceDataSql] withParameterDictionary:[model modelToJSONObject]];
		if(rs) NSLog(@"replace data success"); else NSLog(@"replace data failure");
	}];
}

- (void)replaceItems:(NSArray *)models
{
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db beginTransaction];
		for (NSObject<DatabaseProtocol> *model in models) {
			BOOL rs = [db executeUpdate:[model replaceDataSql] withParameterDictionary:[model modelToJSONObject]];
			if(rs) NSLog(@"replace data success"); else NSLog(@"replace data failure");
		}
		[db commit];
	}];
}

- (void)deleteItem:(NSObject <DatabaseProtocol> *)model
{
	[_dbQueue inDatabase:^(FMDatabase *db) {
		BOOL rs = [db executeUpdate:[model deleteDataSql] withArgumentsInArray:@[model.ID]];
		if(rs) NSLog(@"delete data success"); else NSLog(@"delete data failure");
	}];
}

- (void)deleteAllItem:(NSObject <DatabaseProtocol> *)model
{
	[_dbQueue inDatabase:^(FMDatabase *db) {
		BOOL rs = [db executeUpdate:[model deleteAllDataSql] ];
		if(rs) NSLog(@"delete all data success"); else NSLog(@"delete all data failure");
	}];
}

#pragma mark - GET CUSTOM DATA
- (NSArray *)selectAllConversations
{
	NSMutableArray *conversations = [NSMutableArray array];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:QUERY_ALLCONVERSATION_SQL];
		while ([rs next]) {
			NSData *keyedConvData = [rs dataForColumn:COLUMN_NAME_DATA];
			AVIMKeyedConversation *keyedConv = [NSKeyedUnarchiver unarchiveObjectWithData:keyedConvData];
			AVIMConversation *conv = [[AVIMClient defaultClient] conversationWithKeyedConversation:keyedConv];
			[conversations addObject:conv];
		}
		[rs close];
	}];

	return conversations;
}

//获得发现
//- (void)pullItemsForAllCityWithtimestamp:(int64_t)timestamp limit:(int)limit callback:(void (^)(NSArray *, NSError *))block
//{
//	NSMutableArray *result = [NSMutableArray array];
//	[_dbQueue inDatabase:^(FMDatabase *db) {
//		FMResultSet* rs = [db executeQuery:QUERY_FINDALLCITY_SQL withArgumentsInArray:@[@(timestamp), @(limit)]];
//		while ([rs next]) {
//			FindItemModel *item  = [[FindItemModel alloc] init];
//			item.ID = [rs stringForColumn:COLUMN_NAME_ID];
//			item.city_id = [rs stringForColumn:COLUMN_NAME_CITYID];
//			item.update_time = [rs longLongIntForColumn:COLUMN_NAME_UPDATETIME];
//			item.discover_type = [rs intForColumn:COLUMN_NAME_DISCOVERTYPE];
//			item.content = [FindCntent modelWithJSON:[rs stringForColumn:COLUMN_NAME_CONTENT]];
//			[result addObject:item];
//		};
//		[rs close];
//	}];
//
//	block(result,nil);
//}
//
//- (void)pullItemsForCityId:(NSString *)cityId timestamp:(int64_t)timestamp limit:(int)limit callback:(void (^)(NSArray *, NSError *))block {
//
//	NSMutableArray *result = [NSMutableArray array];
//	[_dbQueue inDatabase:^(FMDatabase *db) {
//		FMResultSet* rs = [db executeQuery:QUERY_FIND_SQL withArgumentsInArray:@[cityId,@(timestamp), @(limit)]];
//		while ([rs next]) {
//			FindItemModel *item  = [[FindItemModel alloc] init];
//			item.ID = [rs stringForColumn:COLUMN_NAME_ID];
//			item.city_id = [rs stringForColumn:COLUMN_NAME_CITYID];
//			item.update_time = [rs longLongIntForColumn:COLUMN_NAME_UPDATETIME];
//			item.discover_type = [rs intForColumn:COLUMN_NAME_DISCOVERTYPE];
//			item.content = [FindCntent modelWithJSON:[rs stringForColumn:COLUMN_NAME_CONTENT]];
//			[result addObject:item];
//		};
//		[rs close];
//	}];
//
//	block(result, nil);
//}
//
//#pragma mark -GET PERSON DATA
//
//- (UserInfo *)pullUserInfo:(NSString *)ID
//{
//	if(![ID isNotEmptyCtg]){ return nil;}
//	[_personDB open];
//    UserInfo *user = [[UserInfo alloc] init];
//	FMResultSet *rs = [_personDB executeQuery:QUERY_USERINFO_SQL withArgumentsInArray:@[ID]];
//	if([rs next]) {
//		user.ID = [rs stringForColumn:COLUMN_NAME_ID];
//		user.name = [rs stringForColumn:COLUMN_NAME_NAME];
//		user.group_id = [rs stringForColumn:COLUMN_NAME_GROUPID];
//		user.phone = [rs stringForColumn:COLUMN_NAME_PHONE];
//		user.avatar = [rs stringForColumn:COLUMN_NAME_AVATAR];
//	}
//	[rs close];
//	[_personDB close];
//    return user;
//}

@end
