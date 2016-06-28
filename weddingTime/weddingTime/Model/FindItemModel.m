//
//  FindItemModel.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "FindItemModel.h"
@implementation FindCntent
- (instancetype)init
{
	self = [super init];
	if(self){
		self.supplier_id = @"";
		self.post_id = @"";
		self.title = @"";
		self.content = @"";
		self.path = @"";
		self.tag = @"";
		self.counts = @"";
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation FindItemModel
- (instancetype)init
{
    self = [super init];
    if(self){
        self.ID = @"";
        self.city_id = @"0";
        self.update_time = 0;
		self.discover_type = 0;
        self.content = [[FindCntent alloc] init];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
	FindItemModel *model = [super modelWithDictionary:dictionary];
	model.content = [FindCntent modelWithDictionary:dictionary[@"content"]];
	return model;
}

- (id)modelToJSONObject
{
	NSMutableDictionary *modeDict = [super modelToJSONObject];
	[modeDict setValue:[_content modelToJSONString] forKey:@"content"];
	return modeDict;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
    return @[@"hash",@"description",@"debugDescription",@"superclass",@"content"];
}

#pragma mark - SQLiteProtocol

- (NSString *)createTableSql
{
	return @"CREATE TABLE IF NOT EXISTS find (id VARCHAR(20), city_id VARCHAR(20), update_time TEXT ,discover_type INTEGER, content TEXT, primary key (id))";
}

- (NSString *)replaceDataSql
{
	return @"replace INTO find (id, city_id, update_time, discover_type, content) VALUES(:id, :city_id, :update_time, :discover_type, :content)";
}

- (NSString *)deleteDataSql
{
	return @"DELETE FROM find WHERE id = ?";
}

@end
