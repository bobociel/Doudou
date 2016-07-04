//
//  YHKaoQinViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHKaoQin;

@interface YHKaoQinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *kaoqinEventLabel;

@property (nonatomic) YHKaoQin	*kaoqin;

@end

@interface YHKaoQinViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *kaoqinBtn;
@property (weak, nonatomic) IBOutlet UILabel *tableViewTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onCheck:(id)sender;
@end
