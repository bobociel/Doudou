//
//  WTBlessCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/12/8.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTWeddingBless.h"
@class WTBlessCell;
@protocol WTBlessCellDelegate <NSObject>
- (void)WTBlessCell:(WTBlessCell *)cell didSelectedDelete:(UIControl *)sender;
@end

@interface WTBlessCell : UITableViewCell
@property (nonatomic, strong) WTWeddingBless *bless;
@property (nonatomic,assign) id <WTBlessCellDelegate> delegate;
@end

@interface UITableView (WTBlessCell)
- (WTBlessCell *)WTBlessCell;
@end