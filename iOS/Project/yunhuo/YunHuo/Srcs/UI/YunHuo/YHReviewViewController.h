//
//  YHReviewViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/23.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHReviewCell : UITableViewCell

@end

@interface YHReviewViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIView *addNewView;
//@property (weak, nonatomic) IBOutlet UIView *addInputBoard;
//@property (weak, nonatomic) IBOutlet UIView *kbExtView;
//@property (weak, nonatomic) IBOutlet UITextView *contentInputView;
//@property (nonatomic) BOOL isAdddNew;

@end
