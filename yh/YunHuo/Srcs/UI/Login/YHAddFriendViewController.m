//
//  YHAddFriendViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHAddFriendViewController.h"

@interface YHAddFriendViewController ()

@end

@implementation YHAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)onSkip:(id)sender
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
