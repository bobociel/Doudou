//
//  ServerManager.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/29.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHServerManager : NSObject

//login part
+ (void) requestCaptcha:(long long)mobile;
+ (void) verifyCaptcha:(NSString*)captcha mobile:(long long)mobile;
+ (void) signup:(long long)mobile userName:(NSString*)userName password:(NSString*)password;
+ (void) signin:(NSString*)username password:(NSString*)password;
+ (void) modifyPassword:(NSString*)password;
+ (void) logout;

//chat part
+ (void) schedulerMeeting;


//project page
+ (void) requestProjectsList;
+ (void) createProject;
+ (void) delProject;

+ (void) requestTasksList;
+ (void) createTask;
+ (void) delTask;

+ (void) requestActivitiesList;

+ (void) requestReviewsList;



//sns page


//mine page

@end
