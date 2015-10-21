//
//  ContractCell.m
//  nihoo
//
//  Created by 刘志 on 15/4/20.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "ContactCell.h"
#import "NihaoContact.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Constants.h"

@interface ContactCell()

@property (weak, nonatomic) IBOutlet UIImageView *userLogo;
@property (weak, nonatomic) IBOutlet UILabel *uname;
@property (weak, nonatomic) IBOutlet UIImageView *userSex;
@property (weak, nonatomic) IBOutlet UILabel *nation;
@property (weak, nonatomic) IBOutlet UILabel *city;

@end

@implementation ContactCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void) loadData : (NihaoContact *) contact {
    _uname.text = contact.ci_nikename;
    _nation.text = contact.country_name_en;
    _city.text = contact.city_name_en;
    UIImage *placeHolder;
    if(contact.ci_sex == UserSexTypeFemale) {
        _userSex.image = [UIImage imageNamed:@"icon_female"];
        placeHolder = [UIImage imageNamed:@"default_icon_female"];
    } else {
        _userSex.image = [UIImage imageNamed:@"icon_male"];
        placeHolder = [UIImage imageNamed:@"default_icon_male"];
    }
    [_userLogo sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:contact.ci_header_img]] placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(error) {
            _userLogo.image = placeHolder;
        } else {
            _userLogo.image = image;
        }
    }];
}

@end
