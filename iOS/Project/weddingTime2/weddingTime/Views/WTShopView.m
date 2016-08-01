//
//  WTShopView.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTShopView.h"
#define kTabBarHeight 50.0
@implementation WTShopView

+ (instancetype)shopView:(UIView *)superView
{
	WTShopView *view = (WTShopView *)[[NSBundle mainBundle] loadNibNamed:@"WTShopView" owner:self options:nil][0];
	view.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	return view;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	self.backgroundColor = WeddingTimeBaseColor;
	_priceLabel.textColor = WHITE;
	[self setPrice:0];
	[_buyButton setTitleColor:WHITE forState:UIControlStateNormal];
	[_buyButton setTitle:@"马上购买" forState:UIControlStateNormal];
}

- (void)setPrice:(NSString *)price
{
	_price = price;
	_priceLabel.attributedText = [LWUtil attributeStringWithPrice:price];
}

- (IBAction)buyAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(shopView:didSelectedBuy:)])
	{
		[self.delegate shopView:self didSelectedBuy:sender];
	}
}


@end
