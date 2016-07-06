//
//  ViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/8.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHLoginViewController.h"
#import "NSDate+Category.h"
#import "YHConfig.h"

@interface YHLoginViewController ()

@end

@implementation YHLoginViewController

- (void) dealloc
{
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if ( [textField isEqual:self.userNameField] )
	{
		[self.passwordField becomeFirstResponder];
	}
	else
	{
		[self onNext:nil];
	}
	return YES;
}

- (IBAction)onNext:(id)sender
{
	//登录等待
	[self enterMainScreen];
}

- (IBAction)hideKB:(id)sender
{
	[self.userNameField resignFirstResponder];
	[self.passwordField resignFirstResponder];
}

- (IBAction)onBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) enterMainScreen
{
	//TBD,还需要考虑自动登录，修改密码登录
	if ( ![[YHConfig instance].lastLanuchTime isEqualToDateIgnoringTime:[NSDate date]] )
	{
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainScreen" bundle:nil];
		UIViewController *mainscreen = [storyboard instantiateInitialViewController];
		[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;		
	}
	else
	{
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainScreen" bundle:nil];
		UIViewController *mainscreen = [storyboard instantiateViewControllerWithIdentifier:@"DayTip"];
		[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;
	}
	[YHConfig instance].lastLanuchTime = [NSDate date];
	[[YHConfig instance] save];

//	[self presentViewController:mainscreen animated:YES completion:^{
//		[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;
//		[mainscreen updateViewConstraints];
//	}];

}
@end
