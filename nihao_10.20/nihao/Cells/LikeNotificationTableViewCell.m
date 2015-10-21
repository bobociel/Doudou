//
//  LikeNotificationTableViewCell.m
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "LikeNotificationTableViewCell.h"
#import "LikeNotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface LikeNotificationTableViewCell() {
    NSIndexPath *_indexPath;
}
@property (weak, nonatomic) IBOutlet UIImageView *userLogoImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *postDetailView;

@end

@implementation LikeNotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userLogoTapped:)];
    recognizer.numberOfTapsRequired = 1;
    _userLogoImage.userInteractionEnabled = YES;
    [_userLogoImage addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureLikeNotification:(LikeNotification *)notification indexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    
    [_userLogoImage sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:notification.ci_header_img]] placeholderImage:ImageNamed(@"img_register_upload_photo") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error) {
            _userLogoImage.image = image;
        } else {
            _userLogoImage.image = ImageNamed(@"img_register_upload_photo");
        }
    }];
    
    NSString *nickName = IsStringEmpty(notification.ci_nikename) ? notification.ci_username : notification.ci_nikename;
    _userNameLabel.text = nickName;
    
    _likeTimeLabel.text = notification.pii_date;
    
    for(UIView *subView in _postDetailView.subviews) {
        [subView removeFromSuperview];
    }
    
    if(!IsStringEmpty(notification.picture_small_network_url)) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_postDetailView.bounds];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:notification.picture_small_network_url]] placeholderImage:ImageNamed(@"img_is_loading") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(!error) {
                imageView.image = image;
            } else {
                imageView.image = ImageNamed(@"img_is_loading");
            }
        }];
        [_postDetailView addSubview:imageView];
    } else {
        UITextView *textView = [[UITextView alloc] initWithFrame:_postDetailView.bounds];
        textView.font = FontNeveLightWithSize(12.0);
        textView.textColor = ColorWithRGB(120, 120, 120);
        textView.text = notification.cd_info;
        textView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
        textView.userInteractionEnabled = NO;
        textView.backgroundColor = ColorWithRGB(244, 244, 244);
        [_postDetailView addSubview:textView];
    }
    
}

- (void) userLogoTapped : (UITapGestureRecognizer *) recognizer {
    if([_delegate respondsToSelector:@selector(userLogoTapped:)]) {
        [_delegate userLogoTapped:_indexPath];
    }
}

@end
