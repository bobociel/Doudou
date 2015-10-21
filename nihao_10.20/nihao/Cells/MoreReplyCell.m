//
//  MoreReplyCell.m
//  nihao
//
//  Created by HelloWorld on 8/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MoreReplyCell.h"
#import "Comment.h"
#import "Constants.h"

@interface MoreReplyCell ()

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation MoreReplyCell {
	NSIndexPath *currentIndexPath;
}

- (void)configureCellWithAnswer:(Comment *)answer forRowAtIndexPath:(NSIndexPath *)indexPath {
	currentIndexPath = indexPath;
// 2015-08-14 start -------------
//	[self.moreButton setTitle:[NSString stringWithFormat:@"More %ld replies", answer.comments.count - answer.showComments.count] forState:UIControlStateNormal];
// 2015-08-14 end -------------
	
// modify start ------
//	[self.moreButton setTitle:@"More replies" forState:UIControlStateNormal];
// modify end ------
	
	if (self.contentView.subviews.count < 2) {
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.frame) - 0.5, SCREEN_WIDTH - 15, 0.5)];
		separator.backgroundColor = SeparatorColor;
		[self.contentView addSubview:separator];
	}
}

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)showMore:(id)sender {
	if ([self.delegate respondsToSelector:@selector(showMoreReplyFromIndexPath:)]) {
		[self.delegate showMoreReplyFromIndexPath:currentIndexPath];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
