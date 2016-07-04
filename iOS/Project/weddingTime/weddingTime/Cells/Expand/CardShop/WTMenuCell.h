//
//  WTMenuCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingCard.h"

@interface WTMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *menuDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *menuPriceLabel;
@property (nonatomic,strong) WTWeddingCardExt *cardExt;
@end

@interface UITableView (WTMenuCell)
- (WTMenuCell *)WTMenuCell;
@end