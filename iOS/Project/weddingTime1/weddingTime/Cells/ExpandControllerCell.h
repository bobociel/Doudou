//
//  ExpandControllerCell.h
//  weddingTime
//
//  Created by 默默 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
#define CellHeight 170.0
#define CellWidth  414.0
@interface ExpandControllerCell : CommTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *subTtleLabel;

@end

@interface UITableView(ExpandControllerCell)
-(ExpandControllerCell *) ExpandControllerCell;
@end