//
//  NotificationControlCenter.m
//  weddingTime
//
//  Created by 默默 on 15/9/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NotificationControlCenter.h"
#import <AVOSCloud.h>
#import "UIImageView+WebCache.h"
#import "BlingService.h"
#import "UserInfoManager.h"
#import "BlingHelper.h"
#import "UserInfoManager.h"
#import "LoginManager.h"
#import "WTSupplierViewController.h"
#import "WTHotelViewController.h"
#import "SliderListVCManager.h"
#import "WTChatListViewController.h"
#import "WTDemandDetailViewController.h"
#import "WTDemandListViewController.h"
#import "WTOrderListViewController.h"
#import "WTOrderDetailViewController.h"
#import "NotificationTopPush.h"
#import "WTDrawViewController.h"
#import "WTKissViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTWorksDetailViewController.h"
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
    if (application.applicationState == UIApplicationStateActive) {
    } else {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    
    if (!userInfo) {
        return;
    }
    NSString *pushKey=userInfo[PushRemoteIdJumpKey];
    
    //聊天消息们此版本不作处理因为不论何时进来程序一定有顶部的弹出
    if (application.applicationState == UIApplicationStateActive) {//程序在前台接到的通知
        if(![pushKey isNotEmptyCtg])
            return;
        //todo喜欢估摸着不作处理
        //todo计划估摸着不作处理
        if ([pushKey isEqualToString:PushRemotUpdateUserInfo]) {
            if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
                return;
            }
            [[UserInfoManager instance] updateUserInfoFromServer];
        }
        if ([pushKey isEqualToString:PushRemoteIdDemaindNewBidding]||[pushKey isEqualToString:UserPostNewReward]) {//商家抢单
            if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
                return;
            }
            [self dealDeamindSucceedPushWith:userInfo];
        }
        
        if([pushKey isEqualToString:PushBindMessage]){
            //todo对用户信息进行操作，通知所有观察者
            if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
                return;
            }
            [self dealBlingpPushWith:userInfo from:1];
        }

        if ([pushKey isEqualToString:UserPayDeposit]|| [pushKey isEqualToString:PushRemoteIdRefundSucceed] || [pushKey isEqualToString:PushRemoteIdReserveSucceed]||[pushKey isEqualToString:UserPostNewOrder]) {

            if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
                return;
            }
            if ([KeyWindowCurrentViewController isKindOfClass:[WTOrderListViewController class]] || [KeyWindowCurrentViewController isKindOfClass:[WTOrderDetailViewController class]] ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidPayed object:nil];
            } else {
                [self dealOrderPushWith:userInfo];
            }
        }
    }else {//程序从后台切进来触发的通知
        if([pushKey isEqualToString:PushBindMessage]){
            //todo对用户信息进行操作，通知所有观察者
            if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
                return;
            }
            [self dealBlingpPushWith:userInfo from:2];
        }
        if (![KEY_WINDOW.rootViewController isKindOfClass:[UINavigationController class]]) {
            return;//在弹出警告框之类的时候 根视图不是导航视图 push会出错 所以加判断~虽然可能性很小
        }
        
        NSDictionary *data = userInfo[@"data"];
        
        if ([pushKey isEqualToString:PushRemoteIdPushToSupplier]) {
            if (!data) {
                return;
            }
            NSString *supplierId=[LWUtil getString:data[@"supplierId"] andDefaultStr:@""];
            UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
            if ([supplierId isNotEmptyCtg]) {
                NSString *sign=data[@"sign"];
                if ([sign isEqualToString:@"s"]) {
                    if ([[LWUtil getString:supplierId andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_supplier] && [KeyWindowCurrentViewController isKindOfClass:[WTSupplierViewController class]]) {
                        return;
                    }
                    WTSupplierViewController *supplierInfoViewController = [[WTSupplierViewController alloc] init];
                    supplierInfoViewController.supplier_id =[NSNumber numberWithInt:[supplierId intValue]];
                    [nav pushViewController:supplierInfoViewController animated:YES];
                }
                else if ([sign isEqualToString:@"h"]) {
                    if ([[LWUtil getString:supplierId andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_hotel_id] && [KeyWindowCurrentViewController isKindOfClass:[WTHotelViewController class]]) {
                        return;
                    }
                    WTHotelViewController *hotelInfoViewController = [[WTHotelViewController alloc] init];
                    hotelInfoViewController.hotel_id = [NSNumber numberWithInt:[supplierId intValue]];
                    [nav pushViewController:hotelInfoViewController animated:YES];
                }
            }
        }
//        else if ([pushKey isEqualToString:PushRemoteIdPushToInspiration]) {
//            NSDictionary *result = userInfo[@"data"];
//            if (!result) {
//                return;
//            }
//            NSString *tag=result[@"tag"];
//            NSDictionary *color=result[@"color"];
//            UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
//            if ([tag isNotEmptyCtg]) {
//                InspiretionListViewController *ins = [[InspiretionListViewController alloc] init];
//                ins.searchTag = tag;
//                [nav pushViewController:ins animated:YES];
//            }
//            else
//            {
//                InspiretionListViewController *ins = [[InspiretionListViewController alloc] init];
//                ins.searchColor = color;
//                [nav pushViewController:ins animated:YES];
//            }
//        }
        else if ([pushKey isEqualToString:PushPostToUser])
        {
            if (([KeyWindowCurrentViewController isKindOfClass:[WTWorksDetailViewController class]] && [[WeddingTimeAppInfoManager instance].curid_work isEqualToString:[LWUtil getString:data[@"post_id"] andDefaultStr:@""]])) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:WorkRefresh object:nil];
            } else {
                [NotificationTopPush pushToWorkDetailWtihwork_id:[LWUtil getString:data[@"post_id"] andDefaultStr:@""]];
            }
        }
        
        if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
            return;
        }
        
        if ([pushKey isEqualToString:UserPostNewOrder] || [pushKey isEqualToString:UserPayDeposit]|| [pushKey isEqualToString:PushRemoteIdRefundSucceed] || [pushKey isEqualToString:PushRemoteIdReserveSucceed] ) {
            NSString *order_id =[LWUtil getString:data[@"out_trade_no"] andDefaultStr:@""];
            if ([KeyWindowCurrentViewController isKindOfClass:[WTOrderDetailViewController class]] && [[WeddingTimeAppInfoManager instance].curid_order_detail isEqualToString:order_id]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidPayed object:nil];
            } else {
                [NotificationTopPush pushToOrderDetailWtihOrder_id:order_id];
            }
        }
        //三个游戏只在外部点击会直接跳转到游戏
        else if ([pushKey isEqualToString:PushRemoteIdDrawWithPartner]) {
            UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
            if (![nav.topViewController isKindOfClass:[WTDrawViewController class]]) {
                WTDrawViewController *drawVC =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WTDrawViewController"];
                drawVC.isFromJoin=YES;
                [nav pushViewController:drawVC animated:YES];
            }
        }else if ([pushKey isEqualToString:PushRemoteIdKissWithPartner]) {
            UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
            if (![nav.topViewController isKindOfClass:[WTKissViewController class]]) {
                WTKissViewController *kissVc = [[WTKissViewController alloc] init];
                kissVc.isFromJoin=YES;
                [nav pushViewController:kissVc animated:YES];
            }
        }else if ([pushKey isEqualToString:PushRemoteIdShareLocation]) {
            
        }
        //服务器推荐也只有外部点击会直接跳转
        else if ([pushKey isEqualToString:PushRemoteIdDemaindNewBidding]||[pushKey isEqualToString:UserPostNewReward]) {//商家抢单
            if (data) {
                NSString *reward_id = [LWUtil getString:data[@"reward_id"] andDefaultStr:@""];
                if (!([KeyWindowCurrentViewController isKindOfClass:[WTDemandDetailViewController class]] && [[WeddingTimeAppInfoManager instance].curid_demand_detail isEqualToString:[LWUtil getString:data[@"reward_id"] andDefaultStr:@""]])) {
                    [NotificationTopPush pushToDemaindDetailWithRewardId:reward_id];
                }
            }
        } else if ([pushKey isNotEmptyCtg]) {
            NSString *ourconversationId = [ChatMessageManager instance].keyedConversationOur.conversationId;
            if ([ourconversationId isNotEmptyCtg]) {
                if (!([KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]] && [[LWUtil getString:ourconversationId andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_conversation])) {
                    [[ChatMessageManager instance]setWaitOpenConversatinId:ourconversationId];
                }
            }
        }
        else
        {
            if (![pushKey isNotEmptyCtg]||[pushKey isEqualToString:pushRemoteIdContentNormalMessage]) {
                NSString *conversationId=[LWUtil getString:userInfo[PushRemoteIdConversationId] andDefaultStr:@""];
                if ([conversationId isNotEmptyCtg]) {
                    if (!([KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]] && [[LWUtil getString:conversationId andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_conversation])) {
                        [[ChatMessageManager instance]setWaitOpenConversatinId:conversationId];
                    }
                }
            }
        }
    }
    
    //todo另一半的喜欢和计划全都没处理
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
            [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:UIStatusBarAnimationSlide];
        
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

//- (void)dealWorkPushWith:(NSDictionary *)userInfo
//{
//    NSDictionary *data = userInfo[@"data"];
//    if ([[LWUtil getString:data[@"post_id"] andDefaultStr:@""] isEqualToString:[WeddingTimeAppInfoManager instance].curid_work] && [KeyWindowCurrentViewController isKindOfClass:[WorksDetailViewController class]]) {
//        return
//    } else {
//        [self pushTopViewOnKeyWindow: title:@"" subTitle:@"" type:@"" object:@""]
//    }
//}

- (void)dealBlingpPushWith:(NSDictionary *)userInfo from:(int)type
{
    
    NSDictionary *result = userInfo;
    NSNumber *sign = result[@"sign"];
    if (type == 1) {
        if (sign.integerValue == 1) {
            // 绑定请求推送
            BlingHelper *bling = [[BlingHelper alloc] init];
            [bling makeAlertWith:result type:0];
            
            //        [BlingService getInviteStateWithBlock:^(NSDictionary *dic, NSError *error) {
            //            BlingHelper *bling = [[BlingHelper alloc] init];
            //            [bling makeAlertWith:dic];
            //        }];
        }
    }
     if (sign.integerValue == 2){
        // 绑定成功推送
        [UserInfoManager instance].userId_partner = result[@"partner_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidBindingPartnerNotify object:nil];
        BlingHelper *bling = [[BlingHelper alloc] init];
        [bling makeSuccessAlertWith:result];
        //        [BlingService getInviteStateWithBlock:^(NSDictionary *dic, NSError *error) {
        //            BlingHelper *bling = [[BlingHelper alloc] init];
        //            [bling makeSuccessAlertWith:dic];
        //        }];
    } else if (sign.integerValue == 3) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RefuseBinding object:nil];
        BlingHelper *bling = [[BlingHelper alloc] init];
        [bling makeRefuseAlertWith:result];
        
        //        [BlingService getInviteStateWithBlock:^(NSDictionary *dic, NSError *error) {
        //            BlingHelper *bling = [[BlingHelper alloc] init];
        //            [bling makeRefuseAlertWith:dic];
        //        }];
    } else if (sign.integerValue == 4) {
        BlingHelper *bling = [[BlingHelper alloc] init];
        [bling  makeCancelBindAlerWith:result];
    }
    
}

-(void)dealDeamindSucceedPushWith:(NSDictionary *)userInfo{
    NSDictionary *data=userInfo[@"data"];
    [[NSNotificationCenter defaultCenter]postNotificationName:DemandDidRibedNotification object:nil userInfo:@{@"demandId":data[@"reward_id"]}];
    if([KeyWindowCurrentViewController isKindOfClass:[WTDemandListViewController class]]||[KeyWindowCurrentViewController isKindOfClass:[WTDemandDetailViewController class]])
    {
        return;
    }
    
    [self pushTopViewOnKeyWindow:data[@"user_avatar"] title:data[@"user_username"] subTitle:userInfo[@"aps"][@"alert"] type:WTNotificationTopViewTypeDemaindReserverSuccess message:nil object:data[@"reward_id"]];
}

- (void)dealOrderPushWith:(NSDictionary *)userInfo
{
    NSDictionary *data = userInfo[@"data"];
    [self pushTopViewOnKeyWindow:data[@"user_avatar"] title:data[@"user_name"] subTitle:userInfo[@"aps"][@"alert"] type:WTNotificationTopViewTypeOrder message:nil object:data[@"out_trade_no"]];
}

@end
