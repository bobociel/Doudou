//
//  WTDetailCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingCard.h"
@interface WTImageDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (nonatomic,strong) WTWeddingCardImage *cardImage;
+ (CGFloat)cellHeight:(WTWeddingCardImage *)cardImage;
@end

@interface UITableView (WTImageDetailCell)
- (WTImageDetailCell *)WTImageDetailCell;
@end