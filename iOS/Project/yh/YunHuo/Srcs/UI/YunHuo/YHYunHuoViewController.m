//
//  YHYunHuoViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunHuoViewController.h"
#import "HYSegmentedControl.h"
#import "YHYunHuoPageOrderViewController.h"
#import "TouchView.h"
#import "YHConfig.h"
#import "YHYunHuoPageInfo.h"

@interface YHYunHuoViewController ()<HYSegmentedControlDelegate,HYSegmentedControlDataSource>
@property (nonatomic) NSArray *pageTitles;
@property (nonatomic) NSArray *pageControllersClass;
@property (nonatomic) NSMutableDictionary *pageControllers;
@end

@implementation YHYunHuoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.pageTitles = @[@"项目",@"进展",@"日历",@"审核"];
	self.pageControllersClass = @[@"YHProjectsViewController",@"YHActivitiesViewController",@"YHRiChengViewController",@"YHReviewViewController"];
	self.pageControllers = [NSMutableDictionary dictionary];
	[self hySegmentedControlSelectAtIndex:0];
}

- (void) viewDidAppear:(BOOL)animated
{
	[self.pageSegmentControl doInit];
	[self.pageSegmentControl changeSegmentedControlWithIndex:0];
	[self.view layoutSubviews];
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

- (IBAction)nextPage:(id)sender
{
	int curPage = self.pageSegmentControl.curIndex;
	if ( curPage < 2 )
	{
		[self.pageSegmentControl changeSegmentedControlWithIndex:curPage+1];
	}
}

- (IBAction)prePage:(id)sender
{
	int curPage = self.pageSegmentControl.curIndex;
	if ( curPage > 0 )
	{
		[self.pageSegmentControl changeSegmentedControlWithIndex:curPage-1];
	}
}

#pragma mark - HYSegmentedControlDelegate
- (void) hySegmentedControlSelectAtIndex:(NSInteger)index
{
	NSString *controllerStr = self.pageControllersClass[index];
	if ( self.pageControllers[controllerStr] == nil )
	{
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YunHuo" bundle:nil];
		self.pageControllers[controllerStr] = [storyboard instantiateViewControllerWithIdentifier:controllerStr];
		[self addChildViewController:self.pageControllers[controllerStr]];
	}
	[self.pageControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		UIViewController *vc = (UIViewController*)obj;
		[vc.view removeFromSuperview];
	}];
	UIView *view = [self.pageControllers[controllerStr] view];
	view.frame = self.pageContainer.bounds;
	[self.pageContainer addSubview:view];
}

#pragma mark - HYSegmentedControlDataSource
- (NSArray*) titlesForSegmentControl:(HYSegmentedControl*)segmentControl
{
	return self.pageTitles;
}
@end
