//
//  YHTaskCreateViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHTaskCreateViewController.h"
#import "YHTask.h"

@interface YHTaskCreateViewController ()
@property (nonatomic) YHTask *task;

@end

@implementation YHTaskCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.task = [[YHTask alloc] init];
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

- (IBAction)onBack:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCreate:(id)sender {
	//create projects
	self.task.title = self.titleField.text;
	self.task.desc = self.descView.text;
//	[[YHDataCache instance].projects addObject:self.project];
//	[[YHDataCache instance] save];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showTimePicker:(id)sender
{
	[UIView animateWithDuration:0.5 animations:^{
		self.timePickView.center  =CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
	}];
}

- (IBAction)hideTimePicker:(id)sender {
	[UIView animateWithDuration:0.5 animations:^{
		self.timePickView.center  =CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height*3/2);
	}];
	[self.dueDateBtn setTitle:self.task.dueDate.description forState:UIControlStateNormal];
}

- (IBAction)updateMeetingTime:(id)sender
{
	UIDatePicker *datepicker = (UIDatePicker*)sender;
	self.task.dueDate = datepicker.date;
	NSLog(@"Meeting time is %@",datepicker.date);
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}
@end
