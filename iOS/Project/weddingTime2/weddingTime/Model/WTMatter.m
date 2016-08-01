//
//  WTMatter.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/7.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTMatter.h"

@implementation WTMatter

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"desc":@"description"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
