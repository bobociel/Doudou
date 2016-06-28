//
//  WTDemandCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDemand.h"
#import "WTSupplier.h"
@interface WTDemandCell : UITableViewCell
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *mainTitleLabel;
@property (strong, nonatomic) UILabel *subTtleLabel;
@property (strong, nonatomic) WTSupplier *supplier;
@end
