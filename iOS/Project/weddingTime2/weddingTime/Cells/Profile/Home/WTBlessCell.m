//
//  BlessCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/8.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTBlessCell.h"
#import <UIImageView+WebCache.h>
#define kCellSpace 86
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
@property (weak, nonatomic) IBOutlet UIControl *deleteControl;
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
	_titleLabel.font = DefaultFont16;

	_detailLabel.numberOfLines = 0;
	_detailLabel.textColor = LightGragyColor;
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];

	[self bringSubviewToFront:_deleteControl];
}

- (void)setBless:(WTWeddingBless *)bless
{
	_bless = bless;

	[_avatarImage sd_setImageWithURL:[NSURL URLWithString:bless.bless_avatar]
					placeholderImage:[UIImage imageNamed:@"supplier"]];

	NSString *personStr = _bless.part_num.integerValue == 0 ? @" 不参加" : [NSString stringWithFormat:@" %@人参加",bless.part_num];
	NSAttributedString *person = [[NSAttributedString alloc] initWithString:personStr attributes:@{NSForegroundColorAttributeName :WeddingTimeBaseColor}];
	NSAttributedString *name = [[NSAttributedString alloc] initWithString:bless.bless_name];
	NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
	[title appendAttributedString:name];
	[title appendAttributedString:person];
	_titleLabel.attributedText = title;

	NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:bless.bless];
	NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc] init];
	paragra.lineSpacing = 4.0;
	desc.paragraphStyle = paragra;
	_detailLabel.attributedText = desc;
}

+ (CGFloat)cellHeightWithContent:(NSString *)content
{	
	CGSize descSize = [content sizeForFont:[WeddingTimeAppInfoManager fontWithSize:13]
									  size:CGSizeMake(screenWidth-128, MAXFLOAT)
									  mode:-1];

	return ceil(descSize.height) + kCellSpace;
}


- (IBAction)deleteAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(WTBlessCell:didSelectedDelete:)])
	{
		[self.delegate WTBlessCell:self didSelectedDelete:sender];
	}
}

@end
