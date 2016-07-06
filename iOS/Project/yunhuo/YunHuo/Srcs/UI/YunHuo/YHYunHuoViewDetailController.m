//
//  YHYunHuoViewDetailController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunHuoViewDetailController.h"
#import "HYSegmentedControl.h"
#import "YHYunHuoPageOrderViewController.h"
#import "TouchView.h"
#import "YHConfig.h"
#import "YHYunHuoPageInfo.h"

@interface YHYunHuoViewDetailController ()<HYSegmentedControlDelegate,HYSegmentedControlDataSource>
@property (nonatomic) NSArray	*visiblePages;
@property (nonatomic) NSArray	*visiblePagesTitles;
@property (nonatomic) NSArray	*visiblePagesIcons;
@property (nonatomic) NSMutableDictionary *pageControllers;
@end

@implementation YHYunHuoViewDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.pageControllers = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
	[self updatePagesType];
	[self.pageSegmentControl changeSegmentedControlWithIndex:0];
}

- (void) viewDidAppear:(BOOL)animated
{
	[self.pageSegmentControl doInit];
	[self.view layoutSubviews];
}

//- (void) viewDidAppear:(BOOL)animated
//{
//	[self.pageSegmentControl doInit];
//	[self.view layoutSubviews];
//}

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

- (void) updatePagesType
{
	self.visiblePages = [[YHConfig instance] getVisibleYunHuoPages];
	NSMutableArray *titles = [NSMutableArray array];
	NSMutableArray *icons = [NSMutableArray array];
	for ( int i = 0; i < self.visiblePages.count; ++i )
	{
		YHYunHuoPageInfo *page = self.visiblePages[i];
		[titles addObject:page.name];
		[icons addObject:page.icon];
	}
	self.visiblePagesTitles = [NSArray arrayWithArray:titles];
	self.visiblePagesIcons = [NSArray arrayWithArray:icons];
	
	[self.pageSegmentControl doInit];
}

#pragma mark - HYSegmentedControlDelegate
- (void) hySegmentedControlSelectAtIndex:(NSInteger)index
{
	YHYunHuoPageInfo *info = self.visiblePages[index];
	NSString *controllerStr = info.pageControllerClass;
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
	return self.visiblePagesTitles;
}

- (IBAction) reorderViewOut:(id)sender
{
	YHYunHuoPageOrderViewController * orderVC = [[YHYunHuoPageOrderViewController alloc] init];
	[self presentViewController:orderVC animated:YES completion:nil];
}

@end
