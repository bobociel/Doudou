//
//  WTBudgetCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTBudget.h"
#define kCellHeight 120
#define kMaxPrice 10000
@class WTBudgetCell;
@protocol  WTBudgetCellDelegate <NSObject>
- (void)WTBudgetCell:(WTBudgetCell *)cell priceChanged:(NSString *)price;
@end

@interface WTBudgetCell : UITableViewCell
@property (nonatomic,assign) WTWeddingType wedType;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (copy, nonatomic) NSString *step;
@property (copy, nonatomic) NSString *price;
@property (nonatomic, assign) id<WTBudgetCellDelegate> delegate;
@end

@interface UITableView (WTBudgetCell)
- (WTBudgetCell *)WTBudgetCell;
@end