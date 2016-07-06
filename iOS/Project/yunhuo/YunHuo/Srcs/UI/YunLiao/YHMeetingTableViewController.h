//
//  YHMeetingTableViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHMeetingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView	*boardBG;
@property (weak, nonatomic) IBOutlet UILabel *meetingIndex;
@property (weak, nonatomic) IBOutlet UILabel *meetingTime;
@property (weak, nonatomic) IBOutlet UITextView *meetingTopic;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar1;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar2;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar3;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar4;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar5;
//@property (weak, nonatomic) IBOutlet UIImageView *avatar6;
@end

@interface YHMeetingTableViewController : UITableViewController

@end
