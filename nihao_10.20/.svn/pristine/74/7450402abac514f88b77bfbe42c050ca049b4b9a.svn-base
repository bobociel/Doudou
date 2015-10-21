//
//  AskNotificationTableViewCell.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "AskNotificationTableViewCell.h"
#import "AskCommentNotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface AskNotificationTableViewCell () {
    NSIndexPath *_indexPath;
}
@property (weak, nonatomic) IBOutlet UIImageView *userLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;

@end

@implementation AskNotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userLogoTapped:)];
    recognizer.numberOfTapsRequired = 1;
    _userLogoImageView.userInteractionEnabled = YES;
    [_userLogoImageView addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureAskNotification:(AskCommentNotification *)notification indexPath:(NSIndexPath *)indexPath {
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
    _commentContentLabel.text = notification.cmi_info;
}

- (void) userLogoTapped : (UITapGestureRecognizer *) recognizer {
    if([_delegate respondsToSelector:@selector(userLogoTapped:)]) {
        [_delegate userLogoTapped:_indexPath];
    }
}

@end
