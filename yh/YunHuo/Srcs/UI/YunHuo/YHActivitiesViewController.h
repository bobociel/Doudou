//
//  YHYunHuoActivitiesViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/13.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface  YHActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *colorDot;
@property (weak, nonatomic) IBOutlet UIView *timeLine;
@property (weak, nonatomic) IBOutlet UIImageView *activityAvatar;
@property (weak, nonatomic) IBOutlet UILabel *activityTime;
@property (weak, nonatomic) IBOutlet UILabel *activityDetail;
@property (nonatomic) BOOL isFirst;
@property (nonatomic) BOOL isLast;

@end

@interface YHActivitiesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)startWork:(id)sender;

@end
