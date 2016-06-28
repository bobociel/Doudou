//
//  WTTicketCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//
#import "WTTicketCell.h"
@implementation WTTicketCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_companyLabel.font = DefaultFont18;
	_priceLabel.font = DefaultFont20;
	_descLabel.font = DefaultFont12;
	_stateLabel.font = DefaultFont12;

	_sPriceLabel.font = DefaultFont24;
	_sDescLabel.font = DefaultFont12;
	_sStateLabel.font = DefaultFont16;

	_bgView.layer.cornerRadius = 2.0;
	_bgView.layer.masksToBounds = YES;
	_sBgView.layer.cornerRadius = 2.0;
	_sBgView.layer.masksToBounds = YES;
	_headImageView.layer.cornerRadius = _headImageView.height / 2.0;
	_headImageView.layer.borderColor = WHITE.CGColor;
	_headImageView.layer.borderWidth = 3.0f;
	_headImageView.layer.masksToBounds = YES;
}

- (void)setTicket:(WTTicket *)ticket
{
	_ticket = ticket;
	_sBgView.hidden = YES;
	_bgView.backgroundColor = _ticket.ticketColor;
	_companyLabel.text = [LWUtil getString:_ticket.company andDefaultStr:@""];
	_priceLabel.text = [LWUtil stringWithPrice:_ticket.amount];
	_descLabel.text = _ticket.desc;
	_stateLabel.text = [LWUtil getString:_ticket.state_name andDefaultStr:@""];
	[_headImageView sd_setImageWithURL:[NSURL URLWithString:_ticket.avatar]
					  placeholderImage:[WeddingTimeAppInfoManager avatarPlcehold]];
}

- (void)setSupplierTicket:(WTTicket *)supplierTicket
{
	_supplierTicket = supplierTicket;
	_bgView.hidden = YES;
	_sBgView.backgroundColor = _supplierTicket.ticketColor;
	_sPriceLabel.text = [LWUtil stringWithPrice:_supplierTicket.amount];
	_sDescLabel.text =  [LWUtil getString:_supplierTicket.desc andDefaultStr:@""];
	_sStateLabel.text = [LWUtil getString:_supplierTicket.state_name andDefaultStr:@""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView (WTTicketCell)
- (WTTicketCell *)WTTicketCell
{
	static NSString *CellIdentifier = @"WTTicketCell";
	WTTicketCell *cell = (WTTicketCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = (WTTicketCell *)[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
@end
