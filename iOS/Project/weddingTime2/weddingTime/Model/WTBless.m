//
//  WTBless.m
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import "WTBless.h"

@implementation WTBless

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
