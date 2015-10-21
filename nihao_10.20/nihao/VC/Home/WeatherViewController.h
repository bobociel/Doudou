//
//  WeatherViewController.h
//  nihao
//
//  Created by HelloWorld on 7/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface WeatherViewController : UIViewController

// 全部的天气信息
@property (nonatomic, strong) NSDictionary *locationWeatherInfo;

// 天气现象字典
@property (nonatomic, strong) NSDictionary *weatherPhenomenon;

// 当前定位的城市名称
@property (nonatomic, copy) NSString *locationCityName;

// 当前定位的坐标
@property (nonatomic) MyLocationCoordinate2D currentCoordinate;

@end
