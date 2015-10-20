//
//  AskAnswerCell.m
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskAnswerCell.h"
#import "Comment.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "BaseFunction.h"
#import "AppConfigure.h"

@interface AskAnswerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *operatorBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@implementation AskAnswerCell {
	NSIndexPath *currentIndexPath;
}

- (void)configureCellWithAnswer:(Comment *)answer questionUserID:(NSString *)userID forRowAtIndexPath:(NSIndexPath *)indexPath {
	currentIndexPath = indexPath;
	
	NSString *iconURLString = answer.ci_header_img;
	NSString *userName = answer.ci_nikename;
	
	if (IsStringEmpty(userName)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"nihao_%d", answer.cmi_ci_id];
	} else {
		self.userNameLabel.text = userName;
	}
	
	if (IsStringEmpty(iconURLString)) {
		if (answer.ci_sex == UserSexTypeFemale) {
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
	
	if (answer.cmi_source_type == 2) {
		self.answerContentLabel.text = [NSString stringWithFormat:@"Reply@%@:%@", answer.cmi_source_nikename, answer.cmi_info];
	} else {
		self.answerContentLabel.text = answer.cmi_info;
	}
	
	self.timeLabel.text = [BaseFunction dynamicDateFormat:answer.cmi_date];
	
	//给用户头像添加点击事件
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserIcon:)];
	recognizer.numberOfTapsRequired = 1;
	[self.userIconImageView addGestureRecognizer:recognizer];
	
//	NSInteger loginUserID = [[NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]] integerValue];
//	if (loginUserID == answer.cmi_ci_id) {
//		self.deleteBtn.hidden = NO;
//	} else {
//		self.deleteBtn.hidden = YES;
//	}
	
	if (self.lineView.subviews.count <= 0) {
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 8, 0.5)];
		line.backgroundColor = SeparatorColor;
		[self.lineView addSubview:line];
	}
}

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark - click events

- (IBAction)operatorBtnClick:(id)sender {
	if ([self.delegate respondsToSelector:@selector(showAnswerOperationsWithCurrentCellIndexPath:)]) {
		[self.delegate showAnswerOperationsWithCurrentCellIndexPath:currentIndexPath];
	}
}

- (IBAction)deleteBtnClick:(id)sender {
	if ([self.delegate respondsToSelector:@selector(clickedDeleteBtnForRowAtIndexPath:)]) {
		[self.delegate clickedDeleteBtnForRowAtIndexPath:currentIndexPath];
	}
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void)tapUserIcon:(UITapGestureRecognizer *)recognizer {
	if ([self.delegate respondsToSelector:@selector(clickedUserIconAtIndexPath:)]) {
		[self.delegate clickedUserIconAtIndexPath:currentIndexPath];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
