//
//  UserInfoHeader.h
//  nihao
//
//  Created by 刘志 on 15/8/25.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoHeaderClickDelegate <NSObject>

- (void) followingTouched;

- (void) followersTouched;

- (void) userLogoTouched;

- (void) userBaseInfoTouched;

@end

@interface UserInfoHeader : UIView

- (void) configureUserInfo : (NSDictionary *) userInfo;

- (void) setFollowersCount : (NSInteger) followerCount;

@property (nonatomic,weak) id<UserInfoHeaderClickDelegate> delegate;

@end
