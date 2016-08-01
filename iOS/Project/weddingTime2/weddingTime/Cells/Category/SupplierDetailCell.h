//
//  SupplierDetailCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WTSupplier.h"
@interface SupplierDetailCell : UITableViewCell
@property (nonatomic, strong) WTSupplierPost *post;
@end

@interface UITableView(SupplerDetail)
- (SupplierDetailCell *) supplerDetailCell;
@end