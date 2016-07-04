//
//  WTWeddingCardCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingCardCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#define kLeftGap  23.0
#define kAddHeight 117.0
@implementation WTWeddingCardCell
-(void)setCard:(WTWeddingCard *)card
{
	_card = card;
	_cardName.text = card.goods_name;
	_cardPrice.text = [NSString stringWithFormat:@"￥%@",card.goods_price];

	_cardImageView.clipsToBounds = YES;
	_cardImageView.contentMode = UIViewContentModeScaleAspectFill;
	_cardViewHeight.constant = ceil(card.h / card.w  * (screenWidth / 2.0 - 2 * kLeftGap) );
	[_cardImageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:[_card.main_pic stringByAppendingString:kSmall600]]
										placeholderImage:nil
												 options:SDWebImageRetryFailed
												progress:nil
											   completed:nil
									ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
								  ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												Diameter:50];
}

+ (CGFloat)cellHeightWithCard:(WTWeddingCard *)card
{
	CGFloat cellHeight = ceil(card.h / card.w  * (screenWidth / 2.0 - 2 * kLeftGap) ) + kAddHeight;
	return cellHeight;
}
- (IBAction)cardCellChoosed:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(cardCell:didClick:)])
	{
		[self.delegate cardCell:self didClick:sender];
	}
}

@end

@implementation PSCollectionView (WTWeddingCardCell)

- (WTWeddingCardCell *)WTWeddingCardCell{
	WTWeddingCardCell *cell = (WTWeddingCardCell *)[self dequeueReusableView];
	if (nil == cell) {
		cell = [[NSBundle mainBundle] loadNibNamed:@"WTWeddingCardCell" owner:nil options:nil][0];
	}

	cell.backgroundColor=[UIColor whiteColor];
	return cell;
}
@end