//
//  UserFollowListCell.m
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "UserFollowListCell.h"
#import "FollowUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "BaseFunction.h"
#import "AppConfigure.h"

@interface UserFollowListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userSexImageView;

@end

@implementation UserFollowListCell {
	NSIndexPath *currentIndexPath;
}

- (void)configureCellWithUserInfo:(FollowUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath withUserFollowListType:(UserFollowListType)type withOwnerUserID:(NSString *)ownerUserID {
	currentIndexPath = indexPath;
	
	NSString *iconURLString = user.ci_header_img;
	NSString *userName = user.ci_nikename;
	
	if (IsStringEmpty(userName)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"nihao_%d", user.ci_id];
	} else {
		self.userNameLabel.text = userName;
	}
	
	if (IsStringEmpty(iconURLString)) {
		if (user.ci_sex == UserSexTypeFemale) {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_female"];
		} else {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_male"];
		}
	} else {
		[self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (!error) {
				self.userIconImageView.image = image;
			} else {
				self.userIconImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
				NSLog(@"imageURL = %@", imageURL);
			}
		}];
	}
	
	if (user.ci_sex == UserSexTypeFemale) {
		self.userSexImageView.image = [UIImage imageNamed:@"icon_female"];
	} else {
		self.userSexImageView.image = [UIImage imageNamed:@"icon_male"];
	}
	
	if (IsStringNotEmpty(user.country_name_en)) {
		self.userCountryLabel.hidden = NO;
		self.userCountryLabel.text = user.country_name_en;
	} else {
		self.userCountryLabel.hidden = YES;
	}
	
	if (IsStringNotEmpty(user.city_name_en)) {
		self.userLocationLabel.hidden = NO;
		self.userLocationLabel.text = user.city_name_en;
	} else {
		self.userLocationLabel.hidden = YES;
	}
	
	NSString *userID = [NSString stringWithFormat:@"%d", user.ci_id];
	NSString *myUserID = [AppConfigure objectForKey:LOGINED_USER_ID];
	
	if ([userID isEqualToString:myUserID]) {
		self.followBtn.hidden = YES;
	} else {
		self.followBtn.hidden = NO;
	}
	
	if (user.friend_type == UserFriendTypeFriend) {
		[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_followed_each_other"] forState:UIControlStateNormal];
	} else if (user.friend_type == UserFriendTypeFollowed) {
		[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_followed"] forState:UIControlStateNormal];
	} else {
		[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_follow"] forState:UIControlStateNormal];
	}
	
//	if (type == UserFollowListTypeFollow && ([userID isEqualToString:myUserID] || [ownerUserID isEqualToString:myUserID])) {
////		self.followBtn.hidden = YES;
//		if (user.friend_type == UserFriendTypeFriend) {
//			[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_followed_each_other"] forState:UIControlStateNormal];
//		} else if (user.friend_type == UserFriendTypeFollowed) {
//			[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_followed"] forState:UIControlStateNormal];
//		}
//	} else {
////		self.followBtn.hidden = NO;
//		if (user.friend_type == UserFriendTypeFriend || user.friend_type == UserFriendTypeFollowed) {
//			[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_followed_each_other"] forState:UIControlStateNormal];
//		} else {
//			[self.followBtn setBackgroundImage:[UIImage imageNamed:@"icon_user_follow"] forState:UIControlStateNormal];
//		}
//	}
}

- (IBAction)followBtnClick:(id)sender {
	if ([self.delegate respondsToSelector:@selector(userFollowListCellClickFollowBtnAtIndexPath:)]) {
		[self.delegate userFollowListCellClickFollowBtnAtIndexPath:currentIndexPath];
	}
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
