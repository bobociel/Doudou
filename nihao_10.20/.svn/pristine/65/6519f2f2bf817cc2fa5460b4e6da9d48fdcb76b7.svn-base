//
//  LoginOrRegisterViewController.h
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//
//  Description: 登录/注册

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, LoginOrRegisterType) {
    LoginOrRegisterTypeLogin = 0,
    LoginOrRegisterTypeRegister,
//	LoginOrRegisterTypeForgotPWD,
};

@interface LoginOrRegisterViewController : BaseViewController

// 登录或者注册标记
@property(nonatomic,assign) LoginOrRegisterType loginOrRegisterType;
// 登录成功之后回调的 Block
@property (nonatomic, copy) void (^loginSucceed)(void);
// 注册成功之后回调的 Block
//@property (nonatomic, copy) void (^registerSucceed)(void);

@end
