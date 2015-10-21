//
//  UserInfoHeader.m
//  nihao
//
//  Created by 刘志 on 15/8/25.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "UserInfoHeader.h"
#import "NihaoContact.h"
#import "BaseFunction.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

@interface UserInfoHeader()

- (IBAction)followingTouched:(id)sender;
- (IBAction)followersTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *followInfoView;
@property (weak, nonatomic) IBOutlet UIView *baseInfoView;

@property (weak, nonatomic) IBOutlet UILabel *followingNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followingViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followersViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelWidthConstraint;

@end

@implementation UserInfoHeader

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"UserInfoHeader" owner:self options:nil];
        for(NSObject *obj in objs) {
            if([obj isKindOfClass:[UserInfoHeader class]]) {
                self = (UserInfoHeader *) obj;
                break;
            }
        }
        self.frame = frame;
         [self addSeperatorLine];
    }
    return self;
}

- (void) configureUserInfo:(NSDictionary *)responseObject {
    
    NSDictionary *result = responseObject[@"result"];
    NSInteger followCount = [result[@"relationCount"] integerValue];
    NSInteger followerCount = [result[@"byCount"] integerValue];
    [self setFollowCount:followCount followerCount:followerCount];
    
    NSString *iconURLString = result[@"ci_header_img"];
    // 用户头像
    if (IsStringEmpty(iconURLString)) {
        if ([result[@"ci_sex"] integerValue] == UserSexTypeFemale) {
            _userLogoImageView.image = [UIImage imageNamed:@"default_icon_female"];
        } else {
            _userLogoImageView.image = [UIImage imageNamed:@"default_icon_male"];
        }
    } else {
        NSString *logoUrl = [BaseFunction convertServerImageURLToURLString:iconURLString];
        [_userLogoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                _userLogoImageView.image = image;
            } else {
                _userLogoImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
            }
        }];
    }
    
    UITapGestureRecognizer *baseInfoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userBaseInfoTouched)];
    baseInfoRecognizer.numberOfTapsRequired = 1;
    _baseInfoView.userInteractionEnabled = YES;
    [_baseInfoView addGestureRecognizer:baseInfoRecognizer];
    
    //用户头像添加点击事件
    UITapGestureRecognizer *userLogoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userHeaderViewclickedHeaderIcon)];
    userLogoRecognizer.numberOfTapsRequired = 1;
    _userLogoImageView.userInteractionEnabled = YES;
    [_userLogoImageView addGestureRecognizer:userLogoRecognizer];
    
    //用户名
    _nicknameLabel.text = result[@"ci_nikename"];
    [_nicknameLabel sizeToFit];
    _nicknameLabelWidthConstraint.constant = CGRectGetWidth(_nicknameLabel.frame);
    
    //性别
    NSString *sexImageName = [result[@"ci_sex"] integerValue] == UserSexTypeFemale ? @"icon_female" : @"icon_male";
    _sexImageView.image = ImageNamed(sexImageName);
    _sexImageView.hidden = NO;
    
    //是否是企业用户
    if([result[@"ci_type"] integerValue] == Company) {
        _companyImageView.hidden = YES;
        _sexImageView.hidden = YES;
    } else {
        _companyImageView.hidden = YES;
    }
}

- (void) addSeperatorLine {
    //在关注和被关注之间添加一条竖线
    UIView *middleSeperator = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 0.5, (CGRectGetHeight(_followInfoView.frame) - 32) / 2, 0.5, 32)];
    middleSeperator.backgroundColor = ColorWithRGB(230, 230, 230);
    [_followInfoView addSubview:middleSeperator];

    //在用户基本信息和关注信息底部添加分割线
    NSArray *views = @[_followInfoView,_baseInfoView];
    for(UIView *view in views) {
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 0.5, SCREEN_WIDTH, 0.5)];
        seperator.backgroundColor = ColorWithRGB(230, 230, 230);
        [view addSubview:seperator];
    }
}

/**
 *  测试follower和followed文字显示
 */
- (void) setFollowCount : (NSInteger) followCount followerCount : (NSInteger) followerCount {
    CGSize followSize = [BaseFunction labelSizeWithText:[NSString stringWithFormat:@"%ld",(long)followCount] font:FontNeveLightWithSize(26.0)];
    CGSize originSize = _followingNumLabel.frame.size;
    _followingViewWidthConstraint.constant = _followingViewWidthConstraint.constant + (followSize.width - originSize.width);
    _followingNumLabel.text = [NSString stringWithFormat:@"%ld",(long)followCount];
    
    CGSize followerSize = [BaseFunction labelSizeWithText:[NSString stringWithFormat:@"%ld",(long)followerCount] font:FontNeveLightWithSize(26.0)];
    CGSize originFollowerSize = _followersNumLabel.frame.size;
    _followersViewWidthConstraint.constant = _followersViewWidthConstraint.constant + (followerSize.width - originFollowerSize.width);
    _followersNumLabel.text = [NSString stringWithFormat:@"%ld",(long)followerCount];
}

- (void) setFollowersCount:(NSInteger)followerCount {
    CGSize followerSize = [BaseFunction labelSizeWithText:[NSString stringWithFormat:@"%ld",(long)followerCount] font:FontNeveLightWithSize(26.0)];
    CGSize originFollowerSize = _followersNumLabel.frame.size;
    _followersViewWidthConstraint.constant = _followersViewWidthConstraint.constant + (followerSize.width - originFollowerSize.width);
    _followersNumLabel.text = [NSString stringWithFormat:@"%ld",(long)followerCount];
}

- (IBAction)followingTouched:(id)sender {
    if([_delegate respondsToSelector:@selector(followingTouched)]) {
        [_delegate followingTouched];
    }
}

- (IBAction)followersTouched:(id)sender {
    if([_delegate respondsToSelector:@selector(followersTouched)]) {
        [_delegate followersTouched];
    }
}

- (void) userHeaderViewclickedHeaderIcon {
    if([_delegate respondsToSelector:@selector(userLogoTouched)]) {
        [_delegate userLogoTouched];
    }
}

- (void) userBaseInfoTouched {
    if([_delegate respondsToSelector:@selector(userBaseInfoTouched)]) {
        [_delegate userBaseInfoTouched];
    }
}

@end
