//
//  WeddingPlanDetailViewController.h
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "WeddingPlanListCell.h"
#import "WTLocalNoticeManager.h"
#define WeddingPlanShouldBeReloadNotify @"WeddingPlanShouldBeReloadNotify"

@interface WeddingPlanDetailViewController : BaseViewController
@property (nonatomic,copy) NSString *planId;
@property (nonatomic,strong) WTMatter *matter;
@end
