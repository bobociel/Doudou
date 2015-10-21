//
//  RecommendUserCell.m
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "RecommendUserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface RecommendUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isFellowed;

@end

@implementation RecommendUserCell

- (void)initCellWithUserInfo:(NSDictionary *)info {
    NSString *iconURLString = [info objectForKey:@"ci_header_img"];
    NSString *userNameString = [info objectForKey:@"ci_nikename"];
    NSString *userSexString = [info objectForKey:@"ci_sex"];
    
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
    
//    self.userIconImageView.image = [UIImage imageNamed:[info objectForKey:@"user_icon_url"]];
    if (IsStringEmpty(userNameString)) {
        self.userNameLabel.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"ci_phone"]];
    } else {
        self.userNameLabel.text = userNameString;
    }
    
    self.isFellowed.hidden = [[info objectForKey:IS_USER_SELECTED] isEqualToString:@"YES"] ? NO : YES;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
