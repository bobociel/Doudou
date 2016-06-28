//
//  WTDeskViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/24.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDeskViewController.h"
#import "WTDeskCell.h"
#import "AlertViewWithBlockOrSEL.h"
#define kViewHeight 50.0
#define kLabelWidth 120
@interface WTDeskViewController () <UITableViewDelegate,UITableViewDataSource,WTDeskCellDelegate>
@property (nonatomic,assign) BOOL showDesk;
@property (nonatomic,strong) UISwitch *switchBtn;
@property (nonatomic,strong) UIButton *saveBtn;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation WTDeskViewController

+ (instancetype)instanceWithShow:(BOOL)showDesk
{
	WTDeskViewController *VC = [WTDeskViewController new];
	VC.showDesk = showDesk;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_dataArray = [NSMutableArray array];

	[self setupView];
	[self loadDataShowHUD:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardFrameChanged:(NSNotification *)noti
{
	CGRect keyFrame =  [(NSValue *)noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	if(keyFrame.origin.y == screenHeight){
		_tableView.frame = CGRectMake(0, kViewHeight, screenWidth, keyFrame.origin.y - kNavBarHeight-kTabBarHeight-kViewHeight);
	}else{
		[UIView animateKeyframesWithDuration:0.25 delay:0 options:7 animations:^{
			_tableView.frame = CGRectMake(0, kViewHeight, screenWidth, keyFrame.origin.y - kNavBarHeight - kViewHeight);
		} completion:nil];
	}
}

- (void)loadDataShowHUD:(BOOL)isShow
{
	if(isShow) { [self showLoadingView]; }
	[GetService getDeskListWithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
		if(!error && result[@"success"]){
			NSArray *descArray = [NSArray modelArrayWithClass:[WTWeddingDesk class] json:result[@"data"][@"seat_info"]];
			_dataArray = [NSMutableArray arrayWithArray:descArray];
			[_tableView reloadData];
			_switchBtn.on = [result[@"data"][@"enable_seat"] boolValue];
			if(_dataArray.count == 0){
				[NetWorkingFailDoErr errWithView:self.tableView content:@"点击创建座位表" tapBlock:^{
					[self rightNavBtnEvent];
				}];
			}
		}else{
			[self setRightBtnWithTitle:nil];
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.tableView];
			[NetWorkingFailDoErr errWithView:self.tableView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

- (void)saveAction:(UIButton *)sender
{
	[self showLoadingView];
	[PostDataService postWeddingDesks:_dataArray show:_switchBtn.on callback:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error && result[@"success"]){
			[WTProgressHUD ShowTextHUD:@"保存成功" showInView:nil];
			[self loadDataShowHUD:NO];
			if(self.refreshBlock) { self.refreshBlock(_switchBtn.on); }
			[self.navigationController popViewControllerAnimated:YES];
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
		}else{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.tableView];
		}
	}];
}

- (void)rightNavBtnEvent
{
	[self.view endEditing:YES];
	[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];

	NSInteger count = _dataArray.count;
	WTWeddingDesk *desk = [[WTWeddingDesk alloc] init];
	desk.ID = @"0";
	desk.sort = @(count+1).stringValue;
	[_dataArray addObject:desk];
	[self.tableView reloadData];
	[self.tableView scrollToRow:count inSection:0 atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTWeddingDesk *desk = _dataArray[indexPath.row];
	WTDeskCell *cell = [tableView WTDeskCell];
	cell.delegate = self;
	cell.descInfo = desk;
	cell.canDelete = _dataArray.count == (indexPath.row + 1);
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Cell Delegate
- (void)WTDeskCellDidBeignEdit:(WTDeskCell *)cell
{
	NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)WTDeskCell:(WTDeskCell *)cell didSelectedDelete:(UIControl *)sender
{
	[self.view endEditing:YES];
	[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
	NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"删除座位表" message:@"确定删除该条座位表?" ];
	alertView.delegate = self;
	[alertView addOtherButtonWithTitle:@"删除" onTapped:^{
		[self showLoadingView];
		[PostDataService deleteWeddingDeskWithID:cell.descInfo.ID callback:^(NSDictionary *result, NSError *error) {
			[self hideLoadingView];
			if(!error && result[@"success"]){
				[_dataArray removeObjectAtIndex:indexPath.row];
				[self.tableView reloadData];
				if(_dataArray.count == 0){
					[NetWorkingFailDoErr errWithView:self.tableView content:@"点击创建座位表" tapBlock:^{
						[self rightNavBtnEvent];
					}];
				}
			}else{
				NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
				[WTProgressHUD ShowTextHUD:errorContent showInView:self.tableView];
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
	self.title = @"座位表";
	[self setRightBtnWithTitle:@"添加"];

	_switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-50-15, 10, 50, 30)];
	_switchBtn.onTintColor = WeddingTimeBaseColor;
	_switchBtn.on = _showDesk;
	[self.view addSubview:_switchBtn];

	UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kLabelWidth, kViewHeight-22)];
	leftLabel.font = DefaultFont16;
	leftLabel.textColor = rgba(153, 153, 153, 1);
	leftLabel.text = @"在请柬中显示";
	[self.view addSubview:leftLabel];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kViewHeight, screenWidth, screenHeight-kViewHeight-kNavBarHeight-kTabBarHeight)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = rgba(247, 247, 247, 1);
	_tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	_saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_saveBtn.frame = CGRectMake(0, _tableView.bottom, screenWidth, kTabBarHeight);
	_saveBtn.backgroundColor = WeddingTimeBaseColor;
	_saveBtn.titleLabel.font = DefaultFont16;
	[_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
	[_saveBtn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_saveBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
