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
#define KEY_WINDOW                [(AppDelegate *)[UIApplication sharedApplication].delegate window]
#define KeyWindowCurrentViewController ((UINavigationController*)KEY_WINDOW.rootViewController).viewControllers.lastObject
//屏幕宽度
#define screenWidth               [[UIScreen mainScreen] bounds].size.width
#define Width_ato           (screenWidth / 414.0)
//屏幕高度(带状态栏)
#define screenHeight              [[UIScreen mainScreen] bounds].size.height
#define Height_ato          (screenHeight / 736.0)
//屏幕高度(不带状态栏)
#define screenHeightWithoutBar    [[UIScreen mainScreen] bounds].size.height - 20

#define UISCREEN_RECT [UIScreen mainScreen].bounds  // 整个屏幕大小

#define kSmall600 @"?imageView2/2/w/600"
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
#define IFDEBUG  1
#define NSLog(...) NSLog(__VA_ARGS__)
#define MSLog(fmt,...) NSLog((@"\n\n[行号]%d\n" "[函数名]%s\n" "[日志]"fmt"\n"),__LINE__,__FUNCTION__,##__VA_ARGS__);

#define MSLogMore(fmt, ...) NSLog((@"[文件名]%s\n" "[函数名]%s\n" "[行号]%d \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define IFDEBUG  0
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

#define isLessThanIOS8      [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0
///是否是iPad
#define IS_IPAD                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

///app版本号  string类型 如 1.0.1
#define APPVERSION                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]




/**************************************************************************************
 **********************************第三方key*******************************************
 *************************[result[@"data"][@"page"] integerValue]*************************************************************/

#define BMapKey         @"3KBDazgbuNN3d7dMwBS7u3Og"

#define QiniuUploadKey  @"qiniuUploadlovewithIosKey"

#define WechatAppId     @"wx1f38c18c3e683972"
#define WechatAppSecret @"3f3825938e67c19ae9bf34763a726070"
#define WeChatScope     @"snsapi_userinfo"

#define QQAppId         @"101210907"

#define SinaKey         @"547893767"
#define SinaSecret      @"728da79e6cc0b8343d68723217da78e8"

#define kURLTypeTB      @"lovewithTaoBao1111"
#define TBAppKey        @""
#define TBAppSecret     @""

#define UMENGKEY        @"558bfa1267e58eeba9004042"

/**************************************************************************************
 **********************************api定义相关*******************************************
 **************************************************************************************/
#pragma mark-
#pragma mark 接口和API相关
//host
#define AVIMHOST                  @"https://leancloud.cn"
#define AVIMSERVERCONVERSATIONID  @"56382c5500b0bf37d7832154"

#ifdef DEBUG
#define app_deviceProfile @"dev"
#define APIHOST         @"http://dev.lovewith.me"
#define AVOSAPPID       @"o8fvolewsx4ffj5gprqaavv1ukcbkyhbn109hgx8hgqw6v7x"
#define AVOSAPPKEY      @"o3h7p3peausargci68r2ojjidztcoyyzz07qkurtnezmcf8p"
#define AVOSMasterKey   @"0yvorexct7j8so4m9o145upuujz2qa1uaf0oasrfamjhdtzr"
#define HomePageBaseUrl [NSString stringWithFormat:@"%@%@",@"http://dev.lovewith.me/u/",[UserInfoManager instance].userId_self]
#define APIACCESSLOG    @"http://log.lovewith2.me/api/accesslog"
#define APIADSACESSLOG  @"http://log.lovewith2.me/api/ads/click"

#else
#define app_deviceProfile @"prod"
#define APIHOST         @"http://www.lovewith.me"
#define AVOSAPPID       @"43t6vt1te8ninrxsd6hgdibo8alsbuokhx1hnqyhvxac2im6"
#define AVOSAPPKEY      @"ye2dy8bvdpewi1801fb08veex59d1jvl8odf3q8g6soelzev"
#define HomePageBaseUrl [NSString stringWithFormat:@"%@%@",@"http://www.lovewith.me/u/",[UserInfoManager instance].userId_self]
#define APIACCESSLOG    @"http://log.lovewith.me/api/accesslog"
#define APIADSACESSLOG  @"http://log.lovewith2.me/api/ads/click"
#endif

#define kSupplierURL [NSString stringWithFormat:@"%@/su/",APIHOST]
#define kPostURL [NSString stringWithFormat:@"%@/share/detail/all/",APIHOST]
#define kHotelURL [NSString stringWithFormat:@"%@/hotel/detail/",APIHOST]
#define kTaobaoURL(ID) [NSString stringWithFormat:@"http://h5.m.taobao.com/awp/core/detail.htm?id=%@",ID]
#define kWedProcessURL(ID) [NSString stringWithFormat:@"%@/u/wedding/process/%@",APIHOST,ID]

/**************************************************************************************/


//错误信息打印头
#define ERRORDOMAIN                           @"LOVEWITH"

#define ERROR_NoresultCode                    404

//颜色
#define titleLableColor       [UIColor colorWithRed:67.0f/255.0f green:73.0f/255.0f blue:82.0f/255.0f alpha:1]//主标题颜色
#define subTitleLableColor    [UIColor colorWithRed:122.0f/255.0f green:128.0f/255.0f blue:137.0f/255.0f alpha:1]//副标题颜色

#define kServerID     @"16219"
#define kServerName   @"婚礼时光"
#define kServerAvatar @"http://mt-avatar.qiniudn.com/2016/01/20/1291cf8b273ff1f2c1200531a5a6921f.png"
#define kServerPhone  @"0571-86460120"

