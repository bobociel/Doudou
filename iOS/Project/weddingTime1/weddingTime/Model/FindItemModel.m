//
//  FindItemModel.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "FindItemModel.h"

@implementation FindItemModel
- (instancetype)init
{
    self = [super init];
    if(self){
        self.ID = @"";
        self.city_id = @"0";
        self.supplier_id = @"";
        self.post_id = @"";
        self.update_time = 0;
        self.title = @"";
        self.content = @"";
        self.tag = @"";
        self.counts = @"";
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
    return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

#pragma mark - SQLiteProtocol

- (NSString *)createTableSql
{
	return @"CREATE TABLE IF NOT EXISTS find (id VARCHAR(20), post_id VARCHAR(20), supplier_id VARCHAR(20), city_id VARCHAR(20) NOT NULL,update_time TEXT NOT NULL,type INTEGER NOT NULL, title TEXT,content TEXT,path TEXT, tag TEXT,counts VARCHAR(20), primary key (id,city_id))";
}

- (NSString *)replaceDataSql
{
	return @"replace INTO find (id, post_id, supplier_id, city_id,update_time, type, title, content, path, tag, counts) VALUES(:id, :post_id, :supplier_id, :city_id, :update_time, :type, :title, :content, :path, :tag, :counts)";
}

- (NSString *)deleteDataSql
{
	return @"DELETE FROM find WHERE id = ?";
}

@end
