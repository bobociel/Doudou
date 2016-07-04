//
//  YHSignUpViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/8.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHRegisterViewController.h"
#import "YHAddFriendViewController.h"

@interface YHRegisterViewController ()

@end

@implementation YHRegisterViewController

- (void) dealloc
{
	
}

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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if ( [textField isEqual:self.nameField] )
	{
		[self.emailField becomeFirstResponder];
	}
	else if ( [textField isEqual:self.emailField] )
	{
		if ( [self isAllFieldOK] )
		{
			[self onNext:nil];
		}
		else
		{
			[textField resignFirstResponder];
		}
	}
	return YES;
}

- (BOOL) isAllFieldOK
{
	//检测名字是否含非法字符
	
	//检测是否合法邮件地址
	
	return YES;
}

- (IBAction)onNext:(id)sender
{
	YHYunKeProfile *profile = [YHDataCache instance].profile;
	profile.name = self.nameField.text;
	profile.email = self.emailField.text;
	profile.phone = [self.phoneField.text longLongValue];
	
//	UIViewController *addfriendVC = [[YHAddFriendViewController alloc] initWithNibName:@"YHAddFriendViewController" bundle:nil];
//	[self presentViewController:addfriendVC animated:YES completion:^{
//		[UIApplication sharedApplication].keyWindow.rootViewController = addfriendVC;
//	}];
}

- (IBAction)hideKB:(id)sender
{
	[self.phoneField resignFirstResponder];
	[self.captchaField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	[self.nameField resignFirstResponder];
	[self.emailField resignFirstResponder];
	[self.confirmPasswordField resignFirstResponder];
}

- (IBAction)onBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
