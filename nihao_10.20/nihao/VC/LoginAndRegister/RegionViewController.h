//
//  RegionViewController.h
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, RegionType) {
	RegionTypeCountry = 0,
	RegionTypeProvince,
	RegionTypeCity,
    RegionFilter,
};

@interface RegionViewController : BaseViewController

@property (nonatomic, copy) NSArray *dataSource;

@property (nonatomic, assign) RegionType regionType;

@property (nonatomic,copy) void(^regionSelected)(NSString *region);
@property (nonatomic,copy) void(^provinceSelected)(NSString *province, NSString *city);
@property (nonatomic,copy) void(^citySelected)(NSString *city);

@property (nonatomic,copy) void(^allRegionFilterSelected)(void);

@end
