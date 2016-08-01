//
//  WTBudget.m
//  weddingTime
//
//  Created by wangxiaobo on 16/4/18.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTBudget.h"

@implementation WTBudgetInfo

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTBudgetInfos
+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"planBudgetInfo":@(WTWeddingTypePlan).stringValue,
			 @"photoBudgetInfo":@(WTWeddingTypePhoto).stringValue,
			 @"captureBudgetInfo":@(WTWeddingTypeCapture).stringValue,
			 @"hostBudgetInfo":@(WTWeddingTypeHost).stringValue,
			 @"dressBudgetInfo":@(WTWeddingTypeDress).stringValue,
			 @"makeUpBudgetInfo":@(WTWeddingTypeMakeUp).stringValue,
			 @"videoBudgetInfo":@(WTWeddingTypeVideo).stringValue,
			 @"hotelBudgetInfo":@(WTWeddingTypeHotel).stringValue};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTBudgetDetail

- (NSString *)budget_cost{
	NSInteger allPrice = _planBudget.integerValue + _photoBudget.integerValue + _captureBudget.integerValue
	                   + _hostBudget.integerValue + _dressBudget.integerValue + _makeUpBudget.integerValue
                       + _videoBudget.integerValue + _hotelBudget.integerValue;
	return @(allPrice).stringValue;
}

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"planBudget":@(WTWeddingTypePlan).stringValue,
			 @"photoBudget":@(WTWeddingTypePhoto).stringValue,
			 @"captureBudget":@(WTWeddingTypeCapture).stringValue,
			 @"hostBudget":@(WTWeddingTypeHost).stringValue,
			 @"dressBudget":@(WTWeddingTypeDress).stringValue,
			 @"makeUpBudget":@(WTWeddingTypeMakeUp).stringValue,
			 @"videoBudget":@(WTWeddingTypeVideo).stringValue,
			 @"hotelBudget": @(WTWeddingTypeHotel).stringValue};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTBudget

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"desc":@"description"};
}

//+ (NSDictionary *)modelContainerPropertyGenericClass
//{
//	return @{@"service_price":[WTBudgetInfos class]};
//}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTAd

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
