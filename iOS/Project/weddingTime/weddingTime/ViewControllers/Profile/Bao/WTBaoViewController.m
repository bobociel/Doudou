//
//  WTBaoViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTBaoViewController.h"
#import "WTTicketListViewController.h"
#import "WTTicketDetailViewController.h"
#import "WTTicketCell.h"
#import "WTTopView.h"
#import "UserInfoManager.h"
#import "GetService.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "MJRefresh.h"
#define kPageSize  8
#define kHeadViewHeight 200
#define kTextWidth  64
#define kTextHeight 15
#define kLineGap    7
#define kLineWidth  ((screenWidth - kTextWidth - 2*kLineGap) / 2.0)
@interface WTBaoViewController () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate,WTTopViewDelegate>
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *descLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *dataSArray;
@property (strong, nonatomic) WTTopView  *topView;
@property (copy, nonatomic) NSString  *withdrawingCount;
@property (copy, nonatomic) NSString  *withdrewCount;
@end

@implementation WTBaoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.dataArray = [NSMutableArray array];
	self.dataSArray = [NSMutableArray array];

	[self setupView];
	[self loadMoreData];
	self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadMoreData];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	_topView.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];
	BOOL show = _dataSArray.count == 0;
	[self loadDataShowHUD:show];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)loadDataShowHUD:(BOOL)show
{
	if(show) { [self showLoadingView]; }
	[GetService getUserTicketListWithPage:0 flag:@"used" block:^(NSDictionary *result, NSError *error){
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:_tableView];
		if(!error && [result[@"success"] boolValue]){
			_withdrawingCount = result[@"data"][@"balance"];
			_withdrewCount = result[@"data"][@"withdraw"];
			NSArray *ticketArray = [NSArray modelArrayWithClass:[WTTicket class] json:result[@"data"][@"used"]];
			_dataArray = [NSMutableArray arrayWithArray:ticketArray];
			[self.tableView reloadData];
			[self updateInfo];
			[NetWorkingFailDoErr removeAllErrorViewAtView:_tableView];
			if(_dataArray.count == 0 && _dataSArray.count == 0){
				[NetWorkingFailDoErr errWithView:_tableView content:@"尚未领取婚礼宝优惠" tapBlock:^{
				}];
			}
		}else{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
		}
	}];
}

- (void)loadMoreData
{
	NSInteger page = ceil(_dataSArray.count/(kPageSize * 1.0) ) + 1;
	[GetService getUserTicketListWithPage:page flag:@"" block:^(NSDictionary *result, NSError *error) {
		[self.tableView.footer endRefreshing];
		if(!error && [result[@"success"] boolValue]){
			NSArray *tickets = [NSArray modelArrayWithClass:[WTTicket class] json:result[@"data"]];
			[_dataSArray addObjectsFromArray:tickets];
			[self.tableView reloadData];
			self.tableView.footer.hidden = tickets.count < kPageSize;
			[NetWorkingFailDoErr removeAllErrorViewAtView:_tableView];
			if(_dataArray.count == 0 && _dataSArray.count == 0){
				[NetWorkingFailDoErr errWithView:_tableView content:@"尚未领取婚礼宝优惠" tapBlock:^{
				}];
			}
		}
	}];
}

- (void)updateInfo
{
	_priceLabel.text = [LWUtil stringWithPrice:[LWUtil getString:_withdrawingCount andDefaultStr:@"0"]];
	_descLabel.text = [NSString stringWithFormat:@"已提现%@元",[LWUtil getString:_withdrewCount andDefaultStr:@"0"]];
}

#pragma mark - TopViewDelegate
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedSetBG:(UIControl *)chatButton
{
	[self.navigationController pushViewController:[WTTicketListViewController new] animated:YES];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(_dataArray.count > 0 && _dataSArray.count > 0 ){
		return 2;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(_dataArray.count > 0 && _dataSArray.count > 0){
		return section == 0 ? _dataArray.count : _dataSArray.count;
	}
	return _dataArray.count + _dataSArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTTicket *ticket = nil;
	if(_dataArray.count > 0 && _dataSArray.count > 0){
		ticket = indexPath.section == 0 ? _dataArray[indexPath.row] : _dataSArray[indexPath.row];
	}else{
		ticket = _dataSArray.count > 0 ? _dataSArray[indexPath.row] : _dataArray[indexPath.row] ;
	}
	WTTicketCell *cell = [tableView WTTicketCell];
	if(ticket) { cell.ticket = ticket; }
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTTicket *ticket = nil;
	if(_dataArray.count > 0 && _dataSArray.count > 0){
		ticket = indexPath.section == 0 ? _dataArray[indexPath.row] : _dataSArray[indexPath.row];
	}else{
		ticket = _dataSArray.count > 0 ? _dataSArray[indexPath.row] : _dataArray[indexPath.row] ;
	}

	if(ticket)
	{
		WTTicketDetailViewController *VC = [WTTicketDetailViewController instanceWithTicket:ticket];
		[VC setUsedBlock:^(WTTicket *ticket) {
			self.dataArray = [NSMutableArray array];
			[self.dataSArray removeObject:ticket];
			[self loadData];
		}];
		[VC setRefreshBlock:^(WTTicket *ticket) {
			self.dataArray = [NSMutableArray array];
			[self loadData];
		}];
		[self.navigationController pushViewController:VC animated:YES];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
	headView.clipsToBounds = YES;
	if( (section == 1 && _dataSArray.count>0 && _dataArray.count>0) || (section == 0 && _dataArray.count == 0) ){
		headView.height = 55.0;
		UILabel *dLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth - kTextWidth)/2, 20, kTextWidth, 15)];
		dLabel.font = DefaultFont12;
		dLabel.textColor = rgba(166, 166, 166, 1);
		dLabel.textAlignment = NSTextAlignmentCenter;
		[headView addSubview:dLabel];
		dLabel.text = @"未使用";

		UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(kLineGap, 55/2.0, kLineWidth, 1)];
		leftLineView.backgroundColor = rgba(232, 232, 232, 1);
		[headView addSubview:leftLineView];

		UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - kLineGap -kLineWidth, 55/2.0, kLineWidth, 1)];
		rightLineView.backgroundColor = rgba(232, 232, 232, 1);
		[headView addSubview:rightLineView];
	}
	return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(_dataSArray.count > 0 && _dataArray.count > 0){
		return section == 1 ? 55 : 0.1;
	}else if (_dataSArray.count > 0 ){
		return 55;
	}
	return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.1;
}

#pragma mark - View
- (void)setupView
{
	[self showBlurBackgroundView];
	[self setupHeadView];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeadViewHeight, screenWidth, screenHeight - kHeadViewHeight) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	[self.view addSubview:_tableView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeSetBG)]];
	[self.topView.setBGButton setTitle:@"已提现" forState:UIControlStateNormal];
	self.topView.delegate = self;
	[self.view addSubview:_topView];
}

- (void)setupHeadView
{
	_headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kHeadViewHeight)];
	_headView.backgroundColor = rgba(0, 0, 0, 0.1);
	[self.view addSubview:_headView];

	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, screenWidth, 21)];
	_titleLabel.font = DefaultFont18;
	_titleLabel.textColor = WHITE;
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.text = @"婚礼宝";
	[_headView addSubview:_titleLabel];

	UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.bottom + 35, screenWidth, 13)];
	dotLabel.font = DefaultFont12;
	dotLabel.textColor = WHITE;
	dotLabel.textAlignment = NSTextAlignmentCenter;
	dotLabel.text = @"可提现";
	[_headView addSubview:dotLabel];

	_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.bottom + 50, screenWidth, 39)];
	_priceLabel.font = DefaultFont30;
	_priceLabel.textColor = WHITE;
	_priceLabel.textAlignment = NSTextAlignmentCenter;
	[_headView addSubview:_priceLabel];

	_descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _priceLabel.bottom + 22, screenWidth, 17)];
	_descLabel.font = DefaultFont14;
	_descLabel.textColor = WHITE;
	_descLabel.textAlignment = NSTextAlignmentCenter;
	[_headView addSubview:_descLabel];

	[self updateInfo];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


@end
