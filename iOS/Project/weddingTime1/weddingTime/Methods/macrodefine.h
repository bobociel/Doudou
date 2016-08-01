//
//  macrodefine.h
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#ifndef weddingTime_macrodefine_h
#define weddingTime_macrodefine_h

#pragma mark-
#pragma mark 一些有用的宏

//基础视图
#define KEY_WINDOW                [[UIApplication sharedApplication] keyWindow]
#define KeyWindowCurrentViewController ((UINavigationController*)KEY_WINDOW.rootViewController).viewControllers.lastObject
//屏幕宽度
#define screenWidth               [[UIScreen mainScreen] bounds].size.width
#define Width_ato           screenWidth / 414.0
//屏幕高度(带状态栏)
#define screenHeight              [[UIScreen mainScreen] bounds].size.height
#define Height_ato          screenHeight / 736.0
//屏幕高度(不带状态栏)
#define screenHeightWithoutBar    [[UIScreen mainScreen] bounds].size.height - 20

#define UISCREEN_RECT [UIScreen mainScreen].bounds  // 整个屏幕大小


/**************************************************************************************
 **********************************颜色,字体等公共属性************************************
 **************************************************************************************/
#pragma mark-
#pragma mark 颜色,字体等公共属性

#define UISCREEN_RECT [UIScreen mainScreen].bounds  // 整个屏幕大小

// block中替换self
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//  常用颜色
#define WHITE [UIColor whiteColor]
#define BLACK [UIColor blackColor]
#define LIGHTGRAY [UIColor lightGrayColor]


#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define MSLog(fmt,...) NSLog((@"\n\n[行号]%d\n" "[函数名]%s\n" "[日志]"fmt"\n"),__LINE__,__FUNCTION__,##__VA_ARGS__);

#define MSLogMore(fmt, ...) NSLog((@"[文件名]%s\n" "[函数名]%s\n" "[行号]%d \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define NSLog(...)
#define MSLog(fmt,...);
#define MSLogMore(fmt,...);
#endif
#endif

#pragma mark-
#pragma mark IOS版本相关
/**************************************************************************************
 **********************************IOS_APP_版本相关*************************************
 **************************************************************************************/

//IOS版本号 float类型
#define IOS_VERSION            [[[UIDevice currentDevice] systemVersion] floatValue]
//iOS版本号  string 类型
#define SYSTEMVERSION          [[UIDevice currentDevice] systemVersion]

//ios版本比较是否大于等于某个版本号
#define isEqualOrThanIOS8      [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define isEqualOrThanIOS7      [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define isEqualOrThanIOS6      [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0

///是否是iPad
#define IS_IPAD                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

///app版本号  string类型 如 1.0.1
#define APPVERSION                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]




/**************************************************************************************
 **********************************第三方key*******************************************
 **************************************************************************************/

#define BMapKey         @"3KBDazgbuNN3d7dMwBS7u3Og"

#define QiniuUploadKey  @"qiniuUploadlovewithIosKey"

#define WechatAppId     @"wx1f38c18c3e683972"
#define WechatAppSecret @"3f3825938e67c19ae9bf34763a726070"

#define QQAppId         @"101210907"
#define AAApiKey        @"6ce38630cc365c15692bb72bb3652f82"

/**************************************************************************************
 **********************************api定义相关*******************************************
 **************************************************************************************/
#pragma mark-
#pragma mark 接口和API相关
//host
#define AVIMHOST      @"https://leancloud.cn"
#define AVIMSERVERCONVERSATIONID  @"56382c5500b0bf37d7832154"

#ifdef DEBUG
#define APIHOST         @"http://test.lovewith.me"
#define AVOSAPPID       @"o8fvolewsx4ffj5gprqaavv1ukcbkyhbn109hgx8hgqw6v7x"
#define AVOSAPPKEY      @"o3h7p3peausargci68r2ojjidztcoyyzz07qkurtnezmcf8p"
#define AVOSMasterKey   @"0yvorexct7j8so4m9o145upuujz2qa1uaf0oasrfamjhdtzr"
#define HomePageBaseUrl [NSString stringWithFormat:@"%@%@",@"http://test.lovewith.me/u/",[UserInfoManager instance].userId_self]

#define UMENGKEY     @"558bfa1267e58eeba9004042"
#define app_deviceProfile @"dev"
#else

//#define APIHOST         @"http://www.lovewith.me"
//#define HomePageBaseUrl [NSString stringWithFormat:@"%@%@",@"http://www.lovewith.me/u/",[UserInfoManager instance].userId_self]
//#define AVOSAPPID       @"43t6vt1te8ninrxsd6hgdibo8alsbuokhx1hnqyhvxac2im6"
//#define AVOSAPPKEY      @"ye2dy8bvdpewi1801fb08veex59d1jvl8odf3q8g6soelzev"
//#define AVOSMasterKey   @"xx7zamtf1wp33wf6k4hiqpxw1oceva7654xbjivdbjsn28qp"

#define APIHOST         @"http://test.lovewith.me"
#define AVOSAPPID       @"o8fvolewsx4ffj5gprqaavv1ukcbkyhbn109hgx8hgqw6v7x"
#define AVOSAPPKEY      @"o3h7p3peausargci68r2ojjidztcoyyzz07qkurtnezmcf8p"
#define AVOSMasterKey   @"0yvorexct7j8so4m9o145upuujz2qa1uaf0oasrfamjhdtzr"
#define HomePageBaseUrl [NSString stringWithFormat:@"%@%@",@"http://test.lovewith.me/u/",[UserInfoManager instance].userId_self]

#define UMENGKEY     @"558bfa1267e58eeba9004042"
#define app_deviceProfile @"prod"
#endif

//颜色相关


//错误信息打印头
#define ERRORDOMAIN                           @"LOVEWITH"

#define ERROR_NoresultCode                    404

//颜色
#define titleLableColor       [UIColor colorWithRed:67.0f/255.0f green:73.0f/255.0f blue:82.0f/255.0f alpha:1]//主标题颜色
#define subTitleLableColor    [UIColor colorWithRed:122.0f/255.0f green:128.0f/255.0f blue:137.0f/255.0f alpha:1]//副标题颜色

#define hotelHunlishiguangId @"16219"
#define hotelHunlishiguangName @"婚礼时光酒店咨询"