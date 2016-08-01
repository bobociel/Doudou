//
//  WTCardIntroduceCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingCard.h"
@class WTCardIntroduceCell;
@protocol WTCardIntroduceCellDelegate <NSObject>
- (void)WTCardIntroduceCell:(WTCardIntroduceCell *)cell didSelectedMore:(UIButton *)sender;
@end

@interface WTCardIntroduceCell : UITableViewCell
@property (nonatomic,assign) BOOL showAll;
@property (nonatomic,strong) WTWeddingCard *card;
@property (nonatomic,assign) id<WTCardIntroduceCellDelegate> delegate;
+ (CGFloat)getHeightWith:(WTWeddingCard *)card isShowAll:(BOOL)showAll;
@end

@interface UITableView (WTCardIntroduceCell)
- (WTCardIntroduceCell *)WTCardIntroduceCell;
@end