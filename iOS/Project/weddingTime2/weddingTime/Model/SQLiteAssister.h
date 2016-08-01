//
//  SQLiteAssister.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteProtocol.h"
#import "FindItemModel.h"
#import "UserInfo.h"
@interface SQLiteAssister : NSObject

+ (instancetype)sharedInstance;
- (void)loadDataBaseCustom;
- (void)loadDataBasePersonal;

- (void)pushItem:(NSObject <SQLiteProtocol> *)model;
- (void)deleteItem:(NSObject <SQLiteProtocol> *)model;
- (void)deleteAllItem:(NSObject <SQLiteProtocol> *)model;

- (UserInfo *)pullUserInfo:(NSString *)ID;

- (void)pullItemsForAllCityWithtimestamp:(int64_t)timestamp
								   limit:(int)limit
								callback:(void (^)(NSArray *, NSError *))block;

- (void)pullItemsForCityId:(NSString *)cityId
				 timestamp:(int64_t)timestamp
					 limit:(int)limit
				  callback:(void (^)(NSArray *, NSError *))block ;
@end
