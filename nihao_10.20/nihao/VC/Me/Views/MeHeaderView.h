//
//  MeHeaderView.h
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MineInfo;
@class MeHeaderView;

typedef NS_ENUM(NSUInteger, MeHeaderViewFollowType) {
	MeHeaderViewFollowTypeFollow = 0,
	MeHeaderViewFollowTypeFollower,
};

@protocol MeHeaderViewDelegate <NSObject>

- (void)meHeaderView:(MeHeaderView *)meHeaderView clickedFollowType:(MeHeaderViewFollowType)type;
- (void)meHeaderViewclickedHeaderIcon;
- (void)viewUserInfo;

@end

@interface MeHeaderView : UIView

- (void)configureMeHeaderViewWithMineInfo:(MineInfo *)mineInfo;

- (void) setNewFollowersCount : (NSUInteger) newFollowerCount;

@property (nonatomic, assign) id <MeHeaderViewDelegate> delegate;

@end
