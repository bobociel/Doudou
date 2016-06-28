//
//  WTThemeCell.m
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import "WTThemeCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@implementation WTThemeCell

- (void)awakeFromNib {
    // Initialization code
	self.backgroundColor = [UIColor clearColor];
	self.imageView.backgroundColor = rgba(221, 221, 221, 1);
	self.imageView.layer.masksToBounds = YES;
	self.imageView.layer.cornerRadius = 5.0;

	self.showCardButton.hidden = YES;
//	self.imageView.layer.shadowRadius = 5.0;
//	self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
//	self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)setTheme:(WTWeddingTheme *)theme
{
	_theme = theme;
	
	_showCardButton.hidden = [LWUtil getString:theme.goods_id andDefaultStr:@""].length == 0;

	NSString *imageURL = [LWUtil getString:theme.path andDefaultStr:@""];
	_imageView.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	[_imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
										placeholderImage:nil
												 options:SDWebImageRetryFailed
												progress:nil
											   completed:nil
									ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
								  ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												Diameter:50];
	
}

- (IBAction)openCardAction:(UIButton *)sender
{
	if([self.delegate respondsToSelector:@selector(WTThemeCell:didSeledtedOpenCard:)])
	{
		[self.delegate WTThemeCell:self didSeledtedOpenCard:sender];
	}
}

@end
