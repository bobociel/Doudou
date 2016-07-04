//
//  BaseViewController.m
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "BaseViewController.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setNavigationHide:NO];
}

- (void)setNavigationHide:(BOOL)isHide
{
	[[UIApplication sharedApplication] setStatusBarStyle:isHide ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
	UIImage *bgImage = isHide ? nil : [UIImage imageWithColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setShadowImage:nil];
	[[UINavigationBar appearance] setTintColor:[UIColor orangeColor]];
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

@implementation UIImage (Custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0,0,1.0,1.0);

	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);
	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return coloredImage;
}

@end
