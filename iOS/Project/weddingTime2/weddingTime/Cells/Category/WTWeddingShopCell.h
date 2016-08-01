//
//  CommonTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BaseViewController.h"
#import "WTSupplier.h"
@class WTWeddingShopCell;
@protocol WTWeddingShopCellDelegate <NSObject>
- (void)WTWeddingShopCell:(WTWeddingShopCell *)cell isLike:(BOOL)isLike;
@end

@interface WTWeddingShopCell : UITableViewCell
@property (nonatomic, strong) WTSupplierPost *post;
@property (nonatomic, assign) id <WTWeddingShopCellDelegate> delegate;
@end

@interface UITableView(WTWeddingShopCell)
- (WTWeddingShopCell *)WTWeddingShopCell;
@end