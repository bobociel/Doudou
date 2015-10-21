//
//  AskViewController.m
//  nihao
//
//  Created by HelloWorld on 6/12/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskViewController.h"
#import "AskCategoryCell.h"
#import "AskCategoryDetailViewController.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "AskCategory.h"
#import "BaseFunction.h"

@interface AskViewController () <UITableViewDelegate, UITableViewDataSource> {
	ListingLoadingStatusView *_loadingStatus;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString *CellReuseIdentifier = @"AskCategoryCell";

@implementation AskViewController {
	// Ask 分类数据数组
    NSMutableArray *askCategoriesArray;
	NSInteger page;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Ask";
    [self dontShowBackButtonTitle];
	
	askCategoriesArray = [[NSMutableArray alloc] init];
	page = 1;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AskCategoryCell" bundle:nil] forCellReuseIdentifier:CellReuseIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 81.0;
	// 添加下拉刷新
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshAskCategoryList) loadMoreAction:@selector(loadMoreAskCategoryList) target:self];
	self.tableView.footer.hidden = YES;
	
	[self initLoadingViews];
	[self requestAskCategoryList];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

// 初始化加载视图
- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	__weak AskViewController *weakSelf = self;
	_loadingStatus.refresh = ^() {
		__strong AskViewController *strongSelf = weakSelf;
		[strongSelf requestAskCategoryList];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
	self.tableView.hidden = YES;
}

#pragma mark - Network
#pragma mark 获取 Ask 分类列表
- (void)requestAskCategoryList {
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"page", @"rows", @"random"]];
	[HttpManager requestAskCategoryListByParameters:(NSDictionary *)parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			if (page == 1) {
				[askCategoriesArray removeAllObjects];
			}
			
			NSArray *tempArray = [AskCategory objectArrayWithKeyValuesArray:resultDict[@"result"][@"rows"]];
			[askCategoriesArray addObjectsFromArray:tempArray];
			
			if (tempArray.count < DEFAULT_REQUEST_DATA_ROWS_INT) {// 没有更多数据
				self.tableView.footer.hidden = YES;
			} else {// 可能还有更多数据
				self.tableView.footer.hidden = NO;
			}
			
			if (askCategoriesArray.count > 0) {
				self.tableView.hidden = NO;
				[_loadingStatus showWithStatus:Done];
			} else {
				self.tableView.hidden = YES;
				[_loadingStatus showWithStatus:Empty];
			}
			
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
			
			[self.tableView reloadData];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[_loadingStatus showWithStatus:NetErr];
	}];
}

- (void)refreshAskCategoryList {
	page = 1;
	[self requestAskCategoryList];
}

- (void)loadMoreAskCategoryList {
	page++;
	[self requestAskCategoryList];
}

#pragma mark - UITabBarDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return askCategoriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AskCategoryCell *cell = (AskCategoryCell  *)[tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    [cell initCellViewWithAskCategory:[askCategoriesArray objectAtIndex:indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AskCategoryDetailViewController *askCategoryDetailViewController = [[AskCategoryDetailViewController alloc] init];
    askCategoryDetailViewController.askCategory = [askCategoriesArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:askCategoryDetailViewController animated:YES];
}

#pragma mark -
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
