//
//  AppDelegate.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginOrRegisterViewController.h"
#import "HomeViewController.h"
#import "MessageViewController.h"
#import "ListingViewController.h"
#import "ContactViewController.h"
#import "MeViewController.h"
#import "HttpManager.h"
#import "City.h"
#import <MJExtension/MJExtension.h>
#import "AppConfigure.h"
#import "PostDetailViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseFunction.h"
#import "EaseMob.h"
#import "MessageDetailController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AskDetailViewController.h"
#import "NewsCommentListViewController.h"
#import "UMessage.h"
#import "NewAskViewController.h"

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate () <CLLocationManagerDelegate, EMChatManagerDelegate, UIAlertViewDelegate> {
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    UIBackgroundTaskIdentifier _taskIdentifier;
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

// 两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

static NSString *const HUANXIN_DEVELOP_KEY = @"nihao_develop";
static NSString *const HUANXIN_DISTRIBUTE_KEY = @"nihao_distribute";
static NSString *const HUANXIN_APP_NAME = @"appnihao#nihao";

static NSString *const UMENG_PUSH_KEY = @"55bf0101e0f55a3f03005160";

static NSString *const FLURRY_KEY = @"BW93ZYTHCX4YD2WRWT5D";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self initDefaultServiceCity];
    BOOL isLogined = [AppConfigure boolForKey:IS_LOGINED];
    // 未登录
    if (!isLogined) {
        [self userLogin];
    } else {
        [self printLoginedUserInfo];
        // 已登录
        [self initTabBar];
        [self autoLoginHuanxin];
    }
    [self initHuanXinSDK:application didFinishLaunchingWithOptions:launchOptions];
    //设置软件当前环境为英文
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
    
    // 设置状态栏的字体颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:AppBlueColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Disable IQKeyboardManager in these ViewController
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[PostDetailViewController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[MessageDetailController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[AskDetailViewController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[NewsCommentListViewController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[NewAskViewController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[LoginOrRegisterViewController class]];
    
    //注册application badge和messagecontroller itembar badge数量变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageBadgeNumberChanged:) name:KNOTIFICATION_MESSAGE_BADGE_CHANGED object:nil];
    
    //移动统计
    /*[Flurry setLogLevel:FlurryLogLevelDebug];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:FLURRY_KEY];*/
    
    //友盟推
    [UMessage startWithAppkey:UMENG_PUSH_KEY launchOptions:launchOptions];
    [UMessage setAutoAlert:NO];
    //[UMessage setLogEnabled:YES];
    [self initUMengPushSetting];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    _taskIdentifier = UIBackgroundTaskInvalid;
    return YES;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}

/**
 *  初始化环信sdk
 *
 *  @param application
 */
- (void) initHuanXinSDK : (UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[EaseMob sharedInstance] registerSDKWithAppKey:HUANXIN_APP_NAME apnsCertName:HUANXIN_DISTRIBUTE_KEY];
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)userLogin {
    LoginOrRegisterViewController *loginViewController = [[LoginOrRegisterViewController alloc] init];
    loginViewController.loginOrRegisterType = LoginOrRegisterTypeLogin;
    loginViewController.loginSucceed = ^(){
        [self printLoginedUserInfo];
        // 保存登录状态
        [AppConfigure setBool:YES forKey:IS_LOGINED];
        [self autoLoginHuanxin];
        // 登录成功，跳转到主界面
        [self initTabBar];
        //获取用户未读消息数
        [self requestUnreadMessage];
    };
    UINavigationController *loginNavController = [self navigationControllerWithRootViewController:loginViewController isHideNavBar:NO];
    self.window.rootViewController = loginNavController;
}

- (void)initTabBar {
    UITabBarController *rootTabBarController = [[UITabBarController alloc] init];
    
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *homeNavController = [self navigationControllerWithRootViewController:homeViewController isHideNavBar:NO];
    MessageViewController *messageViewController = [[MessageViewController alloc] init];
    UINavigationController *messageNavController = [self navigationControllerWithRootViewController:messageViewController isHideNavBar:NO];
    ListingViewController *listingViewController = [[ListingViewController alloc] init];
    UINavigationController *listingNavController = [self navigationControllerWithRootViewController:listingViewController isHideNavBar:NO];
    ContactViewController *contactViewController = [[ContactViewController alloc] init];
    UINavigationController *contactNavController = [self navigationControllerWithRootViewController:contactViewController isHideNavBar:NO];
    MeViewController *meViewController = [[MeViewController alloc] init];
    UINavigationController *meNavController = [self navigationControllerWithRootViewController:meViewController isHideNavBar:NO];
    
    rootTabBarController.viewControllers = @[homeNavController, messageNavController, listingNavController, contactNavController, meNavController];
    // 设置tabbar选中时的字体颜色
    rootTabBarController.tabBar.tintColor = AppBlueColor;
    
    self.window.rootViewController = rootTabBarController;
}

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController isHideNavBar:(BOOL)isHideNavBar {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navController.navigationBar.barTintColor = AppBlueColor;
    navController.navigationBar.tintColor = [UIColor whiteColor];
    
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:FontNeveLightWithSize(16.0)}];
    navController.navigationBar.hidden = isHideNavBar;
    navController.navigationBar.translucent = NO;
    
    return navController;
}

// 退出登录
- (void)userLogOut {
    // 1. 删除已登录用户信息
    [self clearLoginUserInfo];
    // 2. 设置登录标记为未登录
    [AppConfigure setBool:NO forKey:IS_LOGINED];
    // 3. 跳转到登录界面
    [self userLogin];
}

//初始化app默认服务城市信息
- (void) initDefaultServiceCity {
    [HttpManager queryCities:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            NSDictionary *items = responseObject[@"result"][@"items"];
            NSArray *cities = [City objectArrayWithKeyValuesArray:items];
            //初始化app第一次进入时，默认支持的城市
            City *defaultCity;
            for(City *city in cities) {
                NSString *cityNameEn = city.city_name_en;
                //去除字符串中间的空格并转为小写字母后与默认城市比较
                cityNameEn = [[cityNameEn stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
                if([cityNameEn isEqualToString:[DEFAULT_CITY_NAME_EN lowercaseString]]) {
                    defaultCity = city;
                    break;
                }
            }
            
            if(!defaultCity) {
                defaultCity = [[City alloc] init];
                defaultCity.city_id = DEFAULT_CITY_ID;
                defaultCity.city_name = DEFAULT_CITY_NAME_CN;
                defaultCity.city_name_en = DEFAULT_CITY_NAME_EN;
            }
            [City saveCityToUserDefault:defaultCity key:DEFAULT_CITY];
            [City saveCityListToUserDefault:cities];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        City *defaultCity = [[City alloc] init];
        defaultCity.city_id = DEFAULT_CITY_ID;
        defaultCity.city_name = DEFAULT_CITY_NAME_CN;
        defaultCity.city_name_en = DEFAULT_CITY_NAME_EN;
        [City saveCityToUserDefault:defaultCity key:DEFAULT_CITY];
    }];
}

- (void)clearLoginUserInfo {
    [AppConfigure clearLoginUserProfile];
}

- (void)printLoginedUserInfo {
    NSLog(@"logined user = %@", [AppConfigure loginUserProfile]);
}

- (void)requestLocation {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization]; // 永久授权
    }
    
    _locationManager.delegate = self;
    // 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // 开始定位
    [_locationManager startUpdatingLocation];
    
    _geocoder = [[CLGeocoder alloc] init];
}

- (void) requestUnreadMessage {
    NSString *uid =[NSString stringWithFormat:@"%lu",(long)[AppConfigure integerForKey:LOGINED_USER_ID]];
    [HttpManager requestUnreadMessageNums:uid success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            //通知更新ui
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIICATION_UNREAD_MESSAGE_COMES object:responseObject[@"result"]];
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [manager stopUpdatingLocation];
    NSString *currentLatitude = [NSString stringWithFormat:@"%lf", location.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%lf", location.coordinate.longitude];
    
    [self updateUserGPSByLatitude:currentLatitude longitude:currentLongitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //	if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    //		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can't get your location" message:@"please open app location service in settings" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
    //		[alert show];
    //	}
}

- (void)updateUserGPSByLatitude:(NSString *)currentLatitude longitude:(NSString *)currentLongitude {
    NSString *userID = [AppConfigure objectForKey:LOGINED_USER_ID];
    if (IsStringNotEmpty(userID)) {
        NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
        
        NSArray *keys = @[@"ci_id", @"ci_gpslat", @"ci_gpslong", @"random"];
        NSArray *objects = @[userID, currentLatitude, currentLongitude, random];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [HttpManager updateUserGPSByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}

- (void)processDatas {
    _locationManager.delegate = nil;
    _locationManager = nil;
    _geocoder = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self processDatas];
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
    NSString *uid = [AppConfigure objectForKey:REGISTER_USER_ID];
    if(_taskIdentifier == UIBackgroundTaskInvalid && !IsStringEmpty(uid)) {
        _taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
            [[UIApplication sharedApplication] endBackgroundTask:_taskIdentifier];
            _taskIdentifier = UIBackgroundTaskInvalid;
        }];
        NSDictionary *parameters = @{@"ci_id":uid,@"ci_is_online":@"0"};
        [HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] endBackgroundTask:_taskIdentifier];
            _taskIdentifier = UIBackgroundTaskInvalid;
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] endBackgroundTask:_taskIdentifier];
            _taskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self requestLocation];
    [[EaseMob sharedInstance] applicationDidBecomeActive:application];
    BOOL isLogined = [AppConfigure boolForKey:IS_LOGINED];
    if(isLogined)  {
        [self requestUnreadMessage];
    }
    NSString *uid = [AppConfigure objectForKey:REGISTER_USER_ID];
    if(!IsStringEmpty(uid)) {
        NSDictionary *parameters = @{@"ci_id":uid,@"ci_is_online":@"1"};
        [HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self processDatas];
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [UMessage registerDeviceToken:deviceToken];
    NSString *pushToken = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    [AppConfigure setObject:pushToken ForKey:DEVICE_TOKENS];
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive ) {
        NSInteger pushType = [userInfo[@"pushType"] integerValue];
        if(pushType == 2 || pushType == 3 || pushType == 4) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIICATION_UNREAD_MESSAGE_COMES object:userInfo];
        }
    }
}

#pragma mark - 环信自动登录回调
- (void) autoLoginHuanxin {
    [self registerEaseMobNotification];
    //登录环信服务器
    NSString *username = [AppConfigure objectForKey:LOGINED_USER_NAME];
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if (!isAutoLogin) {
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:username completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error) {
                // 设置自动登录
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            }
        } onQueue:nil];
    }
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - IChatManagerDelegate 消息变化

- (BOOL)needShowNotification:(NSString *)fromChatter {
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    return ret;
}

// 收到消息回调
- (void)didReceiveMessage:(EMMessage *)message {
    BOOL needShowNotification = (message.messageType != eMessageTypeChat) ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        } else {
            [self playSoundAndVibration];
        }
        
        //刷新messagecontroller的itembar和app badge红点数量
        //[[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_APPLICATION_BADGE_CHANGED object:badgeNum];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MESSAGE_BADGE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_NEW_MESSAGE_COMES object:nil];
#endif
    }
}

- (void)showNotificationWithMessage:(EMMessage *)message {
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
    [[EaseMob sharedInstance].chatManager updatePushOptions:options error:nil];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //触发通知的时间
    notification.fireDate = [NSDate date];
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[picture]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"Location";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"Voice";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"Video";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.messageType == eMessageTypeGroupChat) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        } else if (message.messageType == eMessageTypeChatRoom) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username"]];
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            NSString *chatroomName = [chatrooms objectForKey:message.conversationChatter];
            if (chatroomName) {
                title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, chatroomName];
            }
        } else {
            title = message.ext[@"em_apns_ext"][@"nickname"];
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    } else {
        notification.alertBody = @"You have a new message";
    }
    
    notification.alertAction = @"Open";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    //收到消息时，播放音频
    AudioServicesPlaySystemSound(1007);
    // 收到消息时，震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

/*!
 @method
 @brief 用户自动登录完成后的回调
 @discussion
 @param loginInfo 登录的用户信息
 @param error     错误信息
 @result
 */
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    if(!error) {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showUnreadMessageNum) userInfo:nil repeats:NO];
    }
}

- (void) showUnreadMessageNum {
    //message badge number设置
    NSUInteger unreadMsgNums = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    UITabBarController *tabController = (UITabBarController *)_window.rootViewController;
    MessageViewController *msgController = tabController.viewControllers[1];
    NSString *badgeValue = (unreadMsgNums == 0) ? nil : [NSString stringWithFormat:@"%lu",(unsigned long)unreadMsgNums];
    msgController.tabBarItem.badgeValue = badgeValue;
}

#pragma mark - 接受离线消息
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Prompt" message:@"your login account has been in other places" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
    } onQueue:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self userLogOut];
}

#pragma mark - 应用图标和消息红点数量处理
/**
 *  message badge数量变化处理方法
 *
 *  @param notification
 */
- (void) messageBadgeNumberChanged : (NSNotification *) notification {
    [self showUnreadMessageNum];
}

#pragma mark - umeng push message
- (void) initUMengPushSetting {
    //[UMessage setAutoAlert:NO];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        //UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        //action2.identifier = @"action2_identifier";
        //action2.title=@"Reject";
        //action2.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候不启动程序，在后台处理
        //action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        //action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:nil forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
#else
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound];
#endif
}

@end
