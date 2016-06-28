//
//  NotificationTopPush.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NotificationTopPush.h"
#import "WTSupplierViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTHotelViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTDemandDetailViewController.h"
//#import "WTOrderDetailViewController.h"
#import "WTBlessListViewController.h"
#import "WTTicketDetailViewController.h"
#import "WeddingPlanDetailViewController.h"
#import "LWUtil.h"
@implementation NotificationTopPush
+ (void)pushToSupplierWithSupplierID:(id)supplierId
{
	if (!supplierId) { return; }
	if ( [KeyWindowCurrentViewController isKindOfClass:[WTSupplierViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

	WTSupplierViewController *supplierInfoViewController = [[WTSupplierViewController alloc] init];
	supplierInfoViewController.supplier_id = supplierId;
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav pushViewController:supplierInfoViewController animated:NO];
}

+ (void)pushToWorkDetailWtihwork_id:(id)work_id
{
    if (!work_id) { return; }
	if ( [KeyWindowCurrentViewController isKindOfClass:[WTWorksDetailViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

    WTWorksDetailViewController *detail = [WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:work_id];
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav setNavigationBarHidden:NO animated:NO];
    [nav pushViewController:detail animated:NO];
}

+ (void)pushToHotelWtihHotelId:(id)hotelId
{
	if (!hotelId) { return; }
	if ( [KeyWindowCurrentViewController isKindOfClass:[WTHotelViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}
	WTHotelViewController *hotelVC = [[WTHotelViewController alloc] init];
	hotelVC.hotel_id = hotelId;
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav pushViewController:hotelVC animated:NO];
}

+ (void)pushToInspirationWtihTag:(id)tag
{
	if (!tag) { return; }
	if ( [KeyWindowCurrentViewController isKindOfClass:[WTInspiretionListViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

	WTInspiretionListViewController *detail = [[WTInspiretionListViewController alloc] init];
	detail.searchTag = tag;
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav setNavigationBarHidden:NO animated:NO];
	[nav pushViewController:detail animated:NO];
}

+ (void)pushToInspirationWtihColor:(id)color
{
	if (!color) { return; }
	if( [KeyWindowCurrentViewController isKindOfClass:[WTInspiretionListViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}
	NSArray *keyAndName = [color componentsSeparatedByString:@"|"];
	NSString *key = @"";
	NSString *name = @"";
	if(keyAndName.count == 2)
	{
		key = keyAndName[0];
		name = keyAndName[1];
	}
	WTInspiretionListViewController *detail = [[WTInspiretionListViewController alloc] init];
	detail.searchColor = @{@"value":key,@"name":name};
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav setNavigationBarHidden:NO animated:NO];
	[nav pushViewController:detail animated:NO];
}


+ (void)pushToDemaindDetailWithRewardId:(id)rewardId{
    if (!rewardId) { return; }
	if( [KeyWindowCurrentViewController isKindOfClass:[WTDemandDetailViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}
    WTDemandDetailViewController *demaindDetailVC=[[WTDemandDetailViewController alloc]init];
    demaindDetailVC.rewardId = rewardId;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav pushViewController:demaindDetailVC animated:NO];
}

+ (void)pushToOrderDetailWtihOrder_id:(id)order_id
{
//	if (!order_id) { return; }
//	if( [KeyWindowCurrentViewController isKindOfClass:[WTOrderDetailViewController class]] )
//	{
//		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
//	}
//	WTOrderDetailViewController *detail = [[WTOrderDetailViewController alloc] init];
//	detail.order_id = order_id;
//	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
//	[nav setNavigationBarHidden:NO animated:YES];
//	[nav pushViewController:detail animated:NO];
}

+ (void)pushToBlessList
{
    if ( [KeyWindowCurrentViewController isKindOfClass:[WTBlessListViewController class]] )
    {
        [KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
    }
    
    WTBlessListViewController *detail = [[WTBlessListViewController alloc] init];
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav setNavigationBarHidden:NO animated:NO];
    [nav pushViewController:detail animated:NO];
}

+ (void)pushToPlanDetailWtihMatterID:(id)matter_id
{
	if (!matter_id) { return; }
	if ( [KeyWindowCurrentViewController isKindOfClass:[WeddingPlanDetailViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

	WeddingPlanDetailViewController *detail = [[WeddingPlanDetailViewController alloc] init];
	detail.planId = matter_id;
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav setNavigationBarHidden:NO animated:NO];
	[nav pushViewController:detail animated:NO];
}

+ (void)pushToTicketDetail:(NSString *)ID
{
	if ( [KeyWindowCurrentViewController isKindOfClass:[WTTicketDetailViewController class]] )
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

	WTTicketDetailViewController *detail = [WTTicketDetailViewController instanceWithTicketID:ID];
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
	[nav setNavigationBarHidden:NO animated:NO];
	[nav pushViewController:detail animated:NO];
}

@end
