//
//  WTBudgetViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTBudgetViewController.h"
#import "WTSettingViewController.h"
#import "WTChatListViewController.h"
#import "WTLikeListViewController.h"
#import "WTBudgetCell.h"
#import "WTTopView.h"
#import "UserInfoManager.h"
#import "GetService.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#define kHeadViewHeight 200
@interface WTBudgetViewController () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate,WTBudgetCellDelegate,WTTopViewDelegate>
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UILabel *budgetTitleLabel;
@property (strong, nonatomic) UILabel *budgePriceLabel;
@property (strong, nonatomic) UILabel *budgeDescLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) WTTopView  *topView;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *keyArray;
@property (strong, nonatomic) WTBudget *budget;
@end

@implementation WTBudgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	_budget = [WTBudget new];
	_budget.budget = [WTBudgetDetail modelWithDictionary:[UserInfoManager instance].budgetInfo];

	_titleArray = [@[@"婚礼策划",@"婚纱写真",@"婚礼跟拍",@"婚礼主持",@"婚纱礼服",@"新娘跟妆",@"婚礼摄像",@"婚宴酒店"] mutableCopy];
	_keyArray = [@[@(WTWeddingTypePlan).stringValue,@(WTWeddingTypePhoto).stringValue,@(WTWeddingTypeCapture).stringValue,@(WTWeddingTypeHost).stringValue,@(WTWeddingTypeDress).stringValue,@(WTWeddingTypeMakeUp).stringValue,@(WTWeddingTypeVideo).stringValue,@(WTWeddingTypeHotel).stringValue] mutableCopy];
	[self setupView];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	_topView.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)loadData
{
    [self showLoadingView];
    [GetService getBudgetBlock:^(NSDictionary *result, NSError *error){
        [self hideLoadingView];
        if(!error && result[@"success"]){
			 _budget = [WTBudget modelWithDictionary:result[@"data"]];
			[UserInfoManager instance].budgetInfo = [_budget.budget modelToJSONObject];
			[[UserInfoManager instance] saveOtherToUserDefaults];
			[_tableView reloadData];
			[self countBudgetAction];
		}
	 }];
}

- (void)countBudgetAction
{
	_budgePriceLabel.attributedText = [LWUtil attributeStringWithAllBudget:_budget.budget.budget_cost];
}

- (void)saveBudget
{
    [self showLoadingView];
    [PostDataService putBudgetWithInfo:[_budget.budget modelToJSONObject] withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if(!error && result[@"success"]){
            [UserInfoManager instance].budgetInfo = [_budget.budget modelToJSONObject];
            [[UserInfoManager instance] saveOtherToUserDefaults];
			if(_refreshBlock){ _refreshBlock(YES); }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [WTProgressHUD ShowTextHUD:@"保存失败" showInView:_tableView];
        }
    }];
}

#pragma mark - TopViewDelegate
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedChat:(UIControl *)chatButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTChatListViewController new] animated:YES];
	}
}

- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTLikeListViewController new] animated:YES];
	}
}

- (void)WTBudgetCell:(WTBudgetCell *)cell priceChanged:(NSString *)price
{
	switch (cell.wedType) {
		case WTWeddingTypePlan:{ _budget.budget.planBudget = cell.price;  } break;
		case WTWeddingTypePhoto:{ _budget.budget.photoBudget = cell.price; } break;
		case WTWeddingTypeCapture:{ _budget.budget.captureBudget = cell.price; } break;
		case WTWeddingTypeHost:{ _budget.budget.hostBudget = cell.price ;} break;
		case WTWeddingTypeDress:{ _budget.budget.dressBudget = cell.price; } break;
		case WTWeddingTypeMakeUp:{ _budget.budget.makeUpBudget = cell.price; } break;
		case WTWeddingTypeVideo:{ _budget.budget.videoBudget = cell.price; } break;
		case WTWeddingTypeHotel:{ _budget.budget.hotelBudget = cell.price; } break;
		default: break;
	}
	[self countBudgetAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTBudgetInfo *budgetInfo = [WTBudgetInfo new];
	WTBudgetCell *cell = [tableView WTBudgetCell];
	cell.delegate = self;
	cell.wedType = [_keyArray[indexPath.row] integerValue];
	cell.descLabel.text = _titleArray[indexPath.row];
	switch (cell.wedType) {
		case WTWeddingTypePlan:{ cell.price = _budget.budget.planBudget; budgetInfo = _budget.service_price.planBudgetInfo; } break;
		case WTWeddingTypePhoto:{ cell.price = _budget.budget.photoBudget; budgetInfo = _budget.service_price.photoBudgetInfo; } break;
		case WTWeddingTypeCapture:{ cell.price = _budget.budget.captureBudget; budgetInfo = _budget.service_price.captureBudgetInfo; } break;
		case WTWeddingTypeHost:{ cell.price = _budget.budget.hostBudget; budgetInfo = _budget.service_price.hostBudgetInfo; } break;
		case WTWeddingTypeDress:{ cell.price = _budget.budget.dressBudget; budgetInfo = _budget.service_price.dressBudgetInfo; } break;
		case WTWeddingTypeMakeUp:{ cell.price = _budget.budget.makeUpBudget; budgetInfo = _budget.service_price.makeUpBudgetInfo; } break;
		case WTWeddingTypeVideo:{ cell.price = _budget.budget.videoBudget; budgetInfo = _budget.service_price.videoBudgetInfo; } break;
		case WTWeddingTypeHotel:{ cell.price = _budget.budget.hotelBudget; budgetInfo = _budget.service_price.hotelBudgetInfo; } break;
		default: break;
	}
	cell.step = budgetInfo.step;
	cell.priceSlider.minimumValue = budgetInfo.min_price.floatValue;
	cell.priceSlider.maximumValue = budgetInfo.max_price.floatValue;
	cell.priceSlider.value = cell.price.doubleValue;
	cell.priceLabel.attributedText = [LWUtil attributeStringWithBudget:cell.price];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)setupView
{
	[self showBlurBackgroundView];
	[self setupHeadView];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeadViewHeight, screenWidth, screenHeight - kHeadViewHeight - kTabBarHeight) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	[self.view addSubview:_tableView];

	_saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_saveButton.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	_saveButton.backgroundColor = WeddingTimeBaseColor;
	_saveButton.titleLabel.font = DefaultFont18;
	[_saveButton setTitle:@"保存" forState:UIControlStateNormal];
	[self.view addSubview:_saveButton];
	[_saveButton addTarget:self action:@selector(saveBudget) forControlEvents:UIControlEventTouchUpInside];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeChat),@(WTTopViewTypeLike)]];
	self.topView.delegate = self;
	[_topView.likeButton setImage:[UIImage imageNamed:@"icon_likes"] forState:UIControlStateNormal];
	[_topView.likeButton setImage:[UIImage imageNamed:@"icon_likes"] forState:UIControlStateSelected];
	[self.view addSubview:_topView];
}

- (void)setupHeadView
{
	_headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kHeadViewHeight)];
	_headView.backgroundColor = rgba(0, 0, 0, 0.1);
	[self.view addSubview:_headView];

	_budgetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, screenWidth, 21)];
	_budgetTitleLabel.font = DefaultFont18;
	_budgetTitleLabel.textColor = WHITE;
	_budgetTitleLabel.textAlignment = NSTextAlignmentCenter;
	_budgetTitleLabel.text = @"预算";
	[_headView addSubview:_budgetTitleLabel];

	_budgePriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _budgetTitleLabel.bottom + 40, screenWidth, 39)];
	_budgePriceLabel.font = DefaultFont36;
	_budgePriceLabel.textColor = WHITE;
	_budgePriceLabel.textAlignment = NSTextAlignmentCenter;
	[_headView addSubview:_budgePriceLabel];
	[self countBudgetAction];

	_budgeDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _budgePriceLabel.bottom + 33, screenWidth, 17)];
	_budgeDescLabel.font = DefaultFont14;
	_budgeDescLabel.textColor = WHITE;
	_budgeDescLabel.textAlignment = NSTextAlignmentCenter;
	_budgeDescLabel.text = @"精准预算更容易找到想要的服务";
	[_headView addSubview:_budgeDescLabel];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
