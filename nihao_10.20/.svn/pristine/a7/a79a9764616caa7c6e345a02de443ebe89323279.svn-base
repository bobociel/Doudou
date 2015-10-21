//
//  PostCommentCell.m
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PostCommentCell.h"
#import "Comment.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Constants.h"
#import "AppConfigure.h"

@interface PostCommentCell () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteCommentBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelToBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelToDeleteBtn;

@end

@implementation PostCommentCell {
	NSIndexPath *currentIndexPath;
}

- (void)configureCellWithInfo:(Comment *)comment forRowAtIndexPath:(NSIndexPath *)indexPath {
	currentIndexPath = indexPath;
	NSString *iconURLString = comment.ci_header_img;
	if (IsStringEmpty(iconURLString)) {
		if (comment.ci_sex == UserSexTypeFemale) {
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
	
	if (IsStringEmpty(comment.ci_nikename)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"user-%d", comment.cmi_ci_id];
	} else {
		self.userNameLabel.text = comment.ci_nikename;
	}
	
	if (comment.cmi_ci_id != ([[AppConfigure objectForKey:LOGINED_USER_ID] intValue])) {
		[self notMineComment];
	} else {
		[self isMineComment];
	}
	
	self.commentDateLabel.text = [BaseFunction dynamicDateFormat:comment.cmi_date];
	if (comment.cmi_source_type == 2) {
		self.commentContentLabel.text = [NSString stringWithFormat:@"Reply@%@:%@", comment.cmi_source_nikename, comment.cmi_info];
	} else {
		self.commentContentLabel.text = comment.cmi_info;
	}
	
	//给用户头像添加点击事件
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserIcon:)];
	recognizer.numberOfTapsRequired = 1;
	[self.userIconImageView addGestureRecognizer:recognizer];
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void)tapUserIcon:(UITapGestureRecognizer *)recognizer {
	if (self.clickUserIcon) {
		self.clickUserIcon(currentIndexPath);
	}
}

- (IBAction)deleteComment:(id)sender {
	[self showAlert];
}

- (void)showAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:DELETE_COMMENT_CONFIRM_TEXT delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alertView show];
}

- (void)isMineComment {
	self.deleteCommentBtn.hidden = NO;
	self.contentLabelToBottom.priority = 750;
	if (self.contentLabelToDeleteBtn.priority != 999) {
		self.contentLabelToDeleteBtn.priority = 999;
	}
}

- (void)notMineComment {
	self.deleteCommentBtn.hidden = YES;
	self.contentLabelToDeleteBtn.priority = 750;
	if (self.contentLabelToBottom.priority != 999) {
		self.contentLabelToBottom.priority = 999;
	}
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSLog(@"buttonIndex = %ld", buttonIndex);
	if (buttonIndex == 1) {
		if (self.deleteComment) {
			self.deleteComment(currentIndexPath);
		}
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
