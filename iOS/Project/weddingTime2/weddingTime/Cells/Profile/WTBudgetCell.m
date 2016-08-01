//
//  WTBudgetCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//
#import "WTBudgetCell.h"
@implementation WTBudgetCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_priceLabel.attributedText = [LWUtil attributeStringWithBudget:@"0"];

	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(15, kCellHeight - 0.5, screenWidth, 0.5)];
	lineView.image = [UIImage imageWithColor:rgba(221, 221, 221, 1)];
	[self addSubview:lineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)changePrice:(UISlider *)sender
{
	CGFloat aPrice = floorf(sender.value / _step.integerValue) * _step.integerValue;
	if(aPrice < sender.minimumValue) {
		aPrice = sender.minimumValue;
	}
	_price = [NSString stringWithFormat:@"%.0f",aPrice];
	_priceLabel.attributedText = [LWUtil attributeStringWithBudget:_price];
	if([self.delegate respondsToSelector:@selector(WTBudgetCell:priceChanged:)]){
		[self.delegate WTBudgetCell:self priceChanged:_price];
	}
}

@end

@implementation UITableView (WTBudgetCell)
- (WTBudgetCell *)WTBudgetCell
{
	static NSString *CellIdentifier = @"WTBudgetCell";

	WTBudgetCell *cell = (WTBudgetCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = (WTBudgetCell *)[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
@end
