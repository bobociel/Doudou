//
//  YHYunLiaoViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHChatHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *badageLabel;

@end

@interface YHYunLiaoViewController : UITableViewController

- (IBAction)addAction:(id)sender;

@end
