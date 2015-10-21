//
//  FollowUserCell.m
//  nihao
//
//  Created by HelloWorld on 6/11/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "FollowUserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "FollowUser.h"
#import "Constants.h"

@interface FollowUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNationalityLabel;
@property (weak, nonatomic) IBOutlet UIButton *followStatusBtn;

@end

@implementation FollowUserCell {
    NSIndexPath *currentIndexPath;
    FollowUser *currentUser;
}

- (void)initCellWithUser:(FollowUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndexPath = indexPath;
    currentUser = user;
    
    NSString *iconURLString =user.ci_header_img;
    NSString *userNameString = user.ci_nikename;
    NSString *userSexString = [NSString stringWithFormat:@"%d", user.ci_sex];
    NSString *userNationalityString = user.country_name_en;
    int friendType = user.friend_type;
    
    if (IsStringEmpty(iconURLString)) {
        if (IsStringEmpty(userSexString) || [@"0" isEqualToString:userSexString]) {
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
            }
        }];
    }
    
    if (IsStringEmpty(userNameString)) {
        self.userNameLabel.text = user.ci_phone;
    } else {
        self.userNameLabel.text = userNameString;
    }
    
    if (IsStringEmpty(userNationalityString)) {
        self.userNationalityLabel.text = @"Unknow Nationality";
    } else {
        self.userNationalityLabel.text = userNationalityString;
    }
//	NSLog(@"indexPath.row = %ld, friendType = %d", indexPath.row, friendType);
    if (friendType == UserFriendTypeFollowed) {
		self.followStatusBtn.highlighted = YES;
		self.followStatusBtn.selected = NO;
    } else if (friendType == UserFriendTypeFriend) {
		self.followStatusBtn.highlighted = NO;
		self.followStatusBtn.selected = YES;
	} else {
		self.followStatusBtn.highlighted = NO;
		self.followStatusBtn.selected = NO;
	}
}

- (IBAction)followBtnClick:(id)sender {
    if (self.followUser) {
        self.followUser(currentUser, currentIndexPath);
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
