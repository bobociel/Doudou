//
//  ExpandControllerCell.h
//  weddingTime
//
//  Created by 默默 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CellHeight 122.0
@interface ExpandControllerCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *logoImageView;
@property (strong, nonatomic)  UILabel *mainTitleLabel;
@property (strong, nonatomic)  UILabel *subTtleLabel;
-(void)setInfo:(id)info;
@end

@interface UITableView(ExpandControllerCell)
-(ExpandControllerCell *) ExpandControllerCell;
@end