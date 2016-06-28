//
//  WTProcessViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTProcessViewController.h"
#import "SetDefaultWeddingTimeViewController.h"
#import "WTCreateProcessViewController.h"
#import "WTProcessCell.h"
#import "SharePopView.h"
#import "AlertViewWithBlockOrSEL.h"
#define kTHeadViewheight 65.0
#define kViewHeight 50.0
#define kLabelWidth 120
@interface WTProcessViewController () <UITableViewDelegate,UITableViewDataSource,WTProcessCellDelegate>
@property (nonatomic,assign) BOOL showProcess;
@property (nonatomic,strong) SharePopView   *shareView;
@property (nonatomic,strong) UISwitch       *switchBtn;
@property (nonatomic,strong) UIButton       *createBtn;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation WTProcessViewController

+ (instancetype)instanceWithShow:(BOOL)showProcess
{
	WTProcessViewController *VC = [WTProcessViewController new];
	VC.showProcess = showProcess;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setupView];
	[self loadData];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getProcessListWithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
		if(!error && result[@"success"]){
			NSArray *descArray = [NSArray modelArrayWithClass:[WTWeddingProcess class] json:result[@"data"][@"process_list"]];
			_dataArray = [NSMutableArray arrayWithArray:descArray];
			[_tableView reloadData];
			_switchBtn.on = [result[@"data"][@"enable"] boolValue];
			if(_dataArray.count == 0){
				[NetWorkingFailDoErr errWithView:self.tableView content:@"点击创建婚礼流程" tapBlock:^{
					[self rightNavBtnEvent];
				}];
			}
		}else{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@"网络出错，请稍后重试"];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.tableView];
			[NetWorkingFailDoErr errWithView:self.tableView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

#pragma mark - Action
- (void)shareAction:(UIButton *)sender
{
	if(_dataArray.count == 0){
		WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"还没有添加婚礼流程" centerImage:nil];
		[alertView setButtonTitles:@[@"关闭"]];
		[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
			[alertView close];
		}];
		[alertView show];
		return ;
	}
	self.shareView = [SharePopView viewWithhareTypes:@[@(WTShareTypeWX),@(WTShareTypeQQ),@(WTShareTypeSina),@(WTShareTypeMessage)]];
	[self.shareView show];

	NSString *title = [NSString stringWithFormat:@"%@&%@的婚礼流程",[UserInfoManager instance].username_self,[UserInfoManager instance].username_partner];
	NSString *desc = [UserInfoManager instance].guestWords;
	NSString *userID = [UserInfoManager instance].userId_self;
	NSString *avatar = [UserInfoManager instance].avatar_self ?: kLogoToPushURL;
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:title
														andDescription:desc
															 andUrlStr:kWedProcessURL(userID)
														   andImageURL:avatar];
}

- (void)rightNavBtnEvent
{
	if([UserInfoManager instance].weddingTime == 0){
		[self.navigationController pushViewController:[SetDefaultWeddingTimeViewController new] animated:YES];
	}else{
		WTCreateProcessViewController *VC = [WTCreateProcessViewController new];
		[VC setRefreshBlock:^(BOOL refresh) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self loadData];
			});
		}];
		[self.navigationController pushViewController:VC animated:YES];
	}
}

- (void)onAction:(UISwitch *)sender
{
	[self showLoadingView];
	[PostDataService postShowWeddingProcess:sender.on callback:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(error || ![result[@"success"] boolValue]){
			sender.on = !sender.on;
			[WTProgressHUD ShowTextHUD:result[@"error_message"] ?: @"网络出错，请稍后重试" showInView:self.tableView];
		}else{
			if(_refreshBlock){ self.refreshBlock(sender.on); }
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
	WTWeddingProcess *process = _dataArray[indexPath.row];
	WTProcessCell *cell = [tableView WTProcessCell];
	cell.delegate = self;
	cell.process = process;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTWeddingProcess *process = _dataArray[indexPath.row];

	WTCreateProcessViewController *VC = [WTCreateProcessViewController instanceWithWeddingProcess:process];
	[VC setRefreshBlock:^(BOOL refresh) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self loadData];
		});
	}];
	[self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - Cell Delegate
- (void)WTProgressCell:(WTProcessCell *)cell didSelectDelete:(UIControl *)sender
{
	[self.view endEditing:YES];
	[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
	NSIndexPath *indexPath = [_tableView indexPathForCell:cell];

	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"删除婚礼流程" message:@"确定删除该条婚礼流程?" ];
	alertView.delegate = self;
	[alertView addOtherButtonWithTitle:@"删除" onTapped:^{
		[self showLoadingView];
		[PostDataService deleteWeddingProcessWithID:cell.process.ID callback:^(NSDictionary *result, NSError *error) {
			[self hideLoadingView];
			[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
			if(!error && result[@"success"]){
				[_dataArray removeObjectAtIndex:indexPath.row];
				[self.tableView reloadData];
				if(_dataArray.count == 0){
					[NetWorkingFailDoErr errWithView:self.tableView content:@"点击创建婚礼流程" tapBlock:^{
						[self rightNavBtnEvent];
					}];
				}
			}else{
				[WTProgressHUD ShowTextHUD:result[@"error_message"] ?: @"网络出错，请稍后重试" showInView:self.tableView];
			}
		}];
	}];
	[alertView setCancelButtonWithTitle:@"取消" onTapped:^{
		[_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
	}];
	[alertView show];
}

#pragma mark - View
- (void)setupView
{
	self.title = @"婚礼流程";
	[self setRightBtnWithTitle:@"添加"];

	_switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-50-15, 10, 50, 30)];
	_switchBtn.onTintColor = WeddingTimeBaseColor;
	_switchBtn.on = _showProcess;
	[self.view addSubview:_switchBtn];
	[_switchBtn addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventValueChanged];

	UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kLabelWidth, kViewHeight-22)];
	leftLabel.font = DefaultFont16;
	leftLabel.textColor = rgba(153, 153, 153, 1);
	leftLabel.text = @"在请柬中显示";
	[self.view addSubview:leftLabel];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, leftLabel.bottom+5, screenWidth, 4)];
	lineView.backgroundColor = rgba(247, 247, 247, 1);
	[self.view addSubview:lineView];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kViewHeight, screenWidth, screenHeight-kViewHeight-kNavBarHeight-kTabBarHeight)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	_createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_createBtn.frame = CGRectMake(0, _tableView.bottom, screenWidth, kTabBarHeight);
	_createBtn.backgroundColor = WeddingTimeBaseColor;
	_createBtn.titleLabel.font = DefaultFont16;
	[_createBtn setTitle:@"分享" forState:UIControlStateNormal];
	[_createBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_createBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
