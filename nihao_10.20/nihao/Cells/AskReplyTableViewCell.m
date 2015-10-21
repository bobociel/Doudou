//
//  AskReplyTableViewCell.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "AskReplyTableViewCell.h"
#import <DTAttributedTextView.h>
#import <DTCoreText.h>
#import "BaseFunction.h"

@interface AskReplyTableViewCell()

@property (weak, nonatomic) IBOutlet DTAttributedTextView *replyTextView;
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;

@end

@implementation AskReplyTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureAskReplyCell:(AskCommentNotification *)notification {
    NSString *askTitle = @"<p style=\"font-size:12px\"><font face=\"HelveticaNeue-Light\"><span style=\"color:#3465A8;\">Original : </span><span style=\"color:#575757;\">%@</span></font></p>";
    askTitle = [NSString stringWithFormat:askTitle,notification.aki_title];
    NSData* descriptionData = [askTitle dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString* attributedDescription = [[NSAttributedString alloc] initWithHTMLData:descriptionData documentAttributes:NULL];
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedDescription];
    CGSize titleSize = [BaseFunction labelSizeWithText:[@"Original : " stringByAppendingString:notification.aki_title] font:FontNeveLightWithSize(12.0) constrainedToSize:CGSizeMake(CGRectGetWidth(self.contentView.frame) - 10, 1000)];
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:CGRectMake(5, 5, titleSize.width, titleSize.height) range:NSMakeRange(0, [attributedDescription length])];
    _replyTextView.contentSize = CGSizeMake([layoutFrame frame].size.width, [layoutFrame frame].size.height);
    _replyTextView.contentInset = UIEdgeInsetsMake(4, 5, 4, 5);
    _replyTextView.attributedString = attributedDescription;
    _replyTextView.scrollEnabled = NO;
    _replyCountLabel.text = [NSString stringWithFormat:@"%ld",notification.aki_sum_cmi_count];
}

@end
