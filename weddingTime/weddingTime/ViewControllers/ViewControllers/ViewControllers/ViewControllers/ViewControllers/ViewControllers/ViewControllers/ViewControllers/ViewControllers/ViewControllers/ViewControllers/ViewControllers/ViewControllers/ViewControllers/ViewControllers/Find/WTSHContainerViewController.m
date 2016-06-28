//
//  WTSHContainerViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTSHContainerViewController.h"
#import "WTSHViewController.h"
#import "WTFilterCityViewController.h"
#import "WTFilterHotelViewController.h"
#import "WTSearchViewController.h"
#import "WTTopView.h"
@interface WTSHContainerViewController () <WTTopViewDelegate,SearchScreeningContentViewDelegate,FilterSelectDelegate>
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic, strong) WTSHViewController *postViewController;
@property (nonatomic, strong) WTSHViewController *suppViewController;
@property (nonatomic, strong) HotelOrSupplierListFilters *filters;
@property (nonatomic, copy) NSString *syn_id;
@end

@implementation WTSHContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.filters = [HotelOrSupplierListFilters defaultFilters];
	self.filters.city_id = [UserInfoManager instance].curCityId;
	self.filters.isFromFilters = YES;

	_topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeFilter),@(WTTopViewTypeSearch),@(WTTopViewTypeSegment)]];
	_topView.delegate = self;
	[self.view addSubview:_topView];

	_postViewController = [WTSHViewController new];
	[self addChildViewController:_postViewController];
	_suppViewController = [WTSHViewController new];
	[self addChildViewController:_suppViewController];

	if(_supplier_type == WTWeddingTypeHotel){
		_topView.segmentCon.selectedSegmentIndex = WTSegmentTypeSupplier;
		_topView.segmentCon.hidden = YES;
	}

	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)loadData
{
	if(_topView.segmentCon.selectedSegmentIndex == WTSegmentTypePost){
		_postViewController.supplier_type = _supplier_type;
        _postViewController.segmentType = WTSegmentTypePost;
		[self.view insertSubview:_postViewController.view belowSubview:_topView];
	}else{
		_suppViewController.supplier_type = _supplier_type;
        _suppViewController.segmentType = WTSegmentTypeSupplier;
		[self.view insertSubview:_suppViewController.view belowSubview:_topView];
	}
}

#pragma mark - TopViewDelegate
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedSegment:(UISegmentedControl *)segment
{
	[self loadData];
}

- (void)topView:(WTTopView *)topView didSelectedFilter:(UIControl *)likeButton
{
	if(_topView.segmentCon.selectedSegmentIndex == WTSegmentTypePost){
		WTFilterCityViewController *synFilter = [[WTFilterCityViewController alloc] init];
		synFilter.delegate = self;
		synFilter.type = WTFliterTypePost;
		synFilter.synOrCityID = _syn_id;
		[self.navigationController presentViewController:synFilter animated:YES completion:nil];
	}else if (self.supplier_type == WTWeddingTypeHotel && _topView.segmentCon.selectedSegmentIndex == WTSegmentTypeSupplier) {
		WTFilterHotelViewController *hotelFilter = [[WTFilterHotelViewController alloc] init];
		hotelFilter.delegate = self;
		hotelFilter.filters = self.filters;
		[self.navigationController presentViewController:hotelFilter animated:YES completion:nil];
	} else if(self.supplier_type != WTWeddingTypeHotel && _topView.segmentCon.selectedSegmentIndex == WTSegmentTypeSupplier) {
		WTFilterCityViewController *synFilter = [[WTFilterCityViewController alloc] init];
		synFilter.delegate = self;
		synFilter.type = WTFliterTypeSupplier;
		synFilter.synOrCityID = _syn_id;
		[self.navigationController presentViewController:synFilter animated:YES completion:nil];
	}
}

- (void)topView:(WTTopView *)topView didSelectedSearch:(UIControl *)likeButton
{
	SearchType type = SearchTypeSupplier;
	if(_topView.segmentCon.selectedSegmentIndex == WTSegmentTypePost){
		type = SearchTypeSupplier;
	}
	else if (self.supplier_type == WTWeddingTypeHotel){
		type = SearchTypeHotel;
	}else{
		type = SearchTypeSupplier;
	}
	[self.navigationController pushViewController:[WTSearchViewController instanceSearchVCWithType:type] animated:YES];
}

#pragma mark - FilterDelegate
- (void)synFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index
{
	_syn_id = info;
	[self filterData];
}

- (void)didChooseScreening:(HotelOrSupplierListFilters *)filters
{
	_filters = filters;
	[self filterData];
}

- (void)filterData
{
	[_postViewController filterDataWithSType:_supplier_type
									 segType:_topView.segmentCon.selectedSegmentIndex
									   synID:_syn_id
									 filters:_filters];
	[self.view insertSubview:_postViewController.view belowSubview:_topView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
