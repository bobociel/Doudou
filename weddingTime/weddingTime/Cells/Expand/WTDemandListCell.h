//
//  WTDemandListCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDemand.h"
@interface WTDemandListCell : UITableViewCell
@property (strong, nonatomic) UILabel *mainTitleLabel;
@property (strong, nonatomic) UILabel *subTtleLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) WTDemand *demand;
@end
