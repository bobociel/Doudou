//
//  NotificationTopPush.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationTopPush : NSObject

+ (void)pushToSupplierWithSupplierID:(NSString *)supplierId;
+ (void)pushToWorkDetailWtihwork_id:(NSString *)work_id;
+ (void)pushToHotelWtihHotelId:(NSString *)hotelId;
+ (void)pushToInspirationWtihTag:(id)tag;
+ (void)pushToInspirationWtihColor:(id)color;

+ (void)pushToOrderDetailWtihOrder_id:(NSString *)order_id;
+ (void)pushToDemaindDetailWithRewardId:(NSString *)rewardId;
+ (void)pushToBlessList;

+ (void)pushToPlanDetailWtihMatterID:(id)matter_id;

+ (void)pushToTicketDetail:(NSString *)ID;
@end
