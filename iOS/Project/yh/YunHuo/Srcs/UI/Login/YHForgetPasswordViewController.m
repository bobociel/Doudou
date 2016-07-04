//
//  YHForgetPasswordViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHForgetPasswordViewController.h"

@interface YHForgetPasswordViewController ()

@end

@implementation YHForgetPasswordViewController

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

- (IBAction)onBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender
{
	
}

- (IBAction)hideKB:(id)sender
{
	[self.phoneField resignFirstResponder];
	[self.captchaField resignFirstResponder];
}

- (IBAction)showPassword:(id)sender
{
	self.passwordField.secureTextEntry = !self.passwordField.secureTextEntry;
	self.confirmPasswordField.secureTextEntry = self.passwordField.secureTextEntry;
}

- (IBAction)modifyPassword:(id)sender
{
	[self enterMainScreen];
}

- (void) enterMainScreen
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainScreen" bundle:nil];
	UIViewController *mainscreen = [storyboard instantiateInitialViewController];
	[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;
	
	//	[self presentViewController:mainscreen animated:YES completion:^{
	//		[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;
	//		[mainscreen updateViewConstraints];
	//	}];
	
}

@end
