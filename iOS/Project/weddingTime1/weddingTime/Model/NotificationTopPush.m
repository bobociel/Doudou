//
//  NotificationTopPush.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NotificationTopPush.h"
#import "WTOrderDetailViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTDemandDetailViewController.h"
@implementation NotificationTopPush



+ (void)pushToOrderDetailWtihOrder_id:(id)order_id
{
    if (!order_id) {
        return;
    }
    WTOrderDetailViewController *detail = [[WTOrderDetailViewController alloc] init];
    detail.order_id = order_id;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav setNavigationBarHidden:NO animated:YES];
    [nav pushViewController:detail animated:YES];
}


+ (void)pushToWorkDetailWtihwork_id:(id)work_id
{
    if (!work_id) {
        return;
    }
    WTWorksDetailViewController *detail = [[WTWorksDetailViewController alloc] init];
    detail.works_id = work_id;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav setNavigationBarHidden:NO animated:YES];
    [nav pushViewController:detail animated:YES];
}


+ (void)pushToDemaindDetailWithRewardId:(id)rewardId{
    if (!rewardId) {
        return;
    }
    WTDemandDetailViewController *demaindDetailVC=[[WTDemandDetailViewController alloc]init];
    demaindDetailVC.rewardId=[rewardId intValue];
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav pushViewController:demaindDetailVC animated:YES];
}

@end
