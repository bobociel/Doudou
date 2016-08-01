//
//  FindTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/22.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FindItemModel.h"
#define kCellHeight (325 * Height_ato)
@interface FindTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger type;
- (void)setUIWithInfo:(FindItemModel *)info;
@end


@interface UITableView(FindCell)

- (FindTableViewCell *) findCell;
@end