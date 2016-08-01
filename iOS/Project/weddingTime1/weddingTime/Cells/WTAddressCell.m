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
        cell.highlighted = YES;
    }
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        self.addressLabel.textColor = [UIColor blackColor];
    }
}

@end
