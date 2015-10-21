//
//  MeHeaderView.m
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MeHeaderView.h"
#import "MineInfo.h"
#import "Constants.h"
#import "BaseFunction.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomBadge.h"

@interface MeHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *aboveView;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userSexImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *userFollowCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFollowerCountLabel;
@property (weak, nonatomic) IBOutlet UIView *followersCountView;
@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexImageToLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexImageToBadgeImageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyImageToLabelConstraint;
- (IBAction)viewUserInfo:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *userRegionNotSetBadgeView;
@property (weak, nonatomic) IBOutlet UILabel *companyLable;


@end

@implementation MeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = (MeHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"MeHeaderView" owner:self options:nil][0];
		self.frame = frame;
		[self drawLines];
	}
	
	return self;
}

- (void)configureMeHeaderViewWithMineInfo:(MineInfo *)mineInfo {
	NSString *iconURLString = mineInfo.ci_header_img;
	NSString *userName = mineInfo.ci_nikename;
	
    
	if (IsStringEmpty(userName)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"nihao_%ld", (long)mineInfo.ci_id];
	} else {
		self.userNameLabel.text = userName;
	}
    
    if (mineInfo.ci_sex == UserSexTypeFemale) {
        self.userSexImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        self.userSexImageView.image = [UIImage imageNamed:@"icon_male"];
    }
    if(mineInfo.ci_type == Company) {
        _companyImageView.image = [UIImage imageNamed:@"icon_verified-head"];
        _companyLable.text = @"Verified";
    }else{
        _companyImageView.image = [UIImage imageNamed:@"icon_unverified-head"];
        _companyLable.text = @"Unverified";
    }
	
	if (IsStringEmpty(iconURLString)) {
		if (mineInfo.ci_sex == UserSexTypeFemale) {
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
    
    if(IsStringEmpty(mineInfo.ci_city_id)) {
        _userRegionNotSetBadgeView.hidden = NO;
        [BaseFunction setCornerRadius:4.0 view:_userRegionNotSetBadgeView];
    } else {
        _userRegionNotSetBadgeView.hidden = YES;
    }
	
	self.userFollowCountLabel.text = [NSString stringWithFormat:@"%ld", mineInfo.relationCount];
	self.userFollowerCountLabel.text = [NSString stringWithFormat:@"%ld", (long)mineInfo.byCount];
	
   	self.badgeImageView.hidden = !mineInfo.ci_is_verified;
	[self hasBadge:!self.badgeImageView.hidden];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerIconTapped:)];
	[self.userIconImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)drawLines {
	UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.aboveView.frame) - 0.5, SCREEN_WIDTH, 0.5)];
	line0.backgroundColor = SeparatorColor;
	[self.aboveView addSubview:line0];
	
	UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0, 9, 0.5, 32)];
	line1.backgroundColor = SeparatorColor;
	[self.bottomView addSubview:line1];
}

- (void)hasBadge:(BOOL)isVerified {
	if (isVerified) {
		self.sexImageToBadgeImageConstraint.priority = 999;
		self.sexImageToLabelConstraint.priority = 750;
	} else {
		self.sexImageToBadgeImageConstraint.priority = 750;
		self.sexImageToLabelConstraint.priority = 999;
	}
}

- (void) setNewFollowersCount:(NSUInteger)newFollowerCount {
    if(newFollowerCount == 0) {
        for(UIView *subView in _followersCountView.subviews) {
            [subView removeFromSuperview];
        }
    } else {
        NSString *badgeNum = (newFollowerCount > 99) ? @"99+" : [NSString stringWithFormat:@"%ld",(unsigned long)newFollowerCount];
        [_followersCountView addSubview:[CustomBadge customBadgeWithString:badgeNum]];
    }
}

#pragma mark - click events

- (void)headerIconTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
	if ([self.delegate respondsToSelector:@selector(meHeaderViewclickedHeaderIcon)]) {
		[self.delegate meHeaderViewclickedHeaderIcon];
	}
}

- (IBAction)followClick:(id)sender {
	if ([self.delegate respondsToSelector:@selector(meHeaderView:clickedFollowType:)]) {
		[self.delegate meHeaderView:self clickedFollowType:MeHeaderViewFollowTypeFollow];
	}
}

- (IBAction)followerClick:(id)sender {
	if ([self.delegate respondsToSelector:@selector(meHeaderView:clickedFollowType:)]) {
		[self.delegate meHeaderView:self clickedFollowType:MeHeaderViewFollowTypeFollower];
	}
}

- (IBAction)viewUserInfo:(id)sender {
    if(_delegate) {
        [_delegate viewUserInfo];
    }
}

@end
