//
//  WTDemand.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDemand.h"

@implementation WTDemand
+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end
