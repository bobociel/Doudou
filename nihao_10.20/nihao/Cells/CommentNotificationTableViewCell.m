//
//  CommentNotificationTableViewCell.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "CommentNotificationTableViewCell.h"
#import "CommentNotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface CommentNotificationTableViewCell () {
    NSIndexPath *_indexPath;
}

@property (weak, nonatomic) IBOutlet UIImageView *userLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *commentCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeLabel;

@end

@implementation CommentNotificationTableViewCell

- (void)awakeFromNib {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userLogoTapped:)];
    recognizer.numberOfTapsRequired = 1;
    _userLogoImageView.userInteractionEnabled = YES;
    [_userLogoImageView addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureCell:(CommentNotification *)notification indexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    
    [_userLogoImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:notification.ci_header_img]] placeholderImage:ImageNamed(@"img_register_upload_photo") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error) {
            _userLogoImageView.image = image;
        } else {
            _userLogoImageView.image = ImageNamed(@"img_register_upload_photo");
        }
    }];
    
    NSString *nickName = IsStringEmpty(notification.ci_nikename) ? notification.ci_username : notification.ci_nikename;
    _userNameLabel.text = nickName;
    
    _commentTimeLabel.text = notification.cmi_date;
    
    _commentCommentLabel.text = notification.cmi_info;
    
    for(UIView *subView in _commentView.subviews) {
        [subView removeFromSuperview];
    }
    
    if(!IsStringEmpty(notification.picture_small_network_url)) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_commentView.bounds];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:notification.picture_small_network_url]] placeholderImage:ImageNamed(@"img_is_loading") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(!error) {
                imageView.image = image;
            } else {
                imageView.image = ImageNamed(@"img_is_loading");
            }
        }];
        [_commentView addSubview:imageView];
    } else {
        UITextView *textView = [[UITextView alloc] initWithFrame:_commentView.bounds];
        textView.font = FontNeveLightWithSize(12.0);
        textView.textColor = ColorWithRGB(120, 120, 120);
        textView.text = notification.cd_info;
        textView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
        textView.userInteractionEnabled = NO;
        textView.backgroundColor = ColorWithRGB(244, 244, 244);
        [_commentView addSubview:textView];
    }
}

- (void) userLogoTapped : (UITapGestureRecognizer *) recognizer {
    if([_delegate respondsToSelector:@selector(userLogoTapped:)]) {
        [_delegate userLogoTapped:_indexPath];
    }
}

@end
