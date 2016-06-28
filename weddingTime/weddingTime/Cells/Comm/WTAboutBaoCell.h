//
//  WTAboutBaoCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/23.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTAboutBaoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
+ (CGFloat)cellHeightWithTitle:(NSString *)title andDesc:(NSString *)desc;
@end

@interface UITableView (WTAboutBaoCell)
- (WTAboutBaoCell *)WTAboutBaoCell;
@end