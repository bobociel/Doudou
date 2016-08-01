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
#import "WTLoadingViewController.h"
#import "UserInfoManager.h"
#import "BlingService.h"
#import "GetService.h"
#import "WTSettingViewController.h"
#import "WTDemandListViewController.h"
#import "WTLoginViewController.h"
#import "ChatMessageManager.h"
#import "AVOSCloud.h"
#import "MobClick.h"
#import "BlingHelper.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WTDemandDetailViewController.h"
#import "WXApi.h"
@interface AppDelegate ()<BMKGeneralDelegate,CLLocationManagerDelegate>

@end

@implementation AppDelegate
{
    NSNumber *partnerId;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[[UITextField appearance] setTintColor:WeddingTimeBaseColor];
	[[UITextView appearance] setTintColor:WeddingTimeBaseColor];

    [[UserInfoManager instance] loadFromUserDefaults];
	[[SQLiteAssister sharedInstance] loadDataBaseCustom];
	
	[self checkVersion];
	[self getLocation];
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor    = [UIColor clearColor];
    QHNavigationController *nav = [[QHNavigationController alloc] initWithRootViewController:[WTMainViewController new]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    //开启AVOS 这将涉及到聊天IM和通知APN 生产环境和测试环境务必分开
    [AVOSCloud setApplicationId:AVOSAPPID clientKey:AVOSAPPKEY];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [AVOSCloud setLogLevel:AVLogLevelNone];
    //  [AVOSCloud useAVCloudCN];
    [AVAnalytics setLogEnabled:NO];
#ifdef DEBUG
    [AVPush setProductionMode:NO];
#else
    [AVPush setProductionMode:YES];
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
    [WXApi registerApp:WechatAppId];
    [[ChatMessageManager instance] beginManage];

    [WeddingTimeAppInfoManager checkUserNotificationSettings];//检测推送

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
	
    [[NotificationControlCenter instance] dealNotificationUWithUserInfo:userInfo application:application];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

	[self checkVersion];
}

- (void)checkVersion
{
	//检查版本更新
	[GetService getWeddingTimeVersionInfoWithBlock:^(NSDictionary *result, NSError *error) {
		if(!error){
			if([WeddingTimeAppInfoManager currentVresionDouble] < [WeddingTimeAppInfoManager versionDoubleWithVersion:result[@"version"]]){
				NSString *str = [NSString stringWithFormat:@"有新的版本更新是否前往更新？"];
				WTAlertView *alertView = [[WTAlertView alloc]initWithText:str centerImage:nil];
				[alertView setButtonTitles:@[@"取消",@"更新"]];
				[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
					[alertView close];
					if(buttonIndex == 1){
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"download_url"]]];
					}
				}];
				[alertView show];
			}
		}
	}];
}

- (void)getLocation
{
    self.bmkMapManager=[[BMKMapManager alloc] init];
    [self.bmkMapManager start:BMapKey generalDelegate:self];

	if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
	{
		float currentSysVersion=[[[UIDevice currentDevice]systemVersion]floatValue];
		if (currentSysVersion>=8.0){
			[self.locationManager requestWhenInUseAuthorization];
		}
	}

    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self;
    }

    // 开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
      // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BlingHelper updateInviteState];
    if ([[UserInfoManager instance].tokenId_self isNotEmptyCtg]){
        [[UserInfoManager instance] updateUserInfoFromServer];
    }

    [[NSNotificationCenter defaultCenter]postNotificationName:DemandDidRibedNotification object:nil];
    
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

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{

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
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[SDImageCache sharedImageCache]clearMemory];
}

@end
