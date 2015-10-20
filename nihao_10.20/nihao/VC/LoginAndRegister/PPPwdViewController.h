//
//  PPPwdViewController.h
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//
//  Description: 完善用户头像、用户名、性别

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, SetPasswordFromType) {
	SetPasswordFromTypeRegister = 0,
	SetPasswordFromTypeForgotPWD,
};

@interface PPPwdViewController : BaseViewController

// 从注册界面传递过来的用户信息
//@property (nonatomic) NSMutableDictionary *userRegisterInfo;
@property (nonatomic, assign) SetPasswordFromType setPasswordFromType;

@end
