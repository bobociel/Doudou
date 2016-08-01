//
//  LoginManager.h
//  lovewith
//
//  Created by imqiuhang on 15/4/7.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
   LoginModePhone  = 0,
   LoginModeWechat = 1,
   LoginModeQQ     = 2,
   LoginModeSina   = 3
}LoginMode;


@protocol LoginManagerDelegate <NSObject>

@optional

- (void)loginSucceed:(NSDictionary*)result;
- (void)loginFaild:(LoginMode)loginMode andErr:(NSString *)errInfo;

- (void)logoutSucceed;
- (void)logoutFaild:(NSString *)errInfo;

@end


@interface LoginManager : NSObject

@property (nonatomic,weak) id <LoginManagerDelegate> delegate;

- (void)loginWithPhone:(NSString *)phone andpassword:(NSString *)password;

+ (void)loginSucceedAfter:(NSDictionary *)result;

+ (void)logoutWithFinishBlock:(void(^)())finish;

+ (void)reblinding ;

+(void)pushToLoginViewControllerWithAnimation:(BOOL)anmation;
@end
