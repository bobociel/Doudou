//
//  WTLocationCityViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/27.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTLocationCityViewController.h"
#import "WTAddressCell.h"
#define kTopViewHeight 120
#define kBtnSpace      10
#define kBtnWidth      ((screenWidth - 20 * 2 - kBtnSpace * 3) / 4)
#define kBtnHeight     32
@interface WTLocationCityViewController () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,LocationManagerDelegate>
@property (nonatomic,strong) UITextField *searchTextField;
@property (nonatomic,strong) UILabel     *currentCity;
@property (nonatomic,strong) UIButton    *locationBtn;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton    *cancelBtn;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *groupCityArray;
@property (nonatomic,strong) NSMutableArray *hotCityArray;
@property (nonatomic,strong) NSMutableArray *filterCityArray;
@property (nonatomic,strong) NSMutableArray *resultCityArray;
@property (nonatomic,strong) LocationManager *locationManager;
@property (nonatomic,assign) BOOL isSearch;
@end

@implementation WTLocationCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	_hotCityArray = [NSMutableArray array];
	_titleArray = [NSMutableArray array];
	_groupCityArray = [NSMutableArray array];
	_filterCityArray = [NSMutableArray array];
	_resultCityArray = [NSMutableArray array];

	[self setupView];
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getAllCityWithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error){
			NSArray *hots = [NSArray modelArrayWithClass:[WTCity class] json:result[@"data"][@"hot_city"]];
			_hotCityArray = [NSMutableArray arrayWithArray:hots];

			for (NSDictionary *citysInfo in result[@"data"][@"city"]) {
				WTCityGroup *group = [[WTCityGroup alloc] init];
				NSString *cityInitial = [LWUtil getString:citysInfo.allKeys[0] andDefaultStr:@""];
				group.groupName = cityInitial;
				NSArray *citys = [NSArray modelArrayWithClass:[WTCity class] json:citysInfo[cityInitial]];
				group.arrayCitys = [citys mutableCopy];
				[_groupCityArray addObject:group];

				[_titleArray addObject:cityInitial];
				[_filterCityArray addObjectsFromArray:citys];
				[self.tableView reloadData];
			}
		}
		else
		{
			[WTProgressHUD ShowTextHUD:@"网络出错，请稍后重试" showInView:self.view];
		}
	}];
}

#pragma mark - Action
- (void)locationAction
{
	_locationManager = [[LocationManager alloc] init];
	_locationManager.delegate = self;
	[_locationManager beginSearch];
}

- (void)chooseCityAction:(UIButton *)sender
{
	sender.selected = !sender.selected;
	WTCity *city = _hotCityArray[sender.tag];
	[UserInfoManager instance].city_name = city.cityName;
	[UserInfoManager instance].curCityId = city.cityID.intValue;
	[[UserInfoManager instance] saveToUserDefaults];

	sender.layer.borderColor = city.cityID.intValue == [UserInfoManager instance].curCityId ? WeddingTimeBaseColor.CGColor : rgba(220, 220, 220, 1).CGColor;
	[sender setTitleColor:city.cityID.intValue == [UserInfoManager instance].curCityId ? WeddingTimeBaseColor : rgba(170, 170, 170, 1) forState:UIControlStateNormal];

	if(_refreshBlock) { self.refreshBlock(YES); }
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _isSearch ? 1 : (self.groupCityArray.count + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(_isSearch)
	{
		return _resultCityArray.count;
	}
	else if(section >= 1)
	{
		WTCityGroup *group = self.groupCityArray[section-1];
		return group.arrayCitys.count;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_isSearch)
	{
		WTCity *city = _resultCityArray[indexPath.row];
		WTAddressCell *cell = [WTAddressCell addressCellWithTableView:tableView];
		cell.cityName = city.cityName;
		return cell;
	}
	else if(indexPath.section == 0)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotCityCell"] ;
		if(!cell){
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HotCityCell"];
			[cell.contentView removeAllSubviews];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

		for (NSInteger i=0; i < _hotCityArray.count; i++) {
			WTCity *city = _hotCityArray[i];
			UIButton *cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			cityBtn.frame = CGRectMake(20+(kBtnWidth + kBtnSpace)*(i%4),10+(kBtnSpace+kBtnHeight)*(i/4), kBtnWidth, kBtnHeight);
			cityBtn.tag = i;
			cityBtn.titleLabel.font = DefaultFont14;
			cityBtn.layer.cornerRadius = kBtnHeight/2.0;
			cityBtn.layer.borderWidth = 1.f;
			[cityBtn setTitle:city.cityName forState:UIControlStateNormal];
			cityBtn.layer.borderColor = city.cityID.intValue == [UserInfoManager instance].curCityId ? WeddingTimeBaseColor.CGColor : rgba(220, 220, 220, 1).CGColor;
			[cityBtn setTitleColor:city.cityID.intValue == [UserInfoManager instance].curCityId ? WeddingTimeBaseColor : rgba(170, 170, 170, 1) forState:UIControlStateNormal];
			[cell.contentView addSubview:cityBtn];
			[cityBtn addTarget:self action:@selector(chooseCityAction:) forControlEvents:UIControlEventTouchUpInside];
		}

		return cell;
	}
	else if(indexPath.section >= 1)
	{
		WTCityGroup *group = self.groupCityArray[indexPath.section-1];
		WTCity *city = group.arrayCitys[indexPath.row];
		
		WTAddressCell *cell = [WTAddressCell addressCellWithTableView:tableView];
		cell.cityName = city.cityName;
		return cell;
	}
	else
	{
		WTAddressCell *cell = [WTAddressCell addressCellWithTableView:tableView];
		cell.cityName = @"";
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!_isSearch && indexPath.section == 0){
		return 10 + (kBtnHeight + kBtnSpace) * ceil(_hotCityArray.count / 4.0);
	}
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(!_isSearch && indexPath.section < 1){ return ; }

	if(!_isSearch && indexPath.section >= 1){
		WTCityGroup *group = self.groupCityArray[indexPath.section-1];
		WTCity *city = group.arrayCitys[indexPath.row];
		[UserInfoManager instance].city_name = city.cityName;
		[UserInfoManager instance].curCityId = city.cityID.intValue;
		[[UserInfoManager instance] saveToUserDefaults];
		if(_refreshBlock) { self.refreshBlock(YES); }
		[self dismissViewControllerAnimated:YES completion:nil];
	}else if(_isSearch) {
		WTCity *city = _resultCityArray[indexPath.row];
		[UserInfoManager instance].city_name = city.cityName;
		[UserInfoManager instance].curCityId = city.cityID.intValue;
		[[UserInfoManager instance] saveToUserDefaults];
		if(_refreshBlock) { self.refreshBlock(YES); }
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *indexView = [_tableView valueForKey:@"index"];
	[indexView setValue:[UIColor clearColor] forKey:@"indexBackgroundColor"];
	[indexView setValue:rgba(65, 65, 65, 1) forKey:@"indexColor"];

	UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
	headView.backgroundColor = WHITE;

	UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, screenWidth-40, 30)];
	headLabel.font = DefaultFont14;
	headLabel.textColor = section == 0 ? rgba(153, 153, 153, 1) : WeddingTimeBaseColor;
	headLabel.text = section == 0 ? @"热门城市" : _titleArray[section-1];
	[headView addSubview:headLabel];
	return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return _titleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index + 1;
}

#pragma mark - LocationDelegate
- (void)didLocationSucceed:(BMKReverseGeoCodeResult *)result
{
	[UserInfoManager instance].city_name = result.addressDetail.city;
	[[UserInfoManager instance] saveToUserDefaults];
	[_locationManager stopLocating];

	_currentCity.text = [NSString stringWithFormat:@"当前城市：%@",[LWUtil getString:[UserInfoManager instance].city_name andDefaultStr:@"无法获取"]];

	CGSize citySize = [_currentCity.text sizeForFont:DefaultFont14 size:CGSizeMake(MAXFLOAT, 30) mode:0];
	_currentCity.width = ceil(citySize.width);
	_locationBtn.left = _currentCity.right + 8;

	[GetService getCityidWithLon:result.location.longitude  andLat:result.location.latitude WithBlock:^(NSDictionary *result, NSError *error) {
		[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
		if (!error) {
			if ([result isKindOfClass:[NSDictionary class]]) {
				if (result[@"city_id"]) {
					[UserInfoManager instance].curCityId = [result[@"city_id"] intValue];
					[[UserInfoManager instance] saveToUserDefaults];
				}
			}
			if(_refreshBlock) { self.refreshBlock(YES); }
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}];
}

- (void)didiFalidLocation
{
	[_locationManager stopLocating];
}

#pragma mark - TextFieldDelegate
- (void)textFieldEditChanged:(UITextField *)textField
{
	NSString *searchKey = [textField.text lowercaseString];
	self.isSearch = textField.text.length > 0;

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName CONTAINS %@",searchKey];
	NSArray *resultArray = [_filterCityArray filteredArrayUsingPredicate:predicate];
	_resultCityArray = [resultArray mutableCopy];
	[self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self.view endEditing:YES];
	NSString *searchKey = [textField.text lowercaseString];
	self.isSearch = YES;

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName CONTAINS %@",searchKey];
	NSArray *resultArray = [_filterCityArray filteredArrayUsingPredicate:predicate];
	_resultCityArray = [resultArray mutableCopy];
	[self.tableView reloadData];
	return YES;
}

#pragma mark - View
- (void)setupView
{
	_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, screenWidth-40, 30)];
	_searchTextField.font = DefaultFont16;
	_searchTextField.delegate = self;
	_searchTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_search"]];
	_searchTextField.leftViewMode = UITextFieldViewModeAlways;
	_searchTextField.placeholder = @" 输入城市名称";
	[self.view addSubview:_searchTextField];
	[_searchTextField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, _searchTextField.bottom+8,screenWidth-40, 0.5)];
	lineView.backgroundColor = rgba(220, 220, 220, 1);
	[self.view addSubview:lineView];

	_currentCity = [[UILabel alloc] initWithFrame:CGRectMake(20, lineView.bottom+8, 20, 30)];
	_currentCity.font = DefaultFont14;
	_currentCity.textColor = rgba(100, 100, 100, 1);
	[self.view addSubview:_currentCity];
	_currentCity.text = [NSString stringWithFormat:@"当前城市：%@",[LWUtil getString:[UserInfoManager instance].city_name andDefaultStr:@"无法获取"]];
	CGSize citySize = [_currentCity.text sizeForFont:DefaultFont14 size:CGSizeMake(MAXFLOAT, 30) mode:0];
	_currentCity.width = ceil(citySize.width);

	_locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_locationBtn.frame = CGRectMake(_currentCity.right+8, lineView.bottom+8, 80, 30);
	_locationBtn.titleLabel.font = DefaultFont14;
	[_locationBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	[_locationBtn setTitle:@"重新定位" forState:UIControlStateNormal];
	[self.view addSubview:_locationBtn];
	[_locationBtn addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopViewHeight, screenWidth, screenHeight-kTopViewHeight-kTabBarHeight)];
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	_cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelBtn.frame = CGRectMake(0, screenHeight-kTabBarHeight, screenWidth, kTabBarHeight);
	_cancelBtn.backgroundColor = WeddingTimeBaseColor;
	_cancelBtn.titleLabel.font = DefaultFont18;
	[_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
	[self.view addSubview:_cancelBtn];
	[_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
