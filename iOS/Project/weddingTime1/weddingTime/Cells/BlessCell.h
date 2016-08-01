//
//  BlessCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/12/8.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "WTBless.h"
@interface BlessCell : UITableViewCell
@property (nonatomic, strong) WTBless *bless;
@end

@interface UITableView (blessCell)

- (BlessCell *)blessCell;
@end