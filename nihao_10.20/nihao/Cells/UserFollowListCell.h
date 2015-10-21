//
//  UserFollowListCell.h
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FollowUser;

typedef NS_ENUM(NSUInteger, UserFollowListType) {
	UserFollowListTypeFollow = 0,
	UserFollowListTypeFollower,
};

@protocol UserFollowListCellDelegate <NSObject>

- (void)userFollowListCellClickFollowBtnAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UserFollowListCell : UITableViewCell

- (void)configureCellWithUserInfo:(FollowUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath withUserFollowListType:(UserFollowListType)type withOwnerUserID:(NSString *)ownerUserID;

@property (nonatomic, assign) id <UserFollowListCellDelegate> delegate;

@end
