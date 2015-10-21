//
//  PostDetailHeaderView.h
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserPost;

@interface PostDetailHeaderView : UIView

- (void)configureHeaderViewWithPostInfo:(UserPost *)post;

- (void)refreshHeaderViewWithFriendType:(NSInteger)friendType;

// 点击删除按钮Block
@property (nonatomic,copy) void(^deletePost)();

// 点击关注对方Block
@property (nonatomic,copy) void(^followUser)();

//查看用户信息
@property (nonatomic,copy) void(^viewUserInfo)();

@end
