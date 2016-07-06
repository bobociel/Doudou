//
//  YHScheduleMeetingViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/13.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHScheduleMeetingViewController.h"

@interface YHScheduleMeetingViewController ()
@property (nonatomic) NSDate *meetingDate;

@end

@implementation YHScheduleMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showTimePicker:(id)sender
{
	[UIView animateWithDuration:0.5 animations:^{
		self.meetingTimePickView.center  =CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
	}];
}

- (IBAction)hideTimePicker:(id)sender {
	[UIView animateWithDuration:0.5 animations:^{
		self.meetingTimePickView.center  =CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height*3/2);
	}];
	[self.meetingDateBtn setTitle:self.meetingDate.description forState:UIControlStateNormal];
}

- (IBAction)updateMeetingTime:(id)sender
{
	UIDatePicker *datepicker = (UIDatePicker*)sender;
	self.meetingDate = datepicker.date;
	NSLog(@"Meeting time is %@",datepicker.date);
}

- (IBAction)hideKB:(id)sender
{
	[self.topic1Field resignFirstResponder];
	[self.topic2Field resignFirstResponder];
	[self.topic3Field resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}
@end
