//
//  WTCardIntroduceCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTCardIntroduceCell.h"
#define kTitleHeight   18.0
#define kMoreBtnHeight 32.0
#define kMoreBtnBottom 30.0
#define kItemSpaces    125.0
#define kTextMaxHeight 74.0
@interface WTCardIntroduceCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreButonTop;
@end

@implementation WTCardIntroduceCell
- (void)awakeFromNib
{
	self.clipsToBounds = YES;

	_nameLabel.font = DefaultFont20;
	_nameLabel.textColor = [UIColor blackColor];

	_descLabel.font = DefaultFont12;
	_descLabel.textColor = rgba(130, 130, 130, 1);

	_moreButton.layer.borderWidth = 1.0;
	_moreButton.layer.borderColor = rgba(170, 170, 170, 1).CGColor;
	[_moreButton setTitleColor:LightGragyColor forState:UIControlStateNormal];
	[_moreButton setTitle:@"展开全部" forState:UIControlStateNormal];
	[_moreButton setTitle:@"收回全部" forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCard:(WTWeddingCard *)card
{
	_card = card;
	_nameLabel.text = [LWUtil getString:_card.goods_name andDefaultStr:@""] ;
	_descLabel.text = [LWUtil getString:_card.goods_desc andDefaultStr:@""];

	CGSize textSize = [card.goods_desc sizeForFont:DefaultFont12 size:CGSizeMake(screenWidth - 2 * 20, MAXFLOAT) mode:NSLineBreakByWordWrapping];

	_moreButtonHeight.constant = textSize.height <= kTextMaxHeight ? 0 : kMoreBtnHeight;
	_moreButonTop.constant = textSize.height <= kTextMaxHeight ? 0 : kMoreBtnBottom;
	_moreButton.hidden = textSize.height <= kTextMaxHeight;
}

+ (CGFloat)getHeightWith:(WTWeddingCard *)card  isShowAll:(BOOL)showAll
{
	CGSize textSize = [card.goods_desc sizeForFont:DefaultFont12 size:CGSizeMake(screenWidth - 2 * 20, MAXFLOAT) mode:NSLineBreakByWordWrapping];
	if(textSize.height <= kTextMaxHeight){
		return kTitleHeight + textSize.height + kItemSpaces - kMoreBtnBottom;
	}

	return showAll ? kTitleHeight + kMoreBtnHeight + textSize.height + kItemSpaces : kTitleHeight + kMoreBtnHeight + kItemSpaces + MIN(kTextMaxHeight, ceil(textSize.height)) ;
}

- (IBAction)moreAction:(UIButton *)sender
{
	if([self.delegate respondsToSelector:@selector(WTCardIntroduceCell:didSelectedMore:)])
	{
		sender.selected = !sender.selected;
		[self.delegate WTCardIntroduceCell:self didSelectedMore:sender];
	}
}

@end

@implementation UITableView (WTCardIntroduceCell)

- (WTCardIntroduceCell *)WTCardIntroduceCell
{
	static NSString *CellIdentifier = @"WTCardIntroduceCell";

	WTCardIntroduceCell * cell = (WTCardIntroduceCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {

		cell = (WTCardIntroduceCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		
	}
	return cell;
}
@end