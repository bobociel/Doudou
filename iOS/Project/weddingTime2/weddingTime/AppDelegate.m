//
//  AppDelegate.m
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "AppDelegate.h"
#import "QHNavigationController.h"
#import "WTMainViewController.h"
#import "WTLoginViewController.h"
#import "WTChatDetailViewController.h"
#import "UserInfoManager.h"
#import "ChatMessageManager.h"
#import "UserService.h"
#import "BlingHelper.h"
#import "MobClick.h"
@interface AppDelegate ()<WeiboSDKDelegate,WXApiDelegate,QQApiInterfaceDelegate,BMKGeneralDelegate,LocationManagerDelegate>
@property(strong,nonatomic)BMKMapManager   *bmkMapManager;
@property(strong,nonatomic)LocationManager *locationManager;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[[UITextField appearance] setTintColor:WeddingTimeBaseColor];
	[[UITextView appearance] setTintColor:WeddingTimeBaseColor];

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];

	QHNavigationController *nav = [[QHNavigationController alloc] initWithRootViewController:[WTMainViewController new]];
	self.window.rootViewController = nav;

	[WXApi registerApp:WechatAppId];
	[WeiboSDK registerApp:SinaKey];
    //开启AVOS 这将涉及到聊天IM和通知APN 生产环境和测试环境务必分开
    [AVOSCloud setApplicationId:AVOSAPPID clientKey:AVOSAPPKEY];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	[TBAppLinkSDK initWithAppkey:TBAppKey BackURL:kURLTypeTB pid:nil type:nil];
	[[TBAppLinkSDK sharedInstance] setAppSecret:TBAppSecret];
	[[TBAppLinkSDK sharedInstance] setJumpFailedMode:TBAppLinkJumpFailedModeOpenH5];
#ifdef DEBUG
    [AVPush setProductionMode:NO];
	[AVAnalytics setLogEnabled:YES];
	[AVOSCloud setAllLogsEnabled:YES];
#else
    [AVPush setProductionMode:YES];
	[AVAnalytics setLogEnabled:NO];
	[AVOSCloud setAllLogsEnabled:NO];
#endif

#if DEBUG
    [MobClick setLogEnabled:YES];
    [MobClick setCrashReportEnabled:YES];
    [MobClick startWithAppkey:UMENGKEY reportPolicy:REALTIME channelId:nil];
    [MobClick setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
#else
    [MobClick startWithAppkey:UMENGKEY reportPolicy:BATCH channelId:nil];
    [MobClick setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
#endif

	[[AFNetworkReachabilityManager sharedManager] startMonitoring];
	[WeddingTimeAppInfoManager checkUserNotificationSettings];
	[[UserInfoManager instance] loadFromUserDefaults];
	[[SQLiteAssister sharedInstance] loadDataBaseCustom];
	[[ChatMessageManager instance] beginManage];
	[self startLocation];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    [[NotificationControlCenter instance] dealNotificationUWithUserInfo:userInfo application:application];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	[[WTLocalNoticeManager manager] dealNotificationWithNotification:notification application:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application{

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    if ([[UserInfoManager instance].tokenId_self isNotEmptyCtg]){
		[BlingHelper updateInviteStateCallback:nil];
        [[UserInfoManager instance] updateUserInfoFromServer];
    }
    
    int num=(int)application.applicationIconBadgeNumber;
    if(num!=0){
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [currentInstallation saveEventually];
        }];
        application.applicationIconBadgeNumber=0;
    }
    [application cancelAllLocalNotifications];

	//检测版本更新
	[WeddingTimeAppInfoManager checkVersion];

	//检测通知是否开启
	if([KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]]){
		if(![WeddingTimeAppInfoManager openedNotification]){
			WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"您还没有启用消息通知" centerImage:nil];
			[alertView setButtonTitles:@[@"去开启",@"暂不开启"]];
			[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
				if(buttonIndex == 0){
					NSString *openString = isEqualOrThanIOS8 ? UIApplicationOpenSettingsURLString: @"prefs:root=NOTIFICATIONS_ID" ;
					NSURL *openURL = [NSURL URLWithString:openString];
					[[UIApplication sharedApplication] openURL:openURL];
				}else if (buttonIndex == 1){
					[KeyWindowCurrentViewController.navigationController popViewControllerAnimated:YES];
				}
			}];
			[alertView show];
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

 - (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //将获取到的token传给avos
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
	[currentInstallation setDeviceProfile:app_deviceProfile];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSNumber *resultStatus = resultDic[@"resultStatus"];
        if (resultStatus.integerValue == 6001 || resultStatus.integerValue == 6002 || resultStatus.integerValue == 4000) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AlipayFailCallBack object:nil];
        } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:AlipayCallBack object:nil];
        }
    }];
	return [WeiboSDK handleOpenURL:url delegate:self] || [WXApi handleOpenURL:url delegate:self] || [QQApiInterface handleOpenURL:url delegate:self] ;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [WeiboSDK handleOpenURL:url delegate:self]
	|| [WXApi handleOpenURL:url delegate:self]
	|| [QQApiInterface handleOpenURL:url delegate:self]
	|| [[TBAppLinkSDK sharedInstance] handleOpenURL:url];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString *resultString = @"";
    switch (response.statusCode)
    {
        case WeiboSDKResponseStatusCodeSuccess: resultString = @"发送成功" ; break;
        case WeiboSDKResponseStatusCodeUserCancel: resultString = @"取消发送"; break;
        case WeiboSDKResponseStatusCodeSentFail: resultString = @"发送失败"; break;
        default: resultString = @"发送失败"; break;
    }
    [WTProgressHUD ShowTextHUD:resultString showInView:KeyWindowCurrentViewController.view];
}

- (void)onResp:(BaseResp *)resp
{
    NSString *resultString = @"";
    if([resp isKindOfClass:[BaseResp class]])
    {
		if([resp isKindOfClass:[SendAuthResp class]]){
			if(resp.errCode == WXSuccess){
				[[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginWithWX object:nil userInfo:@{@"data":[resp modelToJSONObject]}];
			}else{
				[WTProgressHUD ShowTextHUD:@"授权失败" showInView:KeyWindowCurrentViewController.view];
			}
		}
		else
		{
			switch (resp.errCode){
				case WXSuccess: resultString = @"发送成功" ; break;
				case WXErrCodeCommon: resultString = @"发送失败"; break;
				case WXErrCodeUserCancel: resultString = @"取消发送"; break;
				default: resultString = @"发送失败"; break;
			}
			[WTProgressHUD ShowTextHUD:resultString showInView:KeyWindowCurrentViewController.view];
		}
    }
    else if([resp isKindOfClass:[QQBaseResp class]])
	{
        QQBaseResp *response = (QQBaseResp *)resp;
        resultString = response.errorDescription ? @"发送失败" : @"发送成功";
		[WTProgressHUD ShowTextHUD:resultString showInView:KeyWindowCurrentViewController.view];
    }
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)onReq:(QQBaseReq *)req{
    
}

#pragma mark - Other
+ (ALAssetsLibrary *)assetLibrary
{
	static ALAssetsLibrary *assetLibrary;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		assetLibrary = [[ALAssetsLibrary alloc] init];
	});
	return assetLibrary;
}

- (void)startLocation
{
	self.bmkMapManager = [[BMKMapManager alloc] init];
	[self.bmkMapManager start:BMapKey generalDelegate:self];

	_locationManager = [[LocationManager alloc] init];
	_locationManager.delegate = self;
	[_locationManager beginSearch];
}

- (void)didLocationSucceed:(BMKReverseGeoCodeResult *)result
{
	[UserInfoManager instance].city_name = result.addressDetail.city;
	[[UserInfoManager instance] saveToUserDefaults];
	[_locationManager stopLocating];

	[GetService getCityidWithLon:result.location.longitude  andLat:result.location.latitude WithBlock:^(NSDictionary *result, NSError *error) {
		if (!error) {
			if ([result isKindOfClass:[NSDictionary class]]) {
				if (result[@"city_id"]) {
					[UserInfoManager instance].curCityId = [result[@"city_id"] intValue];
					[[UserInfoManager instance] saveToUserDefaults];
				}
			}
		}
	}];
}

- (void)didiFalidLocation
{
	[_locationManager stopLocating];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[SDImageCache sharedImageCache] clearMemory];
}

@end
