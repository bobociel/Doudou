//
//  AppDelegate.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/8.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "AppDelegate.h"
#import "YHConfig.h"
#import "LocationMgr.h"
#import "YHServerManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[[YHDataCache instance] load];
	[[YHConfig instance] load];
	[self initEaseMob];
	[[LocationMgr instance] start];
    [YHServerManager requestCaptcha:13000000000];
    [YHServerManager verifyCaptcha:@"1234" mobile:13000000000];
	[YHServerManager signin:@"123" password:@"123"];
	return YES;
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Easemob
- (void) initEaseMob
{
#if USE_EASEMOB	== 1
#if !TARGET_IPHONE_SIMULATOR
	UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
	UIRemoteNotificationTypeSound |
	UIRemoteNotificationTypeAlert;
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
#endif
	
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
	NSString *apnsCertName = nil;
#if DEBUG
	apnsCertName = @"chatdemoui_dev";
#else
	apnsCertName = @"chatdemoui";
#endif
	[[EaseMob sharedInstance] registerSDKWithAppKey:@"easemob-demo#chatdemoui" apnsCertName:apnsCertName];
	
#if DEBUG
	[[EaseMob sharedInstance] enableUncaughtExceptionHandler];
#endif
	//以下一行代码的方法里实现了自动登录，异步登录，需要监听[didLoginWithInfo: error:]
	//demo中此监听方法在MainViewController中
	[[EaseMob sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
	
#warning 注册为SDK的ChatManager的delegate (及时监听到申请和通知)
	[[EaseMob sharedInstance].chatManager removeDelegate:self];
	[[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
	
#warning 如果使用MagicalRecord, 要加上这句初始化MagicalRecord
	//demo coredata, .pch中有相关头文件引用
	//    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"%@.sqlite", @"UIDemo"]];
#endif
}
@end
