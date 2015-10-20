//
//  FeedbackViewController.h
//  nihao
//
//  Created by YW on 15/7/6.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

@interface FeedbackViewController : BaseViewController

@property (nonatomic, copy) void(^post)(void);

@end
