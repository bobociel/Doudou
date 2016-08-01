//
//  WTCityGroup.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/27.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTCityGroup.h"

@implementation WTCity : NSObject
+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"cityID":@"id",@"cityName":@"name"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTCityGroup

- (NSMutableArray *) arrayCitys
{
	if (_arrayCitys == nil) {
		_arrayCitys = [[NSMutableArray alloc] init];
	}
	return _arrayCitys;
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
	return @{@"arrayCitys":[WTCity class]};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
