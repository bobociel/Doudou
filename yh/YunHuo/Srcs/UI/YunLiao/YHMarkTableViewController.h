//
//  YHMarkTableViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHMarkCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView		*contentBG;

@end

@interface YHMarkTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@end
