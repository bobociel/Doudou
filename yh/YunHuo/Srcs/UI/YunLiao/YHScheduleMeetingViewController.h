//
//  YHScheduleMeetingViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/13.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHScheduleMeetingViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView	*meetingTimePickView;
@property (weak, nonatomic) IBOutlet UIButton *meetingDateBtn;
@property (weak, nonatomic) IBOutlet UITextField *topic1Field;
@property (weak, nonatomic) IBOutlet UITextField *topic2Field;
@property (weak, nonatomic) IBOutlet UITextField *topic3Field;

- (IBAction)showTimePicker:(id)sender;
- (IBAction)hideTimePicker:(id)sender;
- (IBAction)updateMeetingTime:(id)sender;
@end
