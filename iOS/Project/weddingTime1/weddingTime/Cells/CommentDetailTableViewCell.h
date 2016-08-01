//
//  CommentDetailTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"
@interface CommentDetailTableViewCell : UITableViewCell
- (void)setInfo:(id)info;

@end

@interface UITableView (CommentDetailCell)

- (CommentDetailTableViewCell *)commentDetailCell;
@end