//
//  YHFavAddTextViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/16.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHFavAddTextViewController.h"

@interface YHFavAddTextViewController ()

@end

@implementation YHFavAddTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self.textView becomeFirstResponder];
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

- (IBAction)onCancel:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
