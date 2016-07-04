//
//  WTAboutBaoCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/23.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTAboutBaoCell.h"
#define kCellSpace 65
#define TitleFont  [WeddingTimeAppInfoManager blodFontWithSize:18]
@implementation WTAboutBaoCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_titleLabel.font = TitleFont;
	_titleLabel.textColor = rgba(68, 68, 68, 1);
	_descLabel.font = DefaultFont14;
	_descLabel.textColor = rgba(136, 136, 136, 1);

}

+ (CGFloat)cellHeightWithTitle:(NSString *)title andDesc:(NSString *)desc
{
	CGSize titleSize = [title sizeForFont:TitleFont
									 size:CGSizeMake(screenWidth-44, MAXFLOAT)
									 mode:NSLineBreakByWordWrapping];

	CGSize descSize = [desc sizeForFont:DefaultFont14
								   size:CGSizeMake(screenWidth-44, MAXFLOAT)
								   mode:-1];

	return ceil(titleSize.height) + ceil(descSize.height) + kCellSpace;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation UITableView (WTAboutBaoCell)
- (WTAboutBaoCell *)WTAboutBaoCell
{
	static NSString *CellIdentifier = @"WTAboutBaoCell";

	WTAboutBaoCell *cell = (WTAboutBaoCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTAboutBaoCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
	}
	return cell;
}
@end
