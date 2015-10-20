//
//  AskCategoryDetailViewController.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskCategoryDetailViewController.h"
#import "AskCategory.h"
#import "AskContent.h"
#import "AskHotHeaderView.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "HttpManager.h"
#import "AskCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NewAskViewController.h"
#import "SelectCityViewController.h"
#import "City.h"
#import "AppConfigure.h"
#import "AskDetailViewController.h"
#import "EmptyListView.h"

@interface AskCategoryDetailViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, AskHotHeaderViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) EmptyListView *emptyListView;
@property (nonatomic, assign) BOOL cellHeightCacheEnabled;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;
@property (strong, nonatomic) AskHotHeaderView *askHotHeaderView;

@end

static NSString *AskCellIdentifier = @"AskCell";

@implementation AskCategoryDetailViewController {
	// 热门问题数组
	NSArray *hotQuestionArray;
	// 非热门问题数组
	NSMutableArray *askQuestionArray;
	// 要获取第几页
	NSInteger page;
	// 搜索列表要获取第几页
	NSInteger searchResultPage;
	// 城市 ID
	NSString *areaID;
	// 请求数据字典
	NSDictionary *requestParameters;
	CGFloat tableHeaderViewHeight;
	// 是否正在搜索标记
	BOOL isSearching;
	// 选择的城市名字拼音
	NSString *selectedCityName;
	// 搜索的结果数组
	NSMutableArray *searchResultArray;
	// 保存点击的行
	NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.title = self.askCategory.akc_name;
	[self dontShowBackButtonTitle];
	// 设置导航栏按钮的点击执行方法等
	UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Ask" style:UIBarButtonItemStylePlain target:self action:@selector(askBtnClick)];
	NSArray *rightButtonItems = @[menuItem];
	self.navigationItem.rightBarButtonItems = rightButtonItems;
	
	self.cellHeightCacheEnabled = YES;
	askQuestionArray = [[NSMutableArray alloc] init];
	page = 1;
	searchResultPage = 1;
	areaID = @"";
	tableHeaderViewHeight = 0.0;
	isSearching = NO;
	searchResultArray = [[NSMutableArray alloc] init];
	selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
	
	[self initViews];
	[self requestAskHotQuestionList];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (selectedIndexPath.row >= 0 && !isSearching) {
		[self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// 初始化视图控件
- (void)initViews {
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	self.searchBar.delegate = self;
	[self.view addSubview:self.searchBar];
	self.searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	self.searchBarController.delegate = self;
	[self.searchBarController.searchResultsTableView registerNib:[UINib nibWithNibName:@"AskCell" bundle:nil] forCellReuseIdentifier:AskCellIdentifier];
	self.searchBarController.searchResultsDataSource = self;
	self.searchBarController.searchResultsDelegate = self;
	self.searchBarController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
	[BaseFunction addRefreshHeaderAndFooter:self.searchBarController.searchResultsTableView refreshAction:nil loadMoreAction:@selector(loadMoreSearchAskQuestionList) target:self];
	self.searchBarController.searchResultsTableView.header.hidden = YES;
	self.searchBarController.searchResultsTableView.footer.hidden = YES;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.estimatedRowHeight = 60;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView registerNib:[UINib nibWithNibName:@"AskCell" bundle:nil] forCellReuseIdentifier:AskCellIdentifier];
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshAskQuestionList) loadMoreAction:@selector(loadMoreAskQuestionList) target:self];
	self.tableView.footer.hidden = YES;
	[self.view addSubview:self.tableView];
	
	// 如果当前城市为nil，则使用默认服务城市
//	City *city = [City getCityFromUserDefault:CURRENT_CITY];
//	if(!city) {
//		city = [City getCityFromUserDefault:DEFAULT_CITY];
//		[City saveCityToUserDefault:city key:CURRENT_CITY];
//	}
//	areaID = [NSString stringWithFormat:@"%d", city.city_id];
//	selectedCityName = city.city_name_en;
	areaID = @"0";
	selectedCityName = @"Select City";
	
	// 初始化 TableView 提示 View
	self.emptyListView = [[EmptyListView alloc] init];
	self.emptyListView.hidden = YES;
	[self.tableView addSubview:self.emptyListView];
	
	[self initLoadingViews];
}

// 初始化加载中视图
- (void)initLoadingViews {
	// 初始化加载转圈圈的菊花
	self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicatorView.center = self.view.center;
	[self.view addSubview:self.activityIndicatorView];
	[self.activityIndicatorView startAnimating];
	self.tableView.hidden = YES;
	self.searchBar.hidden = YES;
}

// 初始化 Table HeaderView
- (void)initHeaderView {
	// 默认40的高度，只显示搜索栏
	self.askHotHeaderView = [[AskHotHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
	
	UIView *headerView;
	
	if (hotQuestionArray.count == 0) {
		// 如果没有 Hot Question，就只显示搜索栏和灰色分隔条
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
		headerView.clipsToBounds = YES;
		[headerView addSubview:self.askHotHeaderView];
	} else {
		// 如果有，则按照数量来显示 HeaderView
		NSInteger headerViewHeight = 80 + 40 * hotQuestionArray.count + 10;
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, headerViewHeight)];
		self.askHotHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerViewHeight - 10);
		// 添加 Question 行
		[self.askHotHeaderView configureViewWithHotQuestions:hotQuestionArray];
		[headerView addSubview:self.askHotHeaderView];
		// 添加灰色分隔条
		UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame) - 10, SCREEN_WIDTH, 10)];
		separateView.backgroundColor = ColorF4F4F4;
		[headerView addSubview:separateView];
	}
	
	tableHeaderViewHeight = CGRectGetHeight(headerView.frame);
	self.askHotHeaderView.delegate = self;
	[self.askHotHeaderView setSelectedCityName:selectedCityName];
	
	self.tableView.tableHeaderView = headerView;
}

- (void)postNewQuestion:(AskContent *)askConetnt {
	[askQuestionArray insertObject:askConetnt atIndex:0];
	self.emptyListView.hidden = YES;
	[self.tableView reloadData];
}

- (void)deletedAsk {
	[askQuestionArray removeObjectAtIndex:selectedIndexPath.row];
	[self.tableView reloadData];
	// 界面重新显示之后不用刷新第一行了
	selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
	if (askQuestionArray.count == 0) {
		// 显示列表为空提示
		[self showHintView];
	}
}

#pragma mark - network request
#pragma mark 获取 Hot Questions
- (void)requestAskHotQuestionList {
	NSString *askID = [NSString stringWithFormat:@"%ld", self.askCategory.akc_id];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSArray *objects;
	NSArray *keys;
	if (IsStringNotEmpty(areaID) && ![areaID isEqualToString:@"0"]) {
		objects = @[askID, areaID, random];
		keys = @[@"akc_id", @"aki_area", @"random"];
	} else {
		objects = @[askID, random];
		keys = @[@"akc_id", @"random"];
	}
	requestParameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	NSLog(@"requestParameters = %@", requestParameters);
	[HttpManager requestAskCategoryHotAskListByParameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			hotQuestionArray = [AskContent objectArrayWithKeyValuesArray:resultDict[@"result"][@"rows"]];
			[self initHeaderView];
			[self requestAskQuestionListByParameters:requestParameters];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

#pragma mark 获取 Ask Questions 列表
- (void)requestAskQuestionListByParameters:(NSDictionary *)parameters {
	NSString *pageString = [NSString stringWithFormat:@"%lu", page];
	NSMutableDictionary *newParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
	[newParameters setObject:pageString forKey:@"page"];
	[newParameters setObject:DEFAULT_REQUEST_DATA_ROWS forKey:@"rows"];
	
	[HttpManager requestAskCategoryAskListByParameters:newParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			if (page == 1) {
				[askQuestionArray removeAllObjects];
			}
            NSArray *array = [AskContent objectArrayWithKeyValuesArray:resultDict[@"result"][@"rows"]];
            if (array.count < DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = YES;
            } else {
                self.tableView.footer.hidden = NO;
            }
			[askQuestionArray addObjectsFromArray:array];
			
			if (askQuestionArray.count <= 0) {
				// 显示列表为空提示
				[self showHintView];
			} else {
				self.emptyListView.hidden = YES;
			}
			
			// TableView 不能隐藏，否则 HeaderView 无法显示，搜索栏也就无法显示
			self.tableView.hidden = NO;
			self.searchBar.hidden = NO;
			[self.tableView reloadData];
			
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
            
			[self.activityIndicatorView stopAnimating];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

#pragma mark 根据关键字获取 Ask 列表
- (void)requestAskListByKeyword:(NSString *)keyword {
	NSString *pageString = [NSString stringWithFormat:@"%lu", searchResultPage];
	NSMutableDictionary *newParameters = [[NSMutableDictionary alloc] initWithDictionary:requestParameters];
	[newParameters setObject:keyword forKey:@"akc_search"];
	[newParameters setObject:pageString forKey:@"page"];
	[newParameters setObject:DEFAULT_REQUEST_DATA_ROWS forKey:@"rows"];
	
	[HttpManager requestAskCategoryAskListByParameters:newParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			if (searchResultPage == 1) {
				[searchResultArray removeAllObjects];
			}
			
			searchResultArray = [AskContent objectArrayWithKeyValuesArray:resultDict[@"result"][@"rows"]];

			if (self.searchBarController.searchResultsTableView.footer.isRefreshing) {
				[self.searchBarController.searchResultsTableView.footer endRefreshing];
			}
			
			if (searchResultArray.count < DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.searchBarController.searchResultsTableView.footer.hidden = YES;
			} else {
				self.searchBarController.searchResultsTableView.footer.hidden = NO;
			}
			
			[self.searchBarController.searchResultsTableView reloadData];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

// 刷新问题列表
- (void)refreshAskQuestionList {
	page = 1;
	[self requestAskHotQuestionList];
}

// 加载更多问题
- (void)loadMoreAskQuestionList {
	page++;
	[self requestAskQuestionListByParameters:requestParameters];
}

// 加载更多的搜索问题
- (void)loadMoreSearchAskQuestionList {
	searchResultPage++;
	[self requestAskListByKeyword:self.searchBar.text];
}

// 显示提示视图
- (void)showHintView {
	self.emptyListView.hidden = NO;
	[self.emptyListView setHintText:@"Add a new ASK"];
}

#pragma mark - UITabBarDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!isSearching) {
		return askQuestionArray.count;
	} else {
		return searchResultArray.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AskCell *cell = (AskCell  *)[tableView dequeueReusableCellWithIdentifier:AskCellIdentifier forIndexPath:indexPath];
	[self configureCell:cell forRowAtIndexPath:indexPath];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.cellHeightCacheEnabled) {
		return [tableView fd_heightForCellWithIdentifier:AskCellIdentifier cacheByIndexPath:indexPath configuration:^(AskCell *cell) {
			[self configureCell:cell forRowAtIndexPath:indexPath];
		}];
	} else {
		return [tableView fd_heightForCellWithIdentifier:AskCellIdentifier configuration:^(AskCell *cell) {
			[self configureCell:cell forRowAtIndexPath:indexPath];
		}];
	}
}

- (void)configureCell:(AskCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	AskContent *askContent;
	
	if (!isSearching) {
		askContent = askQuestionArray[indexPath.row];
	} else {
		askContent = searchResultArray[indexPath.row];
	}
	
	[cell initCellViewWithAskContent:askContent];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	selectedIndexPath = indexPath;
	
	AskContent *askContent;
	if (!isSearching) {
		askContent = askQuestionArray[indexPath.row];
	} else {
		askContent = searchResultArray[indexPath.row];
	}
	
	if (askContent) {
		AskDetailViewController *askDetailViewController = [[AskDetailViewController alloc] init];
		askDetailViewController.askContent = askContent;
		askDetailViewController.questionID = [NSString stringWithFormat:@"%ld", askContent.aki_id];
		__weak typeof(self) weakSelf = self;
		askDetailViewController.deletedAsk = ^() {
			__strong typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf deletedAsk];
		};
		[self.navigationController pushViewController:askDetailViewController animated:YES];
	}
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *searchString = searchBar.text;
	[self requestAskListByKeyword:searchString];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.view bringSubviewToFront:self.tableView];
	isSearching = NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return NO;
}

#pragma mark - click events
// 发布新的 Ask
- (void)askBtnClick {
	NewAskViewController *newAskViewController = [[NewAskViewController alloc] init];
	newAskViewController.askCategory = self.askCategory;
	newAskViewController.currentCityName = selectedCityName;
	newAskViewController.currentCityID = [areaID integerValue];
	__weak typeof(self) weakSelf = self;
	newAskViewController.postAsk = ^(AskContent *askContent) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf postNewQuestion:askContent];
	};
	[self.navigationController pushViewController:newAskViewController animated:YES];
}

#pragma mark - AskHotHeaderViewDelegate
// 点击搜索问题
- (void)searchButtonClicked {
	[self.view bringSubviewToFront:self.searchBar];
	[self.searchBar becomeFirstResponder];
	isSearching = YES;
	searchResultPage = 1;
}

// 跳转到热门问题列表
- (void)moreHotQuestionsClicked {
	
}

// 选择城市
- (void)selectCityClicked {
	SelectCityViewController *selectCityViewController = [[SelectCityViewController alloc] init];
	selectCityViewController.askCategoryID = [NSString stringWithFormat:@"%ld", self.askCategory.akc_id];
//	selectCityViewController.currentCityName = selectedCityName;
//	selectCityViewController.currentCityID = [areaID integerValue];
	selectCityViewController.selectCityFromType = SelectCityFromTypeAskList;
	__weak typeof(self) weakSelf = self;
	selectCityViewController.selectedCity = ^(NSString *cityName, NSInteger cityID) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf selectedCityWithName:cityName cityID:cityID];
	};
	UINavigationController *nav = [self navigationControllerWithRootViewController:selectCityViewController navBarTintColor:AppBlueColor];
	[self presentViewController:nav animated:YES completion:nil];
}

- (void)hotQuestionSelectedAtIndex:(NSInteger)index {
	NSLog(@"%@ %ld", NSStringFromSelector(_cmd), index);
}

// 选择完城市之后刷新界面
- (void)selectedCityWithName:(NSString *)cityName cityID:(NSInteger)cityID {
	selectedCityName = cityName;
	areaID = [NSString stringWithFormat:@"%ld", cityID];
	[self.tableView.header beginRefreshing];
	[self refreshAskQuestionList];
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
