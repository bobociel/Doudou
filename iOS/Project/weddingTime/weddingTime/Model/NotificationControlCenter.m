//
//  NotificationControlCenter.m
//  weddingTime
//
//  Created by 默默 on 15/9/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NotificationControlCenter.h"
#import "WTChatListViewController.h"
#import "WTDemandDetailViewController.h"
#import "WTDemandListViewController.h"
#import "WTTicketDetailViewController.h"
//#import "WTOrderListViewController.h"
//#import "WTOrderDetailViewController.h"
#import "WTDrawViewController.h"
#import "WTKissViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTSupplierViewController.h"
#import "WTHotelViewController.h"
#import "UIImageView+WebCache.h"
#import "BlingService.h"
#import "UserInfoManager.h"
#import "BlingHelper.h"
#import "UserInfoManager.h"
#import "LoginManager.h"
#import "NotificationTopPush.h"

@implementation NotificationControlCenter

+ (NotificationControlCenter *)instance
{
    static NotificationControlCenter *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[NotificationControlCenter alloc] init];
        _instance.animationQueue = [[BRYSerialAnimationQueue alloc] init];
        UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, -70, screenWidth, 70)];
        backView.backgroundColor=[UIColor whiteColor];
        _instance.queue = [[NSMutableArray alloc] initWithObjects:backView, nil];
    });
    return _instance;
}

-(void)dealNotificationUWithUserInfo:(NSDictionary *)userInfo application:(UIApplication *)application
{
    if (application.applicationState != UIApplicationStateActive) {
		[AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    if (!userInfo || ![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {  return; }

    NSString *pushKey=userInfo[PushRemoteIdJumpKey];
	NSDictionary *data = userInfo[@"data"];
	id IDOrOther;
	WTNotificationTopViewType notiType = WTNotificationTopViewTypeSupplier;
	NSString *title = data[@"user_username"] ? : @"婚礼时光";
	NSString *subTitle = [LWUtil getString:userInfo[@"aps"][@"alert"] andDefaultStr:@""];
	NSString *avatarURL = data[@"user_avatar"] ? : kLogoToPushURL;

    if (application.applicationState == UIApplicationStateActive)
	{
		if(![pushKey isNotEmptyCtg]) {return ;}
		if([pushKey isEqualToString:PushBindMessage])
		{
			[self dealBlingpPushWith:userInfo from:1];
			return ;
		}
        else if ([pushKey isEqualToString:UserPayDeposit]
				 || [pushKey isEqualToString:PushRemoteIdRefundSucceed]
				 || [pushKey isEqualToString:PushRemoteIdReserveSucceed]
				 ||[pushKey isEqualToString:UserPostNewOrder])
        {
			IDOrOther = data[@"out_trade_no"];
			notiType = WTNotificationTopViewTypeOrder;
        }
        else if ([pushKey isEqualToString:PushRemoteIdPushToSupplier])
        {
            IDOrOther = [LWUtil getString:data[@"supplierId"] andDefaultStr:@""];
            NSString *sign = [LWUtil getString:data[@"sign"] andDefaultStr:@""] ;
            notiType = [sign isEqualToString:@"s"] ? WTNotificationTopViewTypeSupplier : WTNotificationTopViewTypeHotel;
        }
        else if([pushKey isEqualToString:PushTagToUser])
        {
            IDOrOther = [LWUtil getString:data[@"key"] andDefaultStr:@""];
            notiType = WTNotificationTopViewTypeTagInspiration;
        }
        else if ([pushKey isEqualToString:PushColorToUser])
        {
            IDOrOther = [LWUtil getString:data[@"key"] andDefaultStr:@""];
            notiType = WTNotificationTopViewTypeColorInspiration;
        }
        else if ([pushKey isEqualToString:PushPostToUser])
        {
            IDOrOther = [LWUtil getString:data[@"post_id"] andDefaultStr:@""];
            notiType = WTNotificationTopViewTypePost;
        }
		else if([pushKey isEqualToString:CouponChange])
		{
			IDOrOther = [LWUtil getString:data[@"receive_id"] andDefaultStr:@""];
			notiType = WTNotificationTopViewTypeTicket;
			[[NSNotificationCenter defaultCenter] postNotificationName:CouponChange object:nil userInfo:nil];
			if([KeyWindowCurrentViewController isKindOfClass:[WTTicketDetailViewController class]]){ return ;}
		}
        else if ([pushKey isEqualToString:SendBless]
				 || [pushKey isEqualToString:pushRemoteIdContentNormalMessage]
				 || [pushKey isEqualToString:PushRemoteIdDrawWithPartner]
				 || [pushKey isEqualToString:PushRemoteIdKissWithPartner])
        {
            return ;
        }

		//显示顶部View
		[self pushTopViewOnKeyWindow:avatarURL title:title subTitle:subTitle type:notiType message:nil object:IDOrOther];
    }
	else
	{
        if (![KEY_WINDOW.rootViewController isKindOfClass:[UINavigationController class]]) { return; }
        
        if([pushKey isEqualToString:PushBindMessage])
		{
            [self dealBlingpPushWith:userInfo from:2];
        }
		else if ([pushKey isEqualToString:PushRemoteIdDrawWithPartner])
		{
			UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
			if (![nav.topViewController isKindOfClass:[WTDrawViewController class]])
			{
				WTDrawViewController *drawVC = [[WTDrawViewController alloc] initWithNibName:@"WTDrawViewController" bundle:nil];
				drawVC.isFromJoin=YES;
				[nav pushViewController:drawVC animated:YES];
			}
		}
		else if ([pushKey isEqualToString:PushRemoteIdKissWithPartner])
		{
			UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
			if (![nav.topViewController isKindOfClass:[WTKissViewController class]]) {
				WTKissViewController *kissVc = [[WTKissViewController alloc] init];
				kissVc.isFromJoin=YES;
				[nav pushViewController:kissVc animated:YES];
			}
		}
		else if ([pushKey isEqualToString:UserPostNewOrder]
			|| [pushKey isEqualToString:UserPayDeposit]
			|| [pushKey isEqualToString:PushRemoteIdRefundSucceed]
			|| [pushKey isEqualToString:PushRemoteIdReserveSucceed] )
		{
			[NotificationTopPush pushToOrderDetailWtihOrder_id:[LWUtil getString:data[@"out_trade_no"] andDefaultStr:@""]];
			return ;
		}
        else if ([pushKey isEqualToString:PushRemoteIdPushToSupplier])
        {
            NSString *supplierId = [LWUtil getString:data[@"supplierId"] andDefaultStr:@""];
            NSString *sign = [LWUtil getString:data[@"sign"] andDefaultStr:@""] ;
            if ([sign isEqualToString:@"s"])
            {
                [NotificationTopPush pushToSupplierWithSupplierID:supplierId];
                return ;
            }
            else if ([sign isEqualToString:@"h"])
            {
                [NotificationTopPush pushToHotelWtihHotelId:supplierId];
                return ;
            }
        }
        else if([pushKey isEqualToString:PushTagToUser])
        {
            [NotificationTopPush pushToInspirationWtihTag:[LWUtil getString:data[@"key"] andDefaultStr:@""]];
            return;
        }
        else if ([pushKey isEqualToString:PushColorToUser])
        {
            [NotificationTopPush pushToInspirationWtihColor:data[@"key"]];
            return;
        }
        else if ([pushKey isEqualToString:PushPostToUser])
        {
            [NotificationTopPush pushToWorkDetailWtihwork_id:[LWUtil getString:data[@"post_id"] andDefaultStr:@""]];
            return;
        }
        else if([pushKey isEqualToString:SendBless])
        {
            [NotificationTopPush pushToBlessList];
            return;
        }
		else if([pushKey isEqualToString:CouponChange])
		{
			[NotificationTopPush pushToTicketDetail:data[@"receive_id"]];
			return;
		}
        else if ([pushKey isEqualToString:PushRemoteIdDemaindNewBidding]
				 ||[pushKey isEqualToString:UserPostNewReward])
		{
			NSString *reward_id = [LWUtil getString:data[@"reward_id"] andDefaultStr:@""];
			[NotificationTopPush pushToDemaindDetailWithRewardId:reward_id];
			return ;
        }
		else if (![pushKey isNotEmptyCtg]||[pushKey isEqualToString:pushRemoteIdContentNormalMessage])
		{
			NSString *conversationId=[LWUtil getString:userInfo[PushRemoteIdConversationId] andDefaultStr:@""];
			if ([conversationId isNotEmptyCtg]) {
				if (!([KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]] && [[LWUtil getString:conversationId andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_conversation])) {
					[[ChatMessageManager instance] setWaitOpenConversatinId:conversationId];
				}
			}
		}
    }
}

-(void)pushTopViewOnKeyWindow:(NSString*)avatar title:(NSString*)title subTitle:(NSString*)subTitle type:(WTNotificationTopViewType)type message:(AVIMMessage*)messgae object:(id)object
{
    __block UIView *backView=[NotificationControlCenter instance].queue[0];
    static dispatch_once_t onece;
    dispatch_once(&onece, ^{
        [KEY_WINDOW addSubview:backView];
    });
    
	__block  NotificationTopView *view=[[NotificationTopView alloc] initWithType:type message:messgae object:object];
    view.mainTitle.text=title;
    view.subTitle.text=subTitle;
    view.frame=CGRectMake(0, -70, screenWidth, 70);
    void(^completeBlock)()=^(){
        if([NotificationControlCenter instance].queue.count==1)
//            [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:UIStatusBarAnimationSlide];

        [KEY_WINDOW addSubview:view];
        [[NotificationControlCenter instance].queue addObject:view];
        
        [[NotificationControlCenter instance].animationQueue animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut|UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            backView.top=0;
            view.top=0;
        } completion:^(BOOL finished) {
            
        }];
        
        [[NotificationControlCenter instance].animationQueue animateWithDuration:1 delay:2.5 options:UIViewAnimationOptionCurveEaseOut|UIViewKeyframeAnimationOptionAllowUserInteraction begin:^NSTimeInterval{
            if ([NotificationControlCenter instance].queue.count>2) {
                return 0.1;
            }
            else
            {
                return 0.4;
            }
        }  animations:^{
            if ([NotificationControlCenter instance].queue.count>2) {
                view.alpha=0;
            }
            else
            {
                view.top=-70;
                backView.top=-70;
            }
        } completion:^(BOOL finished) {
            [[NotificationControlCenter instance].queue removeObject:view];
            [view removeFromSuperview];
            if([NotificationControlCenter instance].queue.count==1){
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            }
        }];
    };
    if ([avatar isNotEmptyCtg]) {
        view.avatarImage.hidden=NO;
        [view.avatarImage sd_setImageWithURL:[NSURL URLWithString:avatar] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            completeBlock();
        }];
    }
    else
    {
        view.avatarImage.hidden=YES;
        completeBlock();
    }
    
}

- (void)dealBlingpPushWith:(NSDictionary *)userInfo from:(int)type
{
	if([KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]])
	{
		[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:NO];
	}

    NSDictionary *result = userInfo;
    NSNumber *sign = result[@"sign"];
    if (type == 1)
	{
        if (sign.integerValue == UserInviteStateInvite)
		{
            BlingHelper *bling = [[BlingHelper alloc] init];
			[bling makeAlertWith:result type:0 callback:nil];
        }
    }
	if (sign.integerValue == UserInviteStateAccpet)
	{
		[UserInfoManager instance].userId_partner = result[@"partner_id"];
        BlingHelper *bling = [[BlingHelper alloc] init];
        [bling makeSuccessAlertWith:result];
    }
	else if (sign.integerValue == UserInviteStateRefuse)
	{
        BlingHelper *bling = [[BlingHelper alloc] init];
		[bling makeRefuseAlertWith:result];
		[[NSNotificationCenter defaultCenter] postNotificationName:RefuseBinding object:nil];
    }
	else if (sign.integerValue == UserInviteStateCancel)
	{
		[[UserInfoManager instance] clearConversations];
		[[UserInfoManager instance] updateUserInfoFromServer];
		NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
		[mu setObject:InviteState_single forKey:[UserInfoManager instance].userId_self];
		[UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
		[[UserInfoManager instance] saveOtherToUserDefaults];
		
        BlingHelper *bling = [[BlingHelper alloc] init];
        [bling  makeCancelBindAlerWith:result];
		[[NSNotificationCenter defaultCenter] postNotificationName:UserDidRebindSucceedNotify object:nil];
    }
}

@end
