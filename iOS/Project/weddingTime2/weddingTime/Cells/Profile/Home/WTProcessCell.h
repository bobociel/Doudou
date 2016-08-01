//
//  WTProcessCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingBless.h"
#define kCellHeight 82
@class WTProcessCell;
@protocol  WTProcessCellDelegate<NSObject>
- (void)WTProgressCell:(WTProcessCell *)cell didSelectDelete:(UIControl *)sender;
@end

@interface WTProcessCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic,strong) WTWeddingProcess *process;
@property (nonatomic,assign) id <WTProcessCellDelegate> delegate;
@end

@interface UITableView (WTProcessCell)
- (WTProcessCell *)WTProcessCell;
@end