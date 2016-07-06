//
//  ServerManager.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/29.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHServerManager.h"
#import "AFNetworking.h"

#define REQMGR				([AFHTTPRequestOperationManager manager])
#define BASE_URL			@"http://192.168.1.108:5000/"
#define COMBINE_URL(url)	[BASE_URL stringByAppendingString:url]

#define REQ_CAP_URL			COMBINE_URL(@"request_captcha")
#define VERIFY_CAP_URL		COMBINE_URL(@"verify_captcha")
#define SIGN_UP_URL         COMBINE_URL(@"sign_up")
#define SIGN_IN_URL         COMBINE_URL(@"sign_in")
#define LOGIN_URL			COMBINE_URL(@"login")
#define MODIFY_PWD_URL      COMBINE_URL(@"modify_password")
#define LOGOUT_URL          COMBINE_URL(@"logout")

@implementation YHServerManager

+ (void) requestCaptcha:(long long)mobile
{
    [REQMGR POST:REQ_CAP_URL parameters:@{@"phone":@(mobile)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"requestCaptcha succeed,%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"requestCaptcha failed");
    }];
}

+ (void) verifyCaptcha:(NSString*)captcha mobile:(long long)mobile
{
    [REQMGR POST:VERIFY_CAP_URL parameters:@{@"phone":@(mobile),@"captcha":captcha} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"verifyCaptcha succeed,%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"verifyCaptcha failed");
    }];
}

+ (void) signup:(long long)mobile userName:(NSString*)userName password:(NSString*)password
{
    [REQMGR POST:SIGN_UP_URL parameters:@{@"username":userName,@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"signup succeed,%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"signup failed");
    }];
}

+ (void) signin:(NSString*)username password:(NSString*)password
{
	[REQMGR POST:SIGN_IN_URL parameters:@{@"username":username,@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"signin succeed,%@",responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"signin failed");
	}];
}

+ (void) modifyPassword:(NSString*)password
{
    [REQMGR POST:MODIFY_PWD_URL parameters:@{@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"modifyPassword succeed,%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"modifyPassword failed");
    }];
}

+ (void) logout
{
    [REQMGR POST:LOGOUT_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"logout succeed,%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"logout failed");
    }];
}

@end
