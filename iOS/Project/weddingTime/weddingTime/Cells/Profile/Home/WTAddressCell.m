//
//  WTAddressCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/10.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTAddressCell.h"
#import <pop/POP.h>
@implementation WTAddressCell

+ (WTAddressCell *)addressCellWithTableView:(UITableView *)tableView{
    WTAddressCell * cell = (WTAddressCell *)[tableView dequeueReusableCellWithIdentifier:@"WTAddressCell"];
    if (nil == cell) {
        cell = (WTAddressCell *)[[NSBundle mainBundle] loadNibNamed:@"WTAddressCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.addressLabel.text = @"";
}

- (void)setAddressName:(NSString *)addressName
{
	_addressName = addressName;
	_addressLabel.text = _addressName;
}

- (void)setCityName:(NSString *)cityName
{
	_cityName = cityName;
	_addressLabel.font = DefaultFont14;
	_addressLabel.text = _cityName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
		self.addressLabel.textColor = WeddingTimeBaseColor;
    } else {
		self.addressLabel.textColor = [_addressName isNotEmptyCtg] ? [UIColor blackColor] : rgba(153, 153, 153, 1);
    }
}

@end
