//
//  WTWeddingTheme.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingTheme.h"

@implementation WTWeddingTheme
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.ID = @"";
		self.path = @"";
		self.goods_id = @"";
		self.style = @"";
		self.name = @"";
	}
	return self;
}

+ (NSDictionary *)modelCustomPropertyMapper
{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end
