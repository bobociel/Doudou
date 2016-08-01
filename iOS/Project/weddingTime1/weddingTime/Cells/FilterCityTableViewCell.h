//
//  FilterCityTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
@interface FilterCityTableViewCell : UITableViewCell
- (void)setInfo:(id)info;
- (void)setSelectedColor;
- (void)restoreTitleColor;
@end
@interface UITableView (filterCityCell)

- (FilterCityTableViewCell *)filterCityCell;
@end