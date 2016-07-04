//
//  WTTicketListViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTTicketListViewController.h"
#import "WTTicketDetailViewController.h"
#import "WTTicketCell.h"
#import "MJRefresh.h"
#define kPageSize 12
@interface WTTicketListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation WTTicketListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"提现记录";
	_dataArray = [NSMutableArray array];

	[self setupView];
	[self loadData];
//	_tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//		[self loadData];
//	}];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getUserWithdrewTicketListBlock:^(NSDictionary *result, NSError *error){
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
		if(!error && result[@"success"]){
			NSArray *ticketArray = [NSArray modelArrayWithClass:[WTTicket class] json:result[@"data"]];
			[_dataArray addObjectsFromArray:ticketArray];
			[_tableView reloadData];
			if(ticketArray.count == 0){
				[NetWorkingFailDoErr errWithView:self.view content:@"暂时没有数据" tapBlock:^{
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
	WTTicket *ticket = _dataArray[indexPath.row];
	WTTicketCell *cell = [tableView WTTicketCell];
	cell.ticket = ticket;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTTicket *ticket = _dataArray[indexPath.row];
	[self.navigationController pushViewController:[WTTicketDetailViewController instanceWithTicket:ticket] animated:YES];
}

#pragma mark - View
- (void)setupView
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	[self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
