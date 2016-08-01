//
//  DemandViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTDemandListViewController.h"
#import "WTCreateDemandViewController.h"
#import "WTDemandDetailViewController.h"
#import "WTDemandListCell.h"
#import "GetService.h"
#import "UserInfoManager.h"
#import "WTProgressHUD.h"
#import "AlertViewWithBlockOrSEL.h"
#import "MJRefresh.h"
#define kPageSize 12
@interface WTDemandListViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WTDemandListViewController
{
    UITableView *demandTableView;
    NSMutableDictionary *resultDic;
    NSMutableArray      *dataArr;
    UILabel             *findTypeLabel;
    UILabel             *stateLabel;
    UILabel             *priceLabel;
    NSDictionary        *serviceTypeId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
}

- (void)initView
{
    self.title = @"我的需求";
	dataArr = [NSMutableArray array];
	
    demandTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight) style:UITableViewStylePlain];
    demandTableView.dataSource = self;
    demandTableView.delegate = self;
    demandTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    demandTableView.backgroundColor = [UIColor whiteColor];
    demandTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:demandTableView];

	[self setRightBtnWithImage:[UIImage imageNamed:@"add_nav"]];

	[self loadData];
	demandTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		[self loadData];
	}];
}

-(void)loadData
{
	NSInteger page = ceil(dataArr.count / kPageSize * 1.0) + 1;
	if(page == 1) { [self showLoadingView]; }
	[GetService getDemandListWithPage:page block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[demandTableView.footer endRefreshing];
		[NetWorkingFailDoErr removeAllErrorViewAtView:demandTableView];
		if(!error)
		{
			if(page == 1) { dataArr = [NSMutableArray array]; }
			NSArray *demandArray = [NSArray modelArrayWithClass:[WTDemand class] json:result[@"data"]];
			[dataArr addObjectsFromArray:demandArray];
			[demandTableView reloadData];
			demandTableView.footer.hidden = demandArray.count < 12.0;
			if(demandArray.count == 0 && page == 1)
			{
				[NetWorkingFailDoErr errWithView:demandTableView content:@"点击创建婚礼需求" tapBlock:^{
					[self rightNavBtnEvent];
				}];
			}
		}
		else
		{
			NSString *errMsg = [LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[NetWorkingFailDoErr errWithView:demandTableView content:errMsg tapBlock:^{
				dataArr = [NSMutableArray array];
				[self loadData];
			}];
		}
	}];
}

- (void)rightNavBtnEvent{
	WTCreateDemandViewController *createDemandVC =[WTCreateDemandViewController new];
	[createDemandVC setRefreshBlock:^(BOOL refresh) {
		dispatch_async(dispatch_get_main_queue(), ^{
			dataArr = [NSMutableArray array];
			[self loadData];
		});
	}];
	[self.navigationController pushViewController:createDemandVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 105;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"WTDemandListCell";
	WTDemand *demand = dataArr[indexPath.row];
	WTDemandListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil)
	{
		cell = [[WTDemandListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	cell.demand = demand;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTDemand *demand = dataArr[indexPath.row];
    WTDemandDetailViewController *detialVC = [WTDemandDetailViewController new];
    detialVC.rewardId = demand.ID;
    [self.navigationController pushViewController:detialVC animated:YES];
}

#pragma mark - TableViewEdit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self deleteDemand:indexPath];
}

- (void)deleteDemand:(NSIndexPath *)indexPath
{
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"删除需求"
																				message:@"确定删除该需求?" ];
	alertView.delegate = self;
	[alertView addOtherButtonWithTitle:@"删除" onTapped:^{
		[self showLoadingView];
		WTDemand *demand = dataArr[indexPath.row];
		[PostDataService deleteDemandWithDemandID:demand.ID callback:^(NSDictionary *result, NSError *error) {
			[self hideLoadingView];
			if(!error && [result[@"success"] boolValue])
			{
				[dataArr removeObjectAtIndex:indexPath.row];
				dataArr.count > 0 ? [demandTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic] : [demandTableView reloadData];
			}
			else
			{
				[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""] showInView:self.view];
			}
		}];
	}];
	[alertView setCancelButtonWithTitle:@"取消" onTapped:^{
		[demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}];
	[alertView show];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
