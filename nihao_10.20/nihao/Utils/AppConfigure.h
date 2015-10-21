//
//  AppConfigure.h
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

// 当前APP版本
#define CURRENT_APP_VERSION       1.0
// 用户第一次安装APP展示引导页的APP版本
#define LAST_SHOW_GUIDE_VERSION @"LAST_SHOW_GUIDE_VERSION"
// 用户是否已经登录
#define IS_LOGINED @"IS_LOGINED"

//当前用户选择的城市
#define CURRENT_CITY @"current_city"
//当前app定位城市
#define LOCATE_CITY @"locate_city"
//app默认服务城市
#define DEFAULT_CITY @"default_city"
//城市列表
#define CITY_LIST @"city_list"

/* 保存登录用户信息 */
//用户名
#define LOGINED_USER_NAME @"ci_username"
// 用户昵称
#define LOGINED_USER_NICKNAME @"ci_nikename"
// 用户年龄
#define LOGINED_USER_AGE @"ci_age"
// 用户居住城市id
#define LOGINED_USER_CITY_ID @"ci_city_id"
// 用户居住城市
#define LOGINED_USER_CITY_NAME_EN @"city_name_en"
// 用户国籍id
#define LOGINED_USER_COUNTRY_ID @"ci_country_id"
// 用户头像url地址(可能为空)
#define LOGINED_USER_ICON_URL @"ci_header_img"
// 用户id
#define LOGINED_USER_ID @"ci_id"
// 用户手机号码
#define LOGINED_USER_PHONE @"ci_phone"
// 用户性别
#define LOGINED_USER_SEX @"ci_sex"
// 用户是否认证
#define LOGINED_USER_IS_VERIFIED @"ci_is_verified"
// 用户关注的人数
#define LOGINED_USER_RELATION_COUNT @"relationCount"
// 关注用户的人数
#define LOGINED_USER_BY_COUNT @"byCount"
// 用户的国籍
#define LOGINED_USER_COUNTRY_NAME_EN @"country_name_en"
// 用户的工作
#define LOGINED_USER_JOB @"ci_job"
// 用户的爱好
#define LOGINED_USER_HOBBIES @"ci_hobbies"
// 用户的生日
#define LOGINED_USER_BIRTHDAY @"ci_birthday"
// 用户的邮箱
#define LOGINED_USER_EMAIL @"ci_email"

/* 保存注册用户信息 */
#define REGISTER_USER_ID @"ci_id"
#define REGISTER_USER_PWD @"ci_login_password"
#define REGISTER_USER_NICKNAME @"ci_nikename"
#define REGISTER_USER_ICON_URL @"ci_header_img"
#define REGISTER_USER_PHONE @"ci_phone"
#define REGISTER_USER_SEX @"ci_sex"
#define REGISTER_USER_USERNAME @"ci_username"
#define REGISTER_USER_LATITUDE @"user_latitude"
#define REGISTER_USER_LONGITUDE @"user_longitude"
#define REGISTER_USER_CITY_ID @"ci_city_id"
#define REGISTER_USER_CITY_NAME @"city_name_en"
#define REGISTER_USER_COUNTRY_ID @"ci_country_id"
#define REGISTER_USER_COUNTRY_NAME @"country_name_en"
#define REGISTER_USER_BIRTHDAY @"ci_birthday"

// Me界面是否需要刷新
#define ME_SHOULD_REFRESH @"me_should_refresh"

#define DEVICE_TOKENS @"device_tokens"

//服务端返回的ssid，加密使用
#define SSID @"ssid"

@interface AppConfigure : NSObject

+ (id)objectForKey:(NSString *)key;
+ (NSString *)valueForKey:(NSString *)key;
+ (float)floatForKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;
+ (void)setObject:(id)value ForKey:(NSString *)key;
+ (void)setValue:(id)value forKey:(NSString *)key;
+ (void)setFloat:(float)value forKey:(NSString *)key;
+ (void)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (void)setBool:(BOOL)value forKey:(NSString *)key;

/**
 *  获取当前登录的用户信息
 *
 *  @return  用户信息
 */
+ (NSDictionary *)loginUserProfile;

/**
 *  保存用户信息
 *
 *  @param userProfile 用户信息
 */
+ (void)saveUserProfile:(NSDictionary *)userProfile;

/**
 *  保存当前注册的用户信息
 *
 *  @param userProfile  用户信息
 */
+ (void)saveRegisterUserProfile:(NSDictionary *)userProfile;

/**
 *  清除登录的用户信息
 */
+ (void)clearLoginUserProfile;

@end
