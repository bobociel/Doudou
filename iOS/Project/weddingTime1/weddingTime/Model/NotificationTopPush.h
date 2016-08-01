//
//  NotificationTopPush.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationTopPush : NSObject

+ (void)pushToOrderDetailWtihOrder_id:(id)order_id;
+ (void)pushToWorkDetailWtihwork_id:(id)work_id;
+ (void)pushToDemaindDetailWithRewardId:(id)rewardId;
@end
