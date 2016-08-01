//
//  LikeListViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTLikeListViewController.h"
#import "WTLikeChildViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTSearchViewController.h"
#import "LWUtil.h"
@interface WTLikeListViewController ()
{
    UISegmentedControl *likeSegmentedControl;
	WTLikeChildViewController *SupplierCommListViewController;
    WTLikeChildViewController *HotelCommListViewController;
	WTLikeChildViewController *PostCommListViewController;
    WTInspiretionListViewController *weddingInspiretionSearchListViewController;
}
@property (nonatomic, assign) SearchType searchType;
@end

@implementation WTLikeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"喜欢";

	likeSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"作品",@"服务商",@"酒店",@"灵感"]];
	likeSegmentedControl.frame = CGRectMake(0, 0, 0, 30);
	likeSegmentedControl.top = 75-64;
	likeSegmentedControl.left  = 10.f;
	likeSegmentedControl.width = screenWidth-2*likeSegmentedControl.left;
	likeSegmentedControl.selectedSegmentIndex = 0;
	likeSegmentedControl.tintColor = [[WeddingTimeAppInfoManager instance] baseColor];
	[likeSegmentedControl addTarget:self action:@selector(likeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:likeSegmentedControl];

	_searchType = NSNotFound;
	[self loadData];
}

- (void)rightNavBtnEvent
{
    [self.navigationController pushViewController:[WTSearchViewController instanceSearchVCWithType:_searchType] animated:YES];
}

- (void)likeSegmentedControlValueChanged:(UISegmentedControl *)segment
{
	if (likeSegmentedControl.selectedSegmentIndex == 0) {
		_searchType = NSNotFound;
	} else if(likeSegmentedControl.selectedSegmentIndex == 1) {
		_searchType = SearchTypeSupplier;
	} else if(likeSegmentedControl.selectedSegmentIndex == 2) {
		_searchType = SearchTypeHotel;
	}
	else if(likeSegmentedControl.selectedSegmentIndex == 3) {
		_searchType = SearchTypeInspiretion;
	}
	[self setRightBtnWithImage: _searchType == NSNotFound ? nil : [UIImage imageNamed:@"search"]];
    [self loadData];
}

- (void)loadData
{
    if(_searchType == SearchTypeSupplier)
    {
        if (!SupplierCommListViewController)
        {
            SupplierCommListViewController = [[WTLikeChildViewController alloc] init];
            SupplierCommListViewController.type = LikeTypeSupplier;
            [self addChildViewController:SupplierCommListViewController];
            SupplierCommListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
        }
        [self.view insertSubview:SupplierCommListViewController.view belowSubview:likeSegmentedControl];
    }
    if (_searchType == SearchTypeInspiretion)
    {
		if (!weddingInspiretionSearchListViewController)
		{
			weddingInspiretionSearchListViewController = [[WTInspiretionListViewController alloc] init];
			[self addChildViewController:weddingInspiretionSearchListViewController];
			weddingInspiretionSearchListViewController.showWithLike=YES;
			weddingInspiretionSearchListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
		}
		[self.view insertSubview:weddingInspiretionSearchListViewController.view belowSubview:likeSegmentedControl];
    }
    else if (_searchType == SearchTypeHotel )
    {
		if (!HotelCommListViewController)
		{
			HotelCommListViewController = [[WTLikeChildViewController alloc] init];
			HotelCommListViewController.type = LikeTypeHotel;
			[self addChildViewController:HotelCommListViewController];
			HotelCommListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
		}
		[self.view insertSubview:HotelCommListViewController.view belowSubview:likeSegmentedControl];
    }
	else if (_searchType == NSNotFound )
	{
		if (!PostCommListViewController)
		{
			PostCommListViewController = [[WTLikeChildViewController alloc] init];
			PostCommListViewController.type = LikeTypePost;
			[self addChildViewController:PostCommListViewController];
			PostCommListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
		}
		[self.view insertSubview:PostCommListViewController.view belowSubview:likeSegmentedControl];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
