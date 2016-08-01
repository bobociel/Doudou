//
//  NotificationControlCenter.h
//  weddingTime
//
//  Created by 默默 on 15/9/21.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRYSerialAnimationQueue.h"
#import "NotificationTopView.h"
//推送
#define PushBindMessage                  @"PushBindMessage"                 //新人绑定推送(服务器)

#define PushRemoteIdJumpKey              @"PushRemoteIdJumpKey"              //聊天推送消息类型 key
#define PushRemoteIdConversationId       @"PushRemoteIdConversationId"       //聊天消息推送 会话id key
#define pushRemoteIdContentNormalMessage @"pushRemoteIdContentNormalMessage" //聊天推送消息类型value 普通消息推送
#define PushRemoteIdDrawWithPartner      @"draw-sda-sddx-222"                //聊天推送消息类型value 邀请draw推送
#define PushRemoteIdKissWithPartner      @"kiss-xx-3eew"                     //聊天推送消息类型value 邀请kiss推送

#define PushRemoteIdPushToSupplier      @"PushRemoteIdPushToSupplier"   //服务器主动推荐 - 商家
#define PushPostToUser                  @"PushPostToUser"               //服务器主动推荐 - 帖子（作品）
#define PushTagToUser                   @"PushTagToUser"                //服务器主动推荐 - 灵感 (标签)
#define PushColorToUser                 @"PushColorToUser"              //服务器主动推荐 - 灵感（颜色）
#define SendBless                       @"SendBless"                    //收到祝福的推送(服务器)
#define CouponChange                    @"CouponChange"                 //已扫码(服务器)
#define kLogoToPushURL                  @"http://mt-ui.qiniudn.com/logo_ios_300.jpg"  //服务器推送通知的LOGO

//本地通知
#define UserInfoUpdate                  @"UserInfoUpdate"                  //更新用户信息
#define RefuseBinding                   @"RefuseBinding"                   //被拒绝绑定通知
#define reLoginNotify                   @"reLoginNotify"                   //重新登录通知(更新绑定状态)
#define UserDidRebindSucceedNotify      @"UserDidRebindSucceedNotify"      //解绑绑定成功
#define UserDidLoginWithWX              @"UserDidLoginWithWX"              //微信登录
#define PushbackgroundImageChanged      @"PushbackgroundImageChanged"      //主背景改变
#define HomePageWebShouldBeReloadNotify @"HomePageWebShouldBeReloadNotify" //更新婚礼主页

//不用的本地通知
#define BaseNumChange                   @"BaseNumChange"
#define UserDidLogoutSucceedNotify      @"UserDidLogoutSucceedNotify"  //退出登录
#define AlipayCallBack                  @"AlipayCallBack"
#define AlipayFailCallBack              @"AlipayFailCallBack"
#define UserDidPayed                    @"UserDidPayed"
//不用的
#define UserPostNewOrder             @"UserPostNewOrder"

#define PushRemoteIdShareLocation    @"sharelocation-lox-3eew"

#define UserPostNewReward            @"UserPostNewReward"
#define PushRemoteNewDemaind         @"PushRemoteNewDemaind"
#define PushRemoteIdDemaindNewBidding @"PushRemoteIdDemaindNewBidding"

#define PushRemotUpdateUserInfo       @"PushRemotUpdateUserInfo"
#define PushRemotUpdateOrders         @"PushRemotUpdateOrders"
#define PushRemoteIdReserveSucceed    @"ReserveSucceed"
#define PushRemoteIdRefundAccepted    @"RefundAccepted"
#define PushRemoteIdRefundSucceed     @"RefundSucceed"

#define UserPayDeposit                   @"UserPayDeposit"
#define UserPayFail                      @"UserPayFail"
#define PartnerPayDeposit                @"PartnerPayDeposit"
#define PartnerPayFail                   @"PartnerPayFail"
@interface NotificationControlCenter : NSObject
+ (NotificationControlCenter *)instance;
@property (nonatomic,strong) BRYSerialAnimationQueue *animationQueue;
@property (nonatomic,strong) NSMutableArray *queue;
-(void)dealNotificationUWithUserInfo:(NSDictionary *)userInfo application:(UIApplication *)application;
-(void)pushTopViewOnKeyWindow:(NSString*)avatar title:(NSString*)title subTitle:(NSString*)subTitle type:(WTNotificationTopViewType)type   message:(AVIMMessage *)message object:(id)object;
@end
