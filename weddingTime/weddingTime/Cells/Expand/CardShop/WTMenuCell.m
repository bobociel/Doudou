//
//  WTMenuCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTMenuCell.h"

@implementation WTMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCardExt:(WTWeddingCardExt *)cardExt
{
	_cardExt = cardExt;
	_menuDescLabel.text = cardExt.label;
	_menuPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",_cardExt.price];
}

@end

@implementation UITableView (WTMenuCell)

- (WTMenuCell *)WTMenuCell
{
	static NSString *CellIdentifier = @"WTMenuCell";

	WTMenuCell * cell = (WTMenuCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTMenuCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
	}
	return cell;
}

@end