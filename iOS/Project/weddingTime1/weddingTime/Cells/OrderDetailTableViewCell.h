//
//  OrderDetailTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
@interface OrderDetailTableViewCell : CommTableViewCell

- (void)setPromptLabelText:(NSString *)text;
- (void)setValueLabelTextColor:(UIColor *)color;
@end

@interface UITableView (OrderDetailCell)

- (OrderDetailTableViewCell *)orderDetailCell;
@end