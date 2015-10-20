//
//  SelectCityViewController.h
//  nihao
//
//  Created by HelloWorld on 7/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, SelectCityFromType) {
	SelectCityFromTypeAskList = 0,
	SelectCityFromTypeNewAsk,
};

@interface SelectCityViewController : BaseViewController

@property (nonatomic, copy) NSString *askCategoryID;
//@property (nonatomic, copy) NSString *currentCityName;
//@property (nonatomic, assign) NSInteger currentCityID;

@property (nonatomic, assign) SelectCityFromType selectCityFromType;

@property (nonatomic, copy) void(^selectedCity)(NSString *cityName, NSInteger cityID);

@end
