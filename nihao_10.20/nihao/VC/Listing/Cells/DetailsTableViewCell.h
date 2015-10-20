//
//  DetailsTableViewCell.h
//  nihao
//
//  Created by 罗中华 on 15/10/20.
//  Copyright © 2015年 boru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsTableViewCell : UITableViewCell
@property(nonatomic,weak) UIImageView *imageView;
@property(nonatomic,weak) UILabel     *logLabel;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
