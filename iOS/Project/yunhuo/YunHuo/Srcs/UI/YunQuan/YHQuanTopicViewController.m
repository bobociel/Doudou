//
//  YHQuanTopicViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/20.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHQuanTopicViewController.h"

@interface YHQuanTopicViewController ()

@end

@implementation YHQuanTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	CGSize size = self.contentView.bounds.size;
	size.height += 60;
	self.scrollView.contentSize = size;
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
