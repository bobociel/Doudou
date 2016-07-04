//
//  YHMainScreenViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/27.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHMainScreenViewController.h"

@interface YHMainScreenViewController ()

@end

@implementation YHMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	UIViewController *yl = [[UIStoryboard storyboardWithName:@"YunLiao" bundle:nil] instantiateInitialViewController];
	UIViewController *yh = [[UIStoryboard storyboardWithName:@"YunHuo" bundle:nil] instantiateInitialViewController];
	UIViewController *yq = [[UIStoryboard storyboardWithName:@"YunQuan" bundle:nil] instantiateInitialViewController];
	UIViewController *yk = [[UIStoryboard storyboardWithName:@"YunKe" bundle:nil] instantiateInitialViewController];
	self.viewControllers = @[yl,yh,yq,yk];
	self.tabBar.tintColor = [UIColor colorWithRed:243/255.0 green:112/255.0 blue:33/255.0 alpha:1.0];
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

@end
