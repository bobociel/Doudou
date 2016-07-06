//
//  YHFavSearchViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/16.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHFavSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView	*tableView;
@property (weak, nonatomic) IBOutlet UITextField	*searchTextField;
- (IBAction)cancelSearch:(id)sender;

@end
