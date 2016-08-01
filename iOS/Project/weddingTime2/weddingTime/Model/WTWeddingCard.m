//
//  WTWeddingCard.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingCard.h"

@implementation WTWeddingCard

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.ID = @"";
		self.taobao_id = @"";
		self.goods_name = @"";
		self.goods_price = 0;
		self.main_pic = @"";
		self.market_price = @"";
		self.goods_sn = @"";
		self.goods_img = @[];
		self.goods_package = @[];
		self.goods_attr = @[];
	}
	return self;
}

+ (NSDictionary *)modelCustomPropertyMapper
{
	return @{@"ID":@"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
	return @{@"goods_img" : [WTWeddingCardImage class],@"goods_package":[WTWeddingCardExt class],@"goods_attr":[WTWeddingCardExt class]};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTWeddingCardImage

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.goods_id = @"";
		self.host = @"";
		self.path = @"";
		self.h = 0;
		self.w = 0;
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTWeddingCardExt

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.goods_id = @"";
		self.label = @"";
		self.attr = @"";
		self.price = 0;
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
