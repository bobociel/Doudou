//
//  NotificationControlCenter.h
//  weddingTime
//
//  Created by 默默 on 15/9/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVObject.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "BRYSerialAnimationQueue.h"
#import "NotificationTopView.h"
//本地通知
#define AlipayCallBack @"AlipayCallBack"
#define AlipayFailCallBack @"AlipayFailCallBack"
#define BaseNumChange @"BaseNumChange"
//推送
#define PushBindMessage @"PushBindMessage"
#define PushRemoteIdJumpKey @"PushRemoteIdJumpKey"

//推送
static  NSString* const PushRemotUpdateUserInfo=@"PushRemotUpdateUserInfo";
static  NSString* const PushRemotUpdateOrders=@"PushRemotUpdateOrders";
static  NSString* const PushRemotUpdateRequirement=@"PushRemotUpdateRequirement";
#define PushRemoteIdJumpKey @"PushRemoteIdJumpKey"
#define PushRemoteIdReserveSucceed @"ReserveSucceed"


#define UserPostNewOrder  @"UserPostNewOrder"
#define PushRemoteIdRefundAccepted                    @"RefundAccepted"
#define PushRemoteIdRefundSucceed       @"RefundSucceed"


#define PushPostToUser @"PushPostToUser"
#define UserPostNewReward @"UserPostNewReward"
#define PushRemoteIdDemaindNewBidding     @"NewBidding"//有商家参与竞标
#define PushRemoteIdPartnerLike         @""
#define PushRemoteIdReBindingPartner      @"PushRemoteIdReBindingPartner"
#define PushRemoteIdDrawWithPartner     @"draw-sda-sddx-222"
#define PushRemoteIdKissWithPartner     @"kiss-xx-3eew"
#define PushRemoteIdShareLocation       @"sharelocation-lox-3eew"
#define PushRemoteIdBindingPartner      @"PushRemoteIdBindingPartner"
#define PushRemoteIdPushToSupplier          @"PushRemoteIdPushToSupplier"//服务器主动推荐
#define PushRemoteIdPushToInspiration          @"PushRemoteIdPushToInspiration"//服务器主动推荐

#define PushRemoteNewDemaind                @"PushRemoteNewDemaind"
#define PushRemoteIdConversationId           @"PushRemoteIdConversationId"
#define pushRemoteIdContentNormalMessage          @"pushRemoteIdContentNormalMessage"
#define UserPayDeposit                  @"UserPayDeposit"
#define UserPayFail                     @"UserPayFail"
#define PartnerPayDeposit               @"PartnerPayDeposit"
#define PartnerPayFail                  @"PartnerPayFail"
//本地通知
#define PushbackgroundImageChanged          @"PushbackgroundImageChanged"
#define UserDidBindingPartnerNotify              @"UserDidBindingPartnerNotify"//接到对方的绑定成功通知
#define RefuseBinding   @"RefuseBinding"
#define reLoginNotify  @"reLoginNotify"
#define UserDidRebindSucceedNotify               @"UserDidRebindSucceedNotify"//解绑成功
#define SecondBottomPush @"SecondBottomPush"
#define UserDidCancelLikeNotify          @"UserDidCancelLikeNotify"
#define UserDidCreateNewDemaind          @"UserDidCreateNewDemaind"
#define UserDidLogoutSucceedNotify               @"UserDidLogoutSucceedNotify"//退出登录

#define UserDidPayed                     @"UserDidPayed"
#define WorkRefresh                      @"WorkRefresh"
//婚礼主页
#define HomePageWebShouldBeReloadNotify  @"HomePageWebShouldBeReloadNotify"
@interface NotificationControlCenter : NSObject
+ (NotificationControlCenter *)instance;
@property (nonatomic,strong) BRYSerialAnimationQueue *animationQueue;
@property (nonatomic,strong) NSMutableArray *queue;
-(void)dealNotificationUWithUserInfo:(NSDictionary *)userInfo application:(UIApplication *)application;
-(void)pushTopViewOnKeyWindow:(NSString*)avatar title:(NSString*)title subTitle:(NSString*)subTitle type:(WTNotificationTopViewType)type   message:(AVIMMessage *)message object:(id)object;
@end
