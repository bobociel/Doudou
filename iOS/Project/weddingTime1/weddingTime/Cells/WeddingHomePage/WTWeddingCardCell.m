//
//  WTWeddingCardCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingCardCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#define kThumb600 @"?imageView2/1/w/600/h/600"
@implementation WTWeddingCardCell
-(void)setCard:(WTWeddingCard *)card
{
	_card = card;
	_cardName.text = card.goods_name;
	_cardPrice.text = [NSString stringWithFormat:@"￥%.2f",card.goods_price];
	NSString *imageURL = [NSString stringWithFormat:@"%@%@",_card.main_pic,kThumb600];
	[_cardImageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
										placeholderImage:nil
												 options:SDWebImageRetryFailed
												progress:nil
											   completed:nil
									ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
								  ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												Diameter:50];
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