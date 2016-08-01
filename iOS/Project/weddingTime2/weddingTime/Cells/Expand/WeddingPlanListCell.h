//
//  WeddingPlanListCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTMatter.h"
@interface WeddingPlanListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
@property (nonatomic, strong) WTMatter *matter;
@end

@interface UITableView(WeddingPlanListCell)
- (WeddingPlanListCell *) WeddingPlanListCell;
@end