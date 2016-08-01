//
//  BlessCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/8.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTBlessCell.h"
#import <UIImageView+WebCache.h>

@implementation UITableView (WTBlessCell)

- (WTBlessCell *)WTBlessCell
{
    static NSString *CellIdentifier = @"WTBlessCell";
    
    WTBlessCell * cell = (WTBlessCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = (WTBlessCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
@end

@interface WTBlessCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *personCountLabel;
@end

@implementation WTBlessCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self initView];
}
- (void)initView
{
    self.avatarImage.layer.cornerRadius = 25;
    self.avatarImage.layer.masksToBounds = YES;

	_titleLabel.textColor = [UIColor blackColor];
	_titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];

	_personCountLabel.textColor = WeddingTimeBaseColor;	_personCountLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];

	_detailLabel.numberOfLines = 0;
	_detailLabel.textColor = rgba(153, 153, 153, 1);
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
}

- (void)setBless:(WTWeddingBless *)bless
{
	_bless = bless;
	_titleLabel.text = bless.bless_name;
	_detailLabel.text = bless.bless;
	_personCountLabel.text = [_bless.part_num integerValue] == 0 ? @"不参加" : [NSString stringWithFormat:@"%@人参加",bless.part_num] ;
	[_avatarImage sd_setImageWithURL:[NSURL URLWithString:bless.bless_avatar]
					placeholderImage:[UIImage imageNamed:@"supplier"]];
}


- (IBAction)deleteAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(WTBlessCell:didSelectedDelete:)])
	{
		[self.delegate WTBlessCell:self didSelectedDelete:sender];
	}
}

@end
