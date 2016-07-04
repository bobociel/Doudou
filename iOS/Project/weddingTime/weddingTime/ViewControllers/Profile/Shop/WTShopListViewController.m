//
//  WTShopListViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTShopListViewController.h"
#import "WTShopDetailViewController.h"
#import "WTWeddingShopCell.h"
#import "MJRefresh.h"
#define kPageSize 12
@interface WTShopListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) WTWeddingType  type;
@property (nonatomic, assign) NSInteger      page;
@property (nonatomic, assign) NSInteger      subpage;
@property (nonatomic, copy)   NSString       *cityID;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation WTShopListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.dataArray = [NSMutableArray array];
	[self setupView];

	_tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadDataWithType:_type andCity:_cityID];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)loadDataWithType:(WTWeddingType)type andCity:(NSString *)cityID
{
	if(_cityID != cityID){
		_page = 1;
		_subpage = 0;
		_dataArray = [NSMutableArray array];
	}

	_cityID = cityID;
	_type = type;
	_page = _page ?: 1;
	if(_page == 1) { [self showLoadingView]; }
	[GetService getShopListWithType:_type andPage:_page andSubpage:_subpage andCityID:_cityID block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[self.tableView.footer endRefreshing];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
		if(!error && [result[@"success"] boolValue]){
			NSArray *shopArray = [NSArray modelArrayWithClass:[WTSupplierPost class] json:result[@"data"][@"post_list"]];
			[_dataArray addObjectsFromArray:shopArray];
			[self.tableView reloadData];

			_page = [result[@"data"][@"page"] integerValue];
			_subpage = [result[@"data"][@"sub_page"] integerValue];
			self.tableView.footer.hidden = shopArray.count < kPageSize && _subpage != 0;
			if(_dataArray.count == 0){
				[NetWorkingFailDoErr errWithView:self.tableView content:@"暂时没有数据" tapBlock:^{
					[self loadData];
				}];
			}
		}else{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.tableView];
			[NetWorkingFailDoErr errWithView:self.tableView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < _dataArray.count )
	{
		WTSupplierPost *post = _dataArray[indexPath.row];
		WTWeddingShopCell *cell = [tableView WTWeddingShopCell];
		cell.post = post;
		return cell;
	}

	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _dataArray.count) { return ; }
	WTSupplierPost *post = _dataArray[indexPath.row];
	[self.navigationController pushViewController:[WTShopDetailViewController instanceVCWithWrokID:post.ID] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 300 * Height_ato + 125;
}

#pragma mark - View
- (void)setupView
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-56) style:UITableViewStylePlain];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
