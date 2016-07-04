//
//  WTIntroduceCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingCard.h"
@class WTIntroduceCell;
@protocol WTIntroduceCellDelegate <NSObject>
- (void)WTIntroduceCell:(WTIntroduceCell *)cell didSelectedMore:(UIButton *)sender;
@end

@interface WTIntroduceCell : UITableViewCell
@property (nonatomic,assign) BOOL showAll;
@property (nonatomic,strong) WTWeddingCard *card;
@property (nonatomic,assign) id<WTIntroduceCellDelegate> delegate;
+ (CGFloat)getHeightWith:(WTWeddingCard *)card isShowAll:(BOOL)showAll;
@end

@interface UITableView (WTIntroduceCell)
- (WTIntroduceCell *)WTIntroduceCell;
@end