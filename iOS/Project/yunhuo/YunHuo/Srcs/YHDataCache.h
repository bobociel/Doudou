//
//  YHDataCache.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHYunKeProfile.h"
#import	"YHProject.h"
#import	"YHKaoQin.h"
#import	"YHDBStorage.h"

@class FMDatabase;
@class FMResultSet;

@interface YHDataCache : NSObject
@property (nonatomic) FMDatabase *db;
@property (readonly) NSString *databasePath;
@property (nonatomic) BOOL				hasCheckedInToday;
@property (nonatomic) YHYunKeProfile	*profile;
@property (nonatomic) NSMutableArray	*projects;
@property (nonatomic) NSMutableArray	*kaoqinRecords;

+ (YHDataCache*) instance;

- (void) save;
- (void) load;


- (void) beginTransaction;
- (void) commitTransaction;

- (void) createTableOfClass:(NSString*)className;
- (BOOL) recordExisted:(id<YHDBStorage>)record;
//+ (NSInteger) totalCountOfClass:(NSString*)className;

//+ (NSArray*) indexesWithConditions:(NSArray*)conditions ofClass:(NSString*)className;
//+ (NSArray*) recordsWithConditions:(NSArray*)conditions ofClass:(NSString*)className;
//
//+ (NSArray*) fetchWithLimitConditions:(NSDictionary*)limitCondsDict sortColumnName:(NSString*)colummn ofClass:(NSString*)className;
//
//+ (void) deleteRecordsWithConditions:(NSArray*)conditions ofClass:(NSString*)className;
//+ (void) deleteWith:(NSInteger)itemID ofClass:(NSString*)className;


@end
