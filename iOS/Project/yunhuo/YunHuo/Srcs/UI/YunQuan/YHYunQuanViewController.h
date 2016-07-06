//
//  YHYunQuanViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHYunQuanTopicCell : UITableViewCell

@end

@interface YHYunQuanViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *rzNewView;
@property (weak, nonatomic) IBOutlet UIView *rzAddInputBoard;
@property (weak, nonatomic) IBOutlet UIView *rzAddInputKBExtView;
@property (weak, nonatomic) IBOutlet UITextView *rzInputView;
@property (weak, nonatomic) IBOutlet UIButton *realNameCheckBtn;
@property (nonatomic) BOOL isAdddNew;

- (IBAction) onAdd;
- (IBAction) onRealName;
@end
