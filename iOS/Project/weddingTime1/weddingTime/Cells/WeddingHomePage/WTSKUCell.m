//
//  WTSKUCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTSKUCell.h"

@implementation WTSKUCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCard:(WTWeddingCard *)card
{
	_card = card;
	self.supplierSKUView.hidden = YES;
	self.contentView.backgroundColor = rgba(247, 247, 247, 1);
	if(_card.goods_attr.count > 0){
		self.sizeDescLabel.text = [(WTWeddingCardExt *)_card.goods_attr[0] label];
		self.sizeLabel.text = [(WTWeddingCardExt *)_card.goods_attr[0] attr];
	}
	if(_card.goods_attr.count > 1){
		self.makeDescLabel.text = [(WTWeddingCardExt *)_card.goods_attr[1] label];
		self.makeLabel.text = [(WTWeddingCardExt *)_card.goods_attr[1] attr];
	}
	if (_card.goods_attr.count > 2) {
		self.skillDescLabel.text = [(WTWeddingCardExt *)_card.goods_attr[2] label];
		self.skillLabel.text = [(WTWeddingCardExt *)_card.goods_attr[2] attr];
	}
}

@end

@implementation UITableView (WTSKUCell)

- (WTSKUCell *)WTSKUCell
{
	static NSString *CellIdentifier = @"WTSKUCell";

	WTSKUCell * cell = (WTSKUCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = (WTSKUCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
	}
	return cell;
}
@end