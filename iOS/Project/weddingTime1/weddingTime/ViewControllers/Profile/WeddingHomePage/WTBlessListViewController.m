//
//  WDInviteListContainerViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBlessListViewController.h"
#import "WTInviteGuestViewController.h"
#import "BlessCell.h"
#import "WTNoDataCell.h"
#import "MJRefresh.h"
#import "GetService.h"
#import "PostDataService.h"
#define kPageSize      10
#define kButtonHeight 44.0
#define kNavBarHeight 64.0
#define kCustomCellHeight 120
@interface WTBlessListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation WTBlessListViewController
{
    NSMutableArray *blessArray;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[UserInfoManager instance].num_bless_readed = [UserInfoManager instance].num_bless;
	[[UserInfoManager instance] saveBlessCToUserDefaults];

    blessArray = [NSMutableArray array];
    [self initView];
	[self addInviteButton];
    [self loadDataShowHUD:YES];
	[self setupRefresh];
}

- (void)initView {
    self.title=@"发送请柬";
	[self.view addSubview:[[UIView alloc] init] ];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kButtonHeight - kNavBarHeight) style:UITableViewStylePlain];
	self.tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)addInviteButton
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	button.frame = CGRectMake(0, screenHeight-kButtonHeight-kNavBarHeight, screenWidth, kButtonHeight);
	[button setTitleColor:WHITE forState:UIControlStateNormal];
	[button setTitle:@"发送邀请" forState:UIControlStateNormal];
	button.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
	[button setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
	[self.view addSubview:button];
	[button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonAction
{
	[self.navigationController pushViewController:[WTInviteGuestViewController new] animated:YES];
}

#pragma mark - Refresh
- (void)loadDataShowHUD:(BOOL)show
{
	if(show){
		[self showLoadingView];
	}
	blessArray = [NSMutableArray array];
	self.tableView.footer.hidden = YES;
	[GetService getBlessListWithPage:1 WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[self.tableView.header endRefreshing];
		if (!error) {
			NSArray *blesses = [NSArray modelArrayWithClass:[WTBless class] json:result[@"data"]];
			blessArray =[NSMutableArray arrayWithArray:blesses];
			[self.tableView reloadData];
			self.tableView.footer.hidden = blessArray.count < kPageSize;
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
		NSInteger addPageCount = blessArray.count % kPageSize == 0 ? 1 : 2;
		NSInteger page = blessArray.count/kPageSize + addPageCount;
		[GetService getBlessListWithPage:page WithBlock:^(NSDictionary *result, NSError *error) {
			[self.tableView.footer endRefreshing];
			if(!error){
				NSArray *blesses = [NSArray modelArrayWithClass:[WTBless class] json:result[@"data"]];
				[blessArray addObjectsFromArray:blesses];
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
	return blessArray.count > 0 ? blessArray.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(blessArray.count == 0){
		WTNoDataCell *cell = [WTNoDataCell NoDataCellWithTableView:tableView];
		cell.noDataLabel.text = @"还没有收到回复";
		return cell;
	}
	else{
		BlessCell *cell = [tableView blessCell];
		cell.bless = blessArray[indexPath.row];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(blessArray.count > 0){
		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return blessArray.count > 0 ? kCustomCellHeight : screenHeight - kButtonHeight - kNavBarHeight;
}

#pragma mark TableViewEdit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return blessArray.count > 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		WTBless *bless = blessArray[indexPath.row];
		[GetService deleteBlessWith:bless.bless_id withBlock:^(NSDictionary *result, NSError *error) {
			if(!error){
				[blessArray removeObjectAtIndex:indexPath.row];
				if([UserInfoManager instance].num_bless_readed > 0)
				{
					[UserInfoManager instance].num_bless_readed -= 1;
					[UserInfoManager instance].num_bless -= 1;
					[[UserInfoManager instance] saveBlessCToUserDefaults];
				}
				if(blessArray.count > 0){
					[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				}else{
					[self.tableView reloadData];
				}
				[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
				if(blessArray.count < 5){
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
}

@end
