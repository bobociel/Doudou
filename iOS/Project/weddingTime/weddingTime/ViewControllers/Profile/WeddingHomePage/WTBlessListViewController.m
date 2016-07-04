//
//  WDInviteListContainerViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBlessListViewController.h"
#import "WTInviteGuestViewController.h"
#import "WTBlessCell.h"
#import "WTNoDataCell.h"
#import "MJRefresh.h"
#import "GetService.h"
#import "AlertViewWithBlockOrSEL.h"
#define kPageSize      10

@interface WTBlessListViewController ()<UITableViewDataSource, UITableViewDelegate,WTBlessCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *blessArray;
@end

@implementation WTBlessListViewController
- (void)viewDidLoad {
    [super viewDidLoad];

	[UserInfoManager instance].num_bless_readed = [UserInfoManager instance].num_bless;
	[[UserInfoManager instance] saveOtherToUserDefaults];

    _blessArray = [NSMutableArray array];
    [self initView];
    [self loadDataShowHUD:YES];
	[self setupRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)initView
{
    self.title = @"宾客回执";

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight - kNavBarHeight) style:UITableViewStylePlain];
	self.tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(0, screenHeight - kNavBarHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	shareButton.backgroundColor = WeddingTimeBaseColor;
	shareButton.titleLabel.font = DefaultFont16;
	[shareButton setTitle:@"去分享" forState:UIControlStateNormal];
	[self.view addSubview:shareButton];
	[shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareAction
{
	[self.navigationController pushViewController:[WTInviteGuestViewController new] animated:YES];
}

#pragma mark - Refresh
- (void)loadDataShowHUD:(BOOL)show
{
	if(show){
		[self showLoadingView];
	}
	_blessArray = [NSMutableArray array];
	self.tableView.footer.hidden = YES;
	[GetService getBlessListWithPage:1 WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[self.tableView.header endRefreshing];
		if (!error) {
			NSArray *blesses = [NSArray modelArrayWithClass:[WTWeddingBless class] json:result[@"data"]];
			_blessArray =[NSMutableArray arrayWithArray:blesses];
			[self.tableView reloadData];
			self.tableView.footer.hidden = _blessArray.count < kPageSize;
		} else {
			self.tableView.footer.hidden = YES;
			NSString *errorContent =[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
		}
	}];
}

- (void)setupRefresh
{
	self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		NSInteger page = _blessArray.count/kPageSize + 1;
		[GetService getBlessListWithPage:page WithBlock:^(NSDictionary *result, NSError *error) {
			[self.tableView.footer endRefreshing];
			if(!error){
				NSArray *blesses = [NSArray modelArrayWithClass:[WTWeddingBless class] json:result[@"data"]];
				[_blessArray addObjectsFromArray:blesses];
				[self.tableView reloadData];
				self.tableView.footer.hidden = blesses.count < kPageSize;
			}else{
				self.tableView.footer.hidden = YES;
				NSString *errorContent =[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
				[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
			}
		}];
	}];
}

#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _blessArray.count > 0 ? _blessArray.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_blessArray.count == 0)
	{
		WTNoDataCell *cell = [WTNoDataCell NoDataCellWithTableView:tableView];
		cell.noDataLabel.text = @"还没有收到回复";
		return cell;
	}
	else
	{
		WTBlessCell *cell = [tableView WTBlessCell];
		cell.delegate = self;
		cell.bless = _blessArray[indexPath.row];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_blessArray.count > 0){
		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_blessArray.count > 0){
		WTWeddingBless *bless = _blessArray[indexPath.row];
		return [WTBlessCell cellHeightWithContent:bless.bless];
	}
	return screenHeight - kTabBarHeight - kNavBarHeight;
}

#pragma mark TableViewEdit
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return _blessArray.count > 0;
//}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//	{
//		[self deleteBless:indexPath];
//    }
//}

- (void)WTBlessCell:(WTBlessCell *)cell didSelectedDelete:(UIControl *)sender
{
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]  initWithTitle:@"删除祝福" message:@"确定删除该祝福?" ];
	alertView.delegate = self;
	[alertView addOtherButtonWithTitle:@"删除" onTapped:^{
		[self deleteBless:[_tableView indexPathForCell:cell]];
	}];
	[alertView setCancelButtonWithTitle:@"取消" onTapped:^{
		[_tableView reloadRowsAtIndexPaths:@[[_tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationRight];
	}];
	[alertView show];
}

- (void)deleteBless:(NSIndexPath *)indexPath
{
	if(!indexPath || _blessArray.count == 0) { return ; }
	WTWeddingBless *bless = _blessArray[indexPath.row];
	[self showLoadingView];
	[GetService deleteBlessWith:bless.bless_id withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error){
			[_blessArray removeObjectAtIndex:indexPath.row];
			if([UserInfoManager instance].num_bless_readed > 0)
			{
				[UserInfoManager instance].num_bless_readed -= 1;
				[UserInfoManager instance].num_bless -= 1;
				[[UserInfoManager instance] saveOtherToUserDefaults];
			}
			if(_blessArray.count > 0){
				[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			}else{
				[self.tableView reloadData];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
			if(_blessArray.count < kPageSize){
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self loadDataShowHUD:NO];
				});
			}
		}
		else{
			NSString *errorString = [LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorString showInView:self.view];
		}
	}];
}

@end
