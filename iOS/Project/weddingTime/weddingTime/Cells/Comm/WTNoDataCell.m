//
//  WTNoDataCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/8.
//  Copyright © 2015年 lovewith.me. All rights reserved.
//

#import "WTNoDataCell.h"

@implementation WTNoDataCell

+ (WTNoDataCell *)NoDataCellWithTableView:(UITableView *)tableView{

    static NSString *CellIdentifier = @"WTNoDataCell";

    WTNoDataCell * cell = (WTNoDataCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {

        cell = (WTNoDataCell *)[[NSBundle mainBundle] loadNibNamed:@"WTNoDataCell" owner:self options:nil][0];
    }
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
