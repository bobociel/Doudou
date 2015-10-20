//
//  NewAskViewController.h
//  nihao
//
//  Created by HelloWorld on 7/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class AskCategory;
@class AskContent;

@interface NewAskViewController : BaseViewController

// Ask 分类
@property (nonatomic) AskCategory *askCategory;
// 选择的城市英文名字
@property (nonatomic, copy) NSString *currentCityName;
// 选择的城市 ID
@property (nonatomic, assign) NSInteger currentCityID;

@property (nonatomic, copy) void(^postAsk)(AskContent *ask);

@end
