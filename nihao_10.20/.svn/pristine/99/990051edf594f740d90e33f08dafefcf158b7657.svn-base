//
//  BestAnswerCell.m
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BestAnswerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "Comment.h"

@interface BestAnswerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation BestAnswerCell

- (void)configureCellWithBestAnswer:(Comment *)bestAnswer {
	NSString *iconURLString = bestAnswer.ci_header_img;
	NSString *userName = bestAnswer.ci_nikename;
	
	if (IsStringEmpty(userName)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"nihao_%d", bestAnswer.cmi_ci_id];
	} else {
		self.userNameLabel.text = userName;
	}
	
	if (IsStringEmpty(iconURLString)) {
		if (bestAnswer.ci_sex == UserSexTypeFemale) {
			self.iconImageView.image = [UIImage imageNamed:@"default_icon_female"];
		} else {
			self.iconImageView.image = [UIImage imageNamed:@"default_icon_male"];
		}
	} else {
		[self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (!error) {
				self.iconImageView.image = image;
			} else {
				self.iconImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
				NSLog(@"imageURL = %@", imageURL);
			}
		}];
	}
	
	self.answerLabel.text = bestAnswer.cmi_info;
	self.timeLabel.text = [BaseFunction dynamicDateFormat:bestAnswer.cmi_date];
	
	//给用户头像添加点击事件
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserIcon:)];
	recognizer.numberOfTapsRequired = 1;
	[self.iconImageView addGestureRecognizer:recognizer];
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void)tapUserIcon:(UITapGestureRecognizer *)recognizer {
	if (self.clickBestAnswerUserIcon) {
		self.clickBestAnswerUserIcon();
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
