//
//  OrderListTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
@interface OrderListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *orderStateLabel;
- (void)setImageWithStr:(NSString *)url;
- (void)setStateLabelPink;
- (void)setStateLabelGray;
- (void)setInfo:(id)info;
@end

@interface UITableView (OrderListCell)

- (OrderListTableViewCell *)orderListCell;
@end