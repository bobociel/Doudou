//
//  TopUserHeaderView.m
//  nihao
//
//  Created by HelloWorld on 6/16/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TopUserHeaderView.h"
#import "CheckBox.h"
#import "Constants.h"
#import "TopUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "UserInfoViewController.h"

#define USER_FIRST_FOLLOW_BTN_TAG 100
#define USER_SECOND_FOLLOW_BTN_TAG 101
#define USER_THIRD_FOLLOW_BTN_TAG 102

@interface TopUserHeaderView () <CheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UIView *topOneView;
@property (weak, nonatomic) IBOutlet UIView *topTwoView;
@property (weak, nonatomic) IBOutlet UIView *topThirdView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIImageView *topUserOneIcon;
@property (weak, nonatomic) IBOutlet UILabel *topUserOneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topUserOneLikeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topUserTwoIcon;
@property (weak, nonatomic) IBOutlet UILabel *topUserTwoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topUserTwoLikeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topUserThirdIcon;
@property (weak, nonatomic) IBOutlet UILabel *topUserThirdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topUserThirdLikeCountLabel;
@property (weak, nonatomic) IBOutlet CheckBox *topUserOneFollowBtn;
@property (weak, nonatomic) IBOutlet CheckBox *topUserTwoFollowBtn;
@property (weak, nonatomic) IBOutlet CheckBox *topUserThirdFollowBtn;
@property (weak, nonatomic) IBOutlet UIImageView *topUserOneSexIV;
@property (weak, nonatomic) IBOutlet UIImageView *topUserSecondSexIV;
@property (weak, nonatomic) IBOutlet UIImageView *topUserThirdSexIV;

- (IBAction)topOneTapped:(id)sender;
- (IBAction)topTwoTapped:(id)sender;
- (IBAction)topThreeTapped:(id)sender;

@end

@implementation TopUserHeaderView {
    NSArray *userIconImageViews;
    NSArray *userNameLabels;
    NSArray *userLikeCntLabels;
    NSArray *userFollowedBtns;
    NSArray *headerUsers;
	NSArray *userViews;
	NSArray *userSexImageViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = (TopUserHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"TopUserHeaderView" owner:self options:nil][0];
        self.frame = frame;
        self.backgroundColor = RootBackgroundColor;
        self.topUserOneFollowBtn.tag = USER_FIRST_FOLLOW_BTN_TAG;
        self.topUserTwoFollowBtn.tag = USER_SECOND_FOLLOW_BTN_TAG;
        self.topUserThirdFollowBtn.tag = USER_THIRD_FOLLOW_BTN_TAG;
        self.topUserOneFollowBtn.delegate = self;
        self.topUserTwoFollowBtn.delegate = self;
        self.topUserThirdFollowBtn.delegate = self;
    }
    
    return self;
}

- (void)configureHeaderViewWithUsersInfo:(NSArray *)users {
    headerUsers = users;
    userIconImageViews = @[self.topUserOneIcon, self.topUserTwoIcon, self.topUserThirdIcon];
    userNameLabels = @[self.topUserOneNameLabel, self.topUserTwoNameLabel, self.topUserThirdNameLabel];
    userLikeCntLabels = @[self.topUserOneLikeCountLabel, self.topUserTwoLikeCountLabel, self.topUserThirdLikeCountLabel];
    userFollowedBtns = @[self.topUserOneFollowBtn, self.topUserTwoFollowBtn, self.topUserThirdFollowBtn];
	userViews = @[self.topOneView, self.topTwoView, self.topThirdView];
	userSexImageViews = @[self.topUserOneSexIV, self.topUserSecondSexIV, self.topUserThirdSexIV];
	
	if (users.count < 2) {
		self.rightView.hidden = YES;
	}
    
    for (int i = 0; i < users.count; i++) {
        TopUser *user = users[i];
        UIImageView *userIconIV = userIconImageViews[i];
        UILabel *userNameLabel = userNameLabels[i];
        UILabel *userLikeCntLabel = userLikeCntLabels[i];
        CheckBox *userFollowBtn = userFollowedBtns[i];
		UIImageView *userSexImageView = userSexImageViews[i];
		
		UIView *userView = userViews[i];
		userView.hidden = NO;
        
        NSString *iconURLString = user.ci_header_img;
        NSString *userName = user.ci_nikename;
        
        if (IsStringEmpty(user.ci_nikename)) {
            userNameLabel.text = @"UnknowName";
        } else {
            userNameLabel.text = userName;
        }
		
		if (user.ci_sex == UserSexTypeFemale) {
			userSexImageView.image = [UIImage imageNamed:@"icon_female"];
		} else {
			userSexImageView.image = [UIImage imageNamed:@"icon_male"];
		}
        
        if (IsStringEmpty(iconURLString)) {
            if (user.ci_sex == UserSexTypeFemale) {
                userIconIV.image = [UIImage imageNamed:@"default_icon_female"];
            } else {
                userIconIV.image = [UIImage imageNamed:@"default_icon_male"];
            }
        } else {
            [userIconIV sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    userIconIV.image = image;
                } else {
                    userIconIV.image = [UIImage imageNamed:@"img_is_load_failed"];
                    NSLog(@"imageURL = %@", imageURL);
                }
            }];
        }
        
        userLikeCntLabel.text = [NSString stringWithFormat:@"%d", user.ca_score];
        
        if (user.friend_type == UserFriendTypeFollowed || user.friend_type == UserFriendTypeFriend) {
            [userFollowBtn setSelectedWithoutDelegate:YES];
        } else {
            [userFollowBtn setSelectedWithoutDelegate:NO];
        }
    }
}

- (void)checkBox:(CheckBox *)checkBox didChangedSelectedStatus:(BOOL)status {
    NSInteger userIndex = 0;
    
    switch (checkBox.tag) {
        case USER_FIRST_FOLLOW_BTN_TAG:
            userIndex = 0;
            break;
        case USER_SECOND_FOLLOW_BTN_TAG:
            userIndex = 1;
            break;
        case USER_THIRD_FOLLOW_BTN_TAG:
            userIndex = 2;
            break;
    }
    
    if (self.followUserForRowAtIndexPath) {
        self.followUserForRowAtIndexPath(userIndex, status);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)topOneTapped:(id)sender {
    [self viewUserInfo:headerUsers[0]];
}

- (IBAction)topTwoTapped:(id)sender {
    [self viewUserInfo:headerUsers[1]];
}

- (IBAction)topThreeTapped:(id)sender {
    [self viewUserInfo:headerUsers[2]];
}

- (void) viewUserInfo : (TopUser *) user {
    UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    controller.uid = user.ca_ci_id;
    controller.uname = user.ci_nikename;
    [_navigationController pushViewController:controller animated:YES];
}
@end
