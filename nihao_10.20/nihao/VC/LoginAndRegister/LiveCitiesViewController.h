//
//  LiveCitiesViewController.h
//  nihao 居住城市
//
//  Created by 刘志 on 15/6/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class City;

typedef NS_ENUM(NSUInteger, SelectCityType) {
	SelectCityTypeLiveCity = 0,
	SelectCityTypeAsk,
};

@interface LiveCitiesViewController : BaseViewController

@property (nonatomic,copy) void(^cityChoosed)(City *city);

@property (nonatomic, assign) SelectCityType selectCityType;

@end
