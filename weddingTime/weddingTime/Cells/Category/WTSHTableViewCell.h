//
//  CommonTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTSupplier.h"
#import "WTHotel.h"
@class WTSHTableViewCell;
@protocol WTSHTableViewCellDelegate <NSObject>
@optional
- (void)WTSHTableViewCell:(WTSHTableViewCell *)cell isLike:(BOOL)isLike;
@end
@interface WTSHTableViewCell : UITableViewCell
@property (nonatomic, assign) WTWeddingType supplier_type;
@property (nonatomic, weak) id<WTSHTableViewCellDelegate> delegate;
@property (nonatomic, strong) WTSupplier *supplier;
@property (nonatomic, strong) WTSupplierPost *post;
@property (nonatomic, strong) WTHotel *hotel;
@end

@interface UITableView(WTSHTableViewCell)
- (WTSHTableViewCell *)WTSHTableViewCell;
@end