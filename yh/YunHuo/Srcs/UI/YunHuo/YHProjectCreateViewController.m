//
//  YHProjectCreateViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHProjectCreateViewController.h"
#import "YHProject.h"

@interface YHProjectCreateViewController ()
@property (nonatomic) YHProject *project;

@end

@implementation YHProjectCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.project = [[YHProject alloc] init];
	self.project.logo = [UIImage imageNamed:@"ProjectDefaultIcon"];
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
	if ( self.titleField.text.length > 0 )
	{
		self.project.title = self.titleField.text;
	}
	else
	{
		self.project.title = @"云活产品开发";
	}
	
	self.project.desc = self.descView.text;
	[[YHDataCache instance].projects addObject:self.project];
	[[YHDataCache instance] save];
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
	[self.dueDateBtn setTitle:self.project.dueDate.description forState:UIControlStateNormal];
}

- (IBAction)updateMeetingTime:(id)sender
{
	UIDatePicker *datepicker = (UIDatePicker*)sender;
	self.project.dueDate = datepicker.date;
	NSLog(@"Meeting time is %@",datepicker.date);
}

- (IBAction)onLogo:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"拍照",@"从手机相册选择", nil];
	[actionSheet showInView:self.view];
}

- (void) updateLogo
{
	[self.logoBtn setImage:self.project.logo forState:UIControlStateNormal];
}

#pragma make UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *photo = info[UIImagePickerControllerEditedImage];
	//TBD,做缩放
	//	self.userInfo.photo = [photo scaleToSize:CGSizeMake(50, 50)];
	//	[FYConfig instance].user.userInfo.photo = self.userInfo.photo;
	//	self.myPhoto.image = self.userInfo.photo;
	//	[[FYServerAgent instance] userPhotoSet:self.userInfo.photo];
	
	//TBD,上传,缓存
	self.project.logo = photo;
	[self updateLogo];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma make UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == actionSheet.cancelButtonIndex )
	{
		return;
	}
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	picker.allowsEditing = YES;
	[self presentViewController:picker animated:YES completion:^{
	}];
	
	if ( buttonIndex == 0 )
	{
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else if ( buttonIndex == 1 )
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}
@end
