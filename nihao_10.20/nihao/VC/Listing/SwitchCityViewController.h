//
//  SwitchCityViewController.h
//  nihao 切换城市
//
//  Created by 刘志 on 15/5/29.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class City;

@interface SwitchCityViewController : BaseViewController

@property (nonatomic,copy) void(^switchCity)(City *city);

@end
