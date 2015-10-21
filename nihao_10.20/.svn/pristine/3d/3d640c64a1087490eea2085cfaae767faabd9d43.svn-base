//
//  CommonMerchantListViewController.m
//  nihao
//
//  Created by HelloWorld on 8/27/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "CommonMerchantListViewController.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "Merchant.h"
#import "ListingLoadingStatusView.h"
#import "BaseFunction.h"
#import "MerchantCell.h"
#import "HttpManager.h"
#import "City.h"
#import "AppConfigure.h"
#import "MerchantDetailsViewController.h"

@interface CommonMerchantListViewController () <UITableViewDelegate, UITableViewDataSource> {
	ListingLoadingStatusView *_loadingStatus;
}

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *CellReuseIdentifier = @"MerchantCell";

@implementation CommonMerchantListViewController
{
	// 商户列表
	NSMutableArray *merchantsArray;
	NSInteger page;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	if (self.commonMerchantListType == CommonMerchantListTypeRecommended) {
		self.title = @"Recommended merchant";
	} else {
		self.title = @"Newly Added Venues";
	}
	
	[self dontShowBackButtonTitle];
	
	merchantsArray = [[NSMutableArray alloc] init];
	page = 1;
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.rowHeight = 86.0;
	self.tableView.tableFooterView = [[UIView alloc] init];
	[self.tableView registerNib:[UINib nibWithNibName:@"MerchantCell" bundle:nil] forCellReuseIdentifier:CellReuseIdentifier];
	[self.view addSubview:self.tableView];
	
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshMerchantList) loadMoreAction:@selector(loadMoreMerchantList) target:self];
	self.tableView.footer.hidden = YES;
	
	[self initLoadingStatus];
	[self requestMerchantList];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_loadingStatus showWithStatus:Loading];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void) initLoadingStatus {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	__weak CommonMerchantListViewController *weakSelf = self;
	_loadingStatus.refresh = ^() {
		[weakSelf requestMerchantList];
	};
	[self.view addSubview:_loadingStatus];
}

- (void)processMerchantListByResult:(NSDictionary *)result {
	NSArray *tempArray = [Merchant objectArrayWithKeyValuesArray:[[result objectForKey:@"result"] objectForKey:@"rows"]];
	[merchantsArray addObjectsFromArray:tempArray];
	
	// 还能获取更多数据
	if (tempArray.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
		self.tableView.footer.hidden = NO;
	} else {// 已经获取全部数据
		self.tableView.footer.hidden = YES;
	}
	// 如果列表有数据
	if (merchantsArray.count > 0) {
		[_loadingStatus showWithStatus:Done];
		self.tableView.header.hidden = NO;
	} else {// 如果列表没有数据
		if (!_loadingStatus.superview) {
			[self.view addSubview:_loadingStatus];
		}
		[_loadingStatus showWithStatus:Empty];
		[_loadingStatus setEmptyImage:@"icon_no_shop" emptyContent:@"No result,recommend us a place you like" imageSize:NO_SHOP];
		self.tableView.footer.hidden = YES;
		self.tableView.header.hidden = YES;
	}
	
	if (self.tableView.footer.isRefreshing) {
		[self.tableView.footer endRefreshing];
	}
	if (self.tableView.header.isRefreshing) {
		[self.tableView.header endRefreshing];
	}
	
	[self.tableView reloadData];
}

#pragma mark - network request functions
#pragma mark 获取商家列表
- (void)requestMerchantList {
	if (self.commonMerchantListType == CommonMerchantListTypeRecommended) {
		[self requestRecommendedMerchantList];
	} else {
		[self requestNewAddMerchantList];
	}
}

#pragma mark 获取新加商户
- (void)requestNewAddMerchantList {
	NSDictionary *parameters = [self requestParameters];
	NSLog(@"request new add merchant list parameters = %@", parameters);
	
	[HttpManager requestNewlyAddMerchantListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			[self processMerchantListByResult:resultDict];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[_loadingStatus showWithStatus:NetErr];
	}];
}

#pragma mark 获取推荐商户
- (void)requestRecommendedMerchantList {
	NSDictionary *parameters = [self requestParameters];
	NSLog(@"request recommended merchant list parameters = %@", parameters);
	
	[HttpManager requestRecommendedMerchantListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			[self processMerchantListByResult:resultDict];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[_loadingStatus showWithStatus:NetErr];
	}];
}

#pragma mark 获取请求参数
- (NSDictionary *)requestParameters {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	NSString *cityName = [City getCityFromUserDefault:CURRENT_CITY].city_name;
	[parameters setObject:cityName forKey:@"mhi_city"];
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	[parameters setObject:pageString forKey:@"page"];
	[parameters setObject:DEFAULT_REQUEST_DATA_ROWS forKey:@"rows"];
	
	if ([self isLocateCitySameAsSelectedCity]) {
		NSString *latString = [NSString stringWithFormat:@"%lf", self.currentCoordinate.latitude];
		NSString *longString = [NSString stringWithFormat:@"%lf", self.currentCoordinate.longitude];
		[parameters setObject:latString forKey:@"ci_gpslat"];
		[parameters setObject:longString forKey:@"ci_gpslong"];
	}
	
	return parameters;
}

- (void)refreshMerchantList {
	page = 1;
	[self requestMerchantList];
}

- (void)loadMoreMerchantList {
	page++;
	[self requestMerchantList];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return merchantsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = (int)indexPath.row;
	// 通过标识来获取列表cell
	MerchantCell *cell = (MerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];
	[cell initCellWithMerchantData:merchantsArray[row]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self openMerchantDetailViewControllerWithMerchant:[merchantsArray objectAtIndex:indexPath.row]];
}

#pragma mark - Other Function
// 跳转到商户详情界面
- (void)openMerchantDetailViewControllerWithMerchant:(Merchant *)merchant {
	MerchantDetailsViewController *merchantDetailsViewController = [[MerchantDetailsViewController alloc] init];
	merchantDetailsViewController.merchantInfo = merchant;
	//	merchantDetailsViewController.navigationBarBackgroundHidden = YES;
	[self.navigationController pushViewController:merchantDetailsViewController animated:YES];
}

- (BOOL)isLocateCitySameAsSelectedCity {
	NSString *selectedCityName = [City getCityFromUserDefault:CURRENT_CITY].city_name_en;
	selectedCityName = [selectedCityName stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *locateCityName = [AppConfigure objectForKey:LOCATE_CITY];
	NSLog(@"selectedCityName = %@, locateCityName = %@", selectedCityName, locateCityName);
	
	if ([selectedCityName compare:locateCityName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
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
