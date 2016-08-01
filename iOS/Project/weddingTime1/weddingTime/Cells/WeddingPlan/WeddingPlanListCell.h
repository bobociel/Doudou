//
//  WeddingPlanListCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
typedef NS_ENUM(NSInteger, PPlanStatus) {
    PPlanStatusAll=0,
    PPlanStatusFinish=3,
    PPlanStatusNotFinish=1
};
@interface WeddingPlanListCell : CommTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;

@end


@interface UITableView(WeddingPlanListCell)

- (WeddingPlanListCell *) WeddingPlanListCell;

@end