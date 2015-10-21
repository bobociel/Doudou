//
//  UserInfoViewController.h
//  nihao
//
//  Created by 刘志 on 15/7/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, UserInfoFrom) {
	UserInfoFromChatList = 0, // Message 聊天列表
	UserInfoFromChat, // 单聊
	UserInfoFromHome, // 首页
};

@interface UserInfoViewController : BaseViewController

//用户id
@property (nonatomic, assign) NSInteger uid;

//用户名字
@property (nonatomic, copy) NSString *uname;

// 从哪个界面进入的
@property (nonatomic, assign) UserInfoFrom userInfoFrom;

@end
