//
//  emandDetailViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
#define keepRewardDateNotification @"keepRewardDateNotification"
#define DemandDidRibedNotification @"DemandDidRibedNotification"
#define DemandDidCanceledNotification @"DemandDidCanceledNotification"
@interface WTDemandDetailViewController : WTSupplierBaseViewController
@property(nonatomic)int rewardId;
@end
