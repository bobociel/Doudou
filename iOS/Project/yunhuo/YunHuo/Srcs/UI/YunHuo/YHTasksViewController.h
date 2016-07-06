//
//  YHTasksViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface YHTaskCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *taskIcon;
@property (weak, nonatomic) IBOutlet UILabel *taskTitle;
@end

@interface YHTasksViewController : UIViewController<SWTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
