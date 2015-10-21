//
//  TopUserCell.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TopUserCell.h"
#import "CheckBox.h"
#import "TopUser.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface TopUserCell () <CheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLikeCountLabel;
@property (weak, nonatomic) IBOutlet CheckBox *followUserCheckBox;
@property (weak, nonatomic) IBOutlet UIImageView *userSexImageView;

@end

@implementation TopUserCell {
    NSIndexPath *currentIndexPath;
}

- (void)configureCellWithUserInfo:(TopUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndexPath = indexPath;

    NSString *iconURLString = user.ci_header_img;
    NSString *userName = user.ci_nikename;
    
    if (IsStringEmpty(userName)) {
        self.userNameLabel.text = @"UnknowName";
    } else {
        self.userNameLabel.text = userName;
    }
	
	if (user.ci_sex == UserSexTypeFemale) {
		self.userSexImageView.image = [UIImage imageNamed:@"icon_female"];
	} else {
		self.userSexImageView.image = [UIImage imageNamed:@"icon_male"];
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
    
    self.userLikeCountLabel.text = [NSString stringWithFormat:@"%d", user.ca_score];
    
    if (user.friend_type == UserFriendTypeFollowed || user.friend_type == UserFriendTypeFriend) {
        [self.followUserCheckBox setSelectedWithoutDelegate:YES];
    } else {
        [self.followUserCheckBox setSelectedWithoutDelegate:NO];
    }
    
    self.followUserCheckBox.delegate = self;
}

- (void)checkBox:(CheckBox *)checkBox didChangedSelectedStatus:(BOOL)status {
    if (self.followUserForRowAtIndexPath) {
        self.followUserForRowAtIndexPath(currentIndexPath, status);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

@end
