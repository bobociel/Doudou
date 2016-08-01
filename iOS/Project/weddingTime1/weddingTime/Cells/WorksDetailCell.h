//
//  WorksDetailCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
@interface WorksDetailCell : CommTableViewCell

@property (nonatomic, assign) int type;
@end

@interface UITableView(WorksDetailCell)

- (WorksDetailCell *) WorksDetailCell;
@end