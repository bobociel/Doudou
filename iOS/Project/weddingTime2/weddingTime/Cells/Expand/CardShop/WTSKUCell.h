//
//  WTSKUCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingCard.h"

@interface WTSKUCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *supplierSKUView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workLabel;

@property (weak, nonatomic) IBOutlet UIView *cardSKUView;
@property (weak, nonatomic) IBOutlet UILabel *sizeDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *makeDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *makeLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillLabel;
@property (nonatomic,strong) WTWeddingCard *card;
@end

@interface UITableView (WTSKUCell)
- (WTSKUCell *)WTSKUCell;
@end