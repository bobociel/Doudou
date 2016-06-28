//
//  WTAddressCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/10.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTCityGroup.h"
@interface WTAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *addressName;
+ (WTAddressCell *)addressCellWithTableView:(UITableView *)tableView;
@end
