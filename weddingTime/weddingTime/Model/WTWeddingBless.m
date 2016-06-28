//
//  WTBless.m
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import "WTWeddingBless.h"

@implementation WTWeddingBless

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end


@implementation WTWeddingDesk

+ (NSDictionary *)modelCustomPropertyMapper
{
	return @{@"ID":@"id"};
}


+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTWeddingProcess

+ (NSDictionary *)modelCustomPropertyMapper
{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
