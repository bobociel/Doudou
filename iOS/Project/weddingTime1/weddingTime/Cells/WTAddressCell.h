//
//  WTAddressCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/10.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
+ (WTAddressCell *)addressCellWithTableView:(UITableView *)tableView;
@end
