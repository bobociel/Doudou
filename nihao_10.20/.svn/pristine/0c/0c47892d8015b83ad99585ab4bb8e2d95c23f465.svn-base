//
//  AnswerReplyCell.m
//  nihao
//
//  Created by HelloWorld on 8/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AnswerReplyCell.h"
#import "DTCoreText.h"
#import "Comment.h"
#import "BaseFunction.h"
#import "AppConfigure.h"

@interface AnswerReplyCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelToButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelToSuperViewConatraint;

//@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet DTAttributedTextContentView *replyContentView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AnswerReplyCell {
	NSIndexPath *currentIndexPath;
}

- (void)configureCellWithReply:(Comment *)reply forRowAtIndexPath:(NSIndexPath *)indexPath {
	currentIndexPath = indexPath;
	NSString *content = [NSString stringWithFormat:@"<html><body style=\"font-size: 12px;\"><span style=\"color: #3465a8;\"><font face=\"HelveticaNeue-Light\">%@ : </font></span><span style=\"color: #787878;\"><font face=\"HelveticaNeue-Light\">@ %@ %@</font></span><span style=\"color: #9e9e9e; font-size: 10px;\"><font face=\"HelveticaNeue-Light\">  %@</font></span></body></html>", reply.ci_nikename, reply.cmi_source_nikename, reply.cmi_info, [BaseFunction dynamicDateFormat:reply.cmi_date]];
	
	NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
	self.replyContentView.attributedString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
	self.replyContentView.backgroundColor = [UIColor clearColor];
	
	NSInteger loginUserID = [[AppConfigure valueForKey:LOGINED_USER_ID] integerValue];
	if (loginUserID == reply.cmi_ci_id) {
		[self isMine];
	} else {
		[self notMine];
	}
}

- (void)isMine {
	self.deleteButton.hidden = NO;
	self.labelToSuperViewConatraint.priority = 750;
	if (self.labelToButtonConstraint.priority != 999) {
		self.labelToButtonConstraint.priority = 999;
	}
}

- (void)notMine {
	self.deleteButton.hidden = YES;
	self.labelToButtonConstraint.priority = 750;
	if (self.labelToSuperViewConatraint.priority != 999) {
		self.labelToSuperViewConatraint.priority = 999;
	}
}

- (IBAction)delete:(id)sender {
	NSLog(@"click delete btn");
	if ([self.delegate respondsToSelector:@selector(deleteReplyAtIndexPath:)]) {
		NSLog(@"delete delegate");
		[self.delegate deleteReplyAtIndexPath:currentIndexPath];
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
