//
//  YHYunQuanSearchViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/22.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSegmentedControl;

@interface YHYunQuanSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchHistoryView;
@property (nonatomic,weak) IBOutlet HYSegmentedControl	*pageSegmentControl;

@end
