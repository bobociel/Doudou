//
//  AskContentCell.m
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskContentCell.h"
#import "AskContent.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "BaseFunction.h"
#import "AppConfigure.h"

@interface AskContentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AskContentCell

- (void)configureCellWithContent:(AskContent *)askContent {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSString *iconURLString = askContent.aki_source_header_img;
	NSString *userName = askContent.aki_source_nikename;
	
	if (IsStringEmpty(userName)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"nihao_%ld", askContent.aki_source_id];
	} else {
		self.userNameLabel.text = userName;
	}
	
	if (IsStringEmpty(iconURLString)) {
		if (askContent.aki_source_sex == UserSexTypeFemale) {
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
	
	self.questionTitleLabel.text = askContent.aki_title;
	self.questionDescriptionLabel.text = askContent.aki_info;
	
	self.timeLabel.text = [BaseFunction dynamicDateFormat:askContent.aki_date];
	
	//给用户头像添加点击事件
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserIcon:)];
	recognizer.numberOfTapsRequired = 1;
	[self.iconImageView addGestureRecognizer:recognizer];
	
	NSInteger cUserID = [AppConfigure integerForKey:LOGINED_USER_ID];
	if (cUserID == askContent.aki_source_id) {
		self.deleteButton.hidden = NO;
		self.deleteButton.userInteractionEnabled = YES;
	} else {
		self.deleteButton.hidden = YES;
		self.deleteButton.userInteractionEnabled = NO;
	}
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void)tapUserIcon:(UITapGestureRecognizer *)recognizer {
	if (self.clickAskContentUserIcon) {
		self.clickAskContentUserIcon();
	}
}

- (IBAction)deleteClick:(id)sender {
	if (self.deleteClicked) {
		self.deleteClicked();
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
