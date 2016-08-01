//
//  WeddingPlanListViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanListViewController.h"
#import "GetService.h"
#import "WeddingPlanDetailViewController.h"
#import "AlertViewWithBlockOrSEL.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "MJRefresh.h"
#define kTopViewHeight 44.0
#define kPageSize 15
@interface WeddingPlanListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation WeddingPlanListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
	self.dataArray = [NSMutableArray array];
	[self initView];
	[self loadDataShowHUD:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataShowHUD:) name:WeddingPlanShouldBeReloadNotify object:nil];
}

- (void)initView
{
	self.tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight - kTopViewHeight)];
	_tableView.tableFooterView = [[UIView alloc]init];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self loadDataShowHUD:NO];
		});
	}];

	self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self loadFooterData];
		});
	}];
}

- (void)loadDataShowHUD:(BOOL)isShow {
	if(isShow) { [self showLoadingView]; }
    [GetService getWeddingPlanListWithStatus:self.status andPage:1 WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:_tableView];
		[self.tableView.header endRefreshing];
		[self.tableView.footer endRefreshing];
		if(!error)
		{
			self.dataArray = [NSMutableArray array];
			NSArray *resultArray = [NSArray modelArrayWithClass:[WTMatter class] json:result[@"data"]];
			[_dataArray addObjectsFromArray:resultArray];
			[self.tableView reloadData];
			self.tableView.footer.hidden = [result[@"data"] count] < kPageSize;

			if(_dataArray.count == 0)
			{
				[NetWorkingFailDoErr errWithView:_tableView content:@"暂时没有数据哦" tapBlock:^{
					[self loadData];
				}];
			}
		}
		else
		{
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@"暂时没有数据哦"] showInView:_tableView];
			[NetWorkingFailDoErr errWithView:_tableView content:@"暂时没有数据哦" tapBlock:^{
				[self loadData];
			}];
		}
     }];
}

- (void)loadFooterData
{
	NSUInteger page = self.dataArray.count / kPageSize + 1;
	[GetService getWeddingPlanListWithStatus:self.status andPage:page WithBlock:^(NSDictionary *result, NSError *error) {
		[self.tableView.footer endRefreshing];
		if(!error)
		{
			NSArray *resultArray = [NSArray modelArrayWithClass:[WTMatter class] json:result[@"data"]];
			[_dataArray addObjectsFromArray:resultArray];
			[self.tableView reloadData];
			self.tableView.footer.hidden = resultArray.count < kPageSize;
		}
	}];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row < _dataArray.count)
	{
		WeddingPlanListCell *cell = [tableView WeddingPlanListCell];
		[cell setMatter:_dataArray[indexPath.row]];
		return cell;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_dataArray count]) {
        WeddingPlanDetailViewController *weddingPlanDetailViewController =
        [[WeddingPlanDetailViewController alloc] init];
        weddingPlanDetailViewController.matter = _dataArray[indexPath.row];
        [self.navigationController pushViewController:weddingPlanDetailViewController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self delegatePlan:indexPath];
    }
}

- (void)delegatePlan:(NSIndexPath *)indexPath {

	WTMatter *matter = _dataArray[indexPath.row];
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"删除待办事项" message:[NSString stringWithFormat:@"确定删除计划:'%@'?",matter.title ?: @"婚礼计划"]];
	alertView.delegate = self;
    [alertView addOtherButtonWithTitle:@"删除" onTapped:^{
         [self showLoadingView];
         [PostDataService postWeddingPlanDelegateWithMatterId:matter.matter_id ?: @"-1" withBlock:^(NSDictionary *result, NSError *error) {
             [self hideLoadingView];
             if (error) {
                 [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,请稍后再试"] showInView:self.view];
                 [_tableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationRight];
             }
			 else
			 {
				 [[WTLocalNoticeManager manager] removeNoticeWithClassType:[WTMatter class] andID:matter.matter_id];
				 NSString *content = [NSString stringWithFormat:@"我删除了计划（%@）",matter.title];
				 [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
					 if (ourCov)
					 {
						 NSDictionary *sendValue = @{@"id":matter.matter_id,@"type":@"p",@"title":content,@"data":[matter modelToJSONString] };
						 [ChatConversationManager sendCustomMessageWithPushName:content
														 andConversationTypeKey:ConversationTypeDeletePlan
														   andConversationValue:sendValue
																	andCovTitle:content
																   conversation:ourCov push:YES success:^{

																		} failure:^(NSError *error) {
																			
																		}];
					 }
				 }];

				[_dataArray removeObjectAtIndex:indexPath.row];
				[_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

				 if ([_dataArray count] < kPageSize) {
					 [self loadDataShowHUD:NO];
				 }
			}
         }];
     }];
    [alertView setCancelButtonWithTitle:@"取消" onTapped:^{
         [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
     }];
    [alertView show];
}

@end
