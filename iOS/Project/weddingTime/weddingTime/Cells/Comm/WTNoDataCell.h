//
//  WTNoDataCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/8.
//  Copyright © 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTNoDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
+ (WTNoDataCell *)NoDataCellWithTableView:(UITableView *)tableView;
@end
