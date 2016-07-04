//
//  SQLiteAssister.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseProtocol.h"
#import "AVIMKeyedConversation+Database.h"
#import "AVIMTypedMessage+DataBase.h"
@interface DatabaseManager : NSObject

+ (instancetype)manager;
- (void)loadDataBaseCustom;
- (void)loadDataBasePersonalID:(NSString *)ID;

- (void)replaceItem:(NSObject <DatabaseProtocol> *)model;
- (void)replaceItems:(NSArray *)models;
- (void)deleteItem:(NSObject <DatabaseProtocol> *)model;
- (void)deleteAllItem:(NSObject <DatabaseProtocol> *)model;

- (NSArray *)selectAllConversations;
//- (UserInfo *)pullUserInfo:(NSString *)ID;

//- (void)pullItemsForAllCityWithtimestamp:(int64_t)timestamp
//								   limit:(int)limit
//								callback:(void (^)(NSArray *, NSError *))block;
//
//- (void)pullItemsForCityId:(NSString *)cityId
//				 timestamp:(int64_t)timestamp
//					 limit:(int)limit
//				  callback:(void (^)(NSArray *, NSError *))block ;
@end
