//
//  AppConfigure.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AppConfigure.h"

@implementation AppConfigure

#pragma mark - get set
//get方法
//object
+ (id)objectForKey:(NSString *)key {
    return [UserDefaults objectForKey:key];
}

//value
+ (NSString *)valueForKey:(NSString *)key {
    return [UserDefaults valueForKey:key] ? [UserDefaults valueForKey:key] : @"";
}

// float
+ (float)floatForKey:(NSString *)key {
    return [UserDefaults floatForKey:key];
}

//int
+ (NSInteger)integerForKey:(NSString *)key {
    return [UserDefaults integerForKey:key];
}

//bool
+ (BOOL)boolForKey:(NSString *)key {
    return [UserDefaults boolForKey:key];
}

//set方法
//object
+ (void)setObject:(id)value ForKey:(NSString *)key {
    [UserDefaults setObject:value forKey:key];
}

//value
+ (void)setValue:(id)value forKey:(NSString *)key {
    [UserDefaults setValue:value forKey:key];
}

// float
+ (void)setFloat:(float)value forKey:(NSString *)key {
    [UserDefaults setFloat:value forKey:key];
}

//int
+ (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [UserDefaults setInteger:value forKey:key];
}

//bool
+ (void)setBool:(BOOL)value forKey:(NSString *)key {
    [UserDefaults setBool:value forKey:key];
}

+ (NSDictionary *)loginUserProfile {
	NSMutableDictionary *myProfile = [[NSMutableDictionary alloc] init];
	
	[myProfile setObject:[self valueForKey:LOGINED_USER_ID] forKey:LOGINED_USER_ID];
	[myProfile setObject:[self valueForKey:LOGINED_USER_ICON_URL] forKey:LOGINED_USER_ICON_URL];
	[myProfile setObject:[self valueForKey:LOGINED_USER_AGE] forKey:LOGINED_USER_AGE];
	[myProfile setObject:[self valueForKey:LOGINED_USER_SEX] forKey:LOGINED_USER_SEX];
	[myProfile setObject:[self valueForKey:LOGINED_USER_NAME] forKey:LOGINED_USER_NAME];
	[myProfile setObject:[self valueForKey:LOGINED_USER_PHONE] forKey:LOGINED_USER_PHONE];
	[myProfile setObject:[self valueForKey:LOGINED_USER_CITY_ID] forKey:LOGINED_USER_CITY_ID];
	[myProfile setObject:[self valueForKey:LOGINED_USER_CITY_NAME_EN] forKey:LOGINED_USER_CITY_NAME_EN];
	[myProfile setObject:[self valueForKey:LOGINED_USER_NICKNAME] forKey:LOGINED_USER_NICKNAME];
	[myProfile setObject:[self valueForKey:LOGINED_USER_COUNTRY_ID] forKey:LOGINED_USER_COUNTRY_ID];
	[myProfile setObject:[self valueForKey:LOGINED_USER_COUNTRY_NAME_EN] forKey:LOGINED_USER_COUNTRY_NAME_EN];
	[myProfile setObject:[self valueForKey:LOGINED_USER_JOB] forKey:LOGINED_USER_JOB];
	[myProfile setObject:[self valueForKey:LOGINED_USER_HOBBIES] forKey:LOGINED_USER_HOBBIES];
	[myProfile setObject:[self valueForKey:LOGINED_USER_IS_VERIFIED] forKey:LOGINED_USER_IS_VERIFIED];
	[myProfile setObject:[self valueForKey:LOGINED_USER_BIRTHDAY] forKey:LOGINED_USER_BIRTHDAY];
	
	return myProfile;
}

+ (void)saveUserProfile:(NSDictionary *)userProfile {
	// 保存前先清除掉之前保存的登录的用户信息
	[AppConfigure clearLoginUserProfile];
	
	for (NSString *key in [userProfile allKeys]) {
		NSString *value = [NSString stringWithFormat:@"%@", userProfile[key]];
		[AppConfigure setValue:value forKey:key];
	}
}

+ (void)saveRegisterUserProfile:(NSDictionary *)userProfile {
	[AppConfigure setObject:userProfile[REGISTER_USER_ID] ForKey:REGISTER_USER_ID];
	[AppConfigure setObject:userProfile[REGISTER_USER_NICKNAME] ForKey:REGISTER_USER_NICKNAME];
	[AppConfigure setObject:userProfile[REGISTER_USER_PHONE] ForKey:REGISTER_USER_PHONE];
	[AppConfigure setObject:userProfile[REGISTER_USER_SEX] ForKey:REGISTER_USER_SEX];
	[AppConfigure setObject:userProfile[REGISTER_USER_USERNAME] ForKey:REGISTER_USER_USERNAME];
}

+ (void)clearLoginUserProfile {
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_NICKNAME];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_AGE];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_CITY_ID];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_COUNTRY_ID];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_CITY_NAME_EN];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_COUNTRY_NAME_EN];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_ICON_URL];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_ID];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_PHONE];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_SEX];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_NAME];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_JOB];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_HOBBIES];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_IS_VERIFIED];
	[AppConfigure setObject:@"" ForKey:LOGINED_USER_BIRTHDAY];
}

@end