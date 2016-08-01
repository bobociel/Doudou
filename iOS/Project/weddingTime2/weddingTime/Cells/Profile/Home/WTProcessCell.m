//
//  WTProcessCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTProcessCell.h"

@implementation WTProcessCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_contentLabel.font = DefaultFont16;
	_contentLabel.textColor = rgba(153, 153, 153, 1);
	_timeLabel.font = DefaultFont16;
	_timeLabel.textColor = WeddingTimeBaseColor;
}

- (void)setProcess:(WTWeddingProcess *)process
{
	_process = process;

	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:_process.time];

	_timeLabel.text = _process.time == 0 ? @"0:00" : [dateFormatter stringFromDate:date];

	NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:
										  [LWUtil getString:_process.content andDefaultStr:@""]];
	NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc] init];
	paragra.lineBreakMode = NSLineBreakByTruncatingTail;
	paragra.lineSpacing = 4.0;
	content.paragraphStyle = paragra;

	_contentLabel.attributedText = content;
}

- (IBAction)deteteAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(WTProgressCell:didSelectDelete:)]){
		[self.delegate WTProgressCell:self didSelectDelete:sender];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView (WTProcessCell)

- (WTProcessCell *)WTProcessCell
{
	static NSString *CellIdentifier = @"WTProcessCell";

	WTProcessCell * cell = (WTProcessCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTProcessCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
@end
