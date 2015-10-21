//
//  PPOthersViewController.m
//  nihao
//
//  Created by HelloWorld on 8/11/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PPOthersViewController.h"
#import "PPOthersCell.h"
#import "ModifyViewController.h"
#import "Nationality.h"
#import "NationalityViewController.h"
#import "RegionViewController.h"
#import "AppConfigure.h"
#import "FindFriendsViewController.h"
#import "HttpManager.h"

#define NextBtnDisableColor [UIColor colorWithRed:183 / 255.0 green:225 / 255.0 blue:252 / 255.0 alpha:1]

@interface PPOthersViewController () <UITableViewDelegate, UITableViewDataSource, ModifyViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *nextButton;

@end

static NSString *CellIdentifier = @"PPOthersCell";

@implementation PPOthersViewController {
	NSArray *profileNames;
	NSMutableArray *userProfile;
	// 保存用户选择的国家 ID
	NSString *userSelectedNationalityID;
	// 保存用户选择的居住城市 ID
	NSString *userCityID;
	NSIndexPath *selectedIndexPath;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Personal Profile";
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = ColorF4F4F4;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 50;
	[self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56)];
	footerView.backgroundColor = ColorF4F4F4;
	
	self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 16, SCREEN_WIDTH - 40, 40)];
	self.nextButton.backgroundColor = NextBtnDisableColor;
	self.nextButton.enabled = NO;
	[self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
	[self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.nextButton.titleLabel.font = FontNeveLightWithSize(18);
	[self.nextButton addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:self.nextButton];
	
	self.tableView.tableFooterView = footerView;
	[self.view addSubview:self.tableView];
	
	profileNames = @[@"Birthday", @"Nationality", @"Where do you live"];
	userProfile = [[NSMutableArray alloc] initWithArray:@[@"", @"", @""]];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Events

- (void)nextBtnClick {
	[self completeUserInfo];
}

#pragma mark - Private

- (void)updateNextButton {
	BOOL finish = YES;
	for (NSString *profile in userProfile) {
		finish = IsStringNotEmpty(profile) && finish;
	}
	
	if (finish) {
		self.nextButton.backgroundColor = AppBlueColor;
		self.nextButton.enabled = YES;
	}
}

- (void)setUserProfileWithInfo:(NSString *)info forRowAtIndexPath:(NSIndexPath *)indexPath {
	userProfile[selectedIndexPath.row] = info;
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	[self updateNextButton];
}

#pragma mark - Networking

- (void)completeUserInfo {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[AppConfigure valueForKey:REGISTER_USER_ID] forKey:REGISTER_USER_ID];
	[parameters setObject:userProfile[0] forKey:REGISTER_USER_BIRTHDAY];
	[parameters setObject:userSelectedNationalityID forKey:REGISTER_USER_COUNTRY_ID];
    [parameters setObject:userProfile[2] forKey:REGISTER_USER_CITY_ID];
	
	// 设置密码
	[HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSInteger rtnCode = [responseObject[@"code"] integerValue];
		if (rtnCode == 0) {
			// 设置成功，进入下一个界面
			FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] init];
            findFriendsViewController.enterSource = REGIST;
			[self.navigationController pushViewController:findFriendsViewController animated:YES];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PPOthersCell *cell = (PPOthersCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.keyLabel.text = profileNames[indexPath.row];
	
	NSString *birthday = userProfile[indexPath.row];
	if (indexPath.row == 0 && IsStringNotEmpty(birthday)) {
		NSString *date = [birthday componentsSeparatedByString:@" "][0];
		cell.valueLabel.text = date;
	} else {
		cell.valueLabel.text = userProfile[indexPath.row];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	selectedIndexPath = indexPath;
	__weak typeof(self) weakSelf = self;
	
	switch (indexPath.row) {
		case 0: {// Birthday
			ModifyViewController *modifyViewController = [[ModifyViewController alloc] init];
			modifyViewController.modifyType = ModifyTypeBirthday;
			modifyViewController.delegate = self;
			NSString *sBirthday = userProfile[0];
			if (IsStringNotEmpty(sBirthday)) {
				modifyViewController.selectedBirthday = sBirthday;
			}
			[self.navigationController pushViewController:modifyViewController animated:YES];
		}
			break;
		case 1: {
			NationalityViewController *nationalityViewController = [[NationalityViewController alloc] init];
			nationalityViewController.nationChoosed = ^(Nationality *nation) {
				userSelectedNationalityID = [NSString stringWithFormat:@"%ld", nation.country_id];
				[AppConfigure setValue:userSelectedNationalityID forKey:REGISTER_USER_COUNTRY_ID];
				[AppConfigure setValue:nation.country_name_en forKey:REGISTER_USER_COUNTRY_NAME];
				[weakSelf setUserProfileWithInfo:nation.country_name_en forRowAtIndexPath:indexPath];
			};
			[self.navigationController pushViewController:nationalityViewController animated:YES];
		}
			break;
		case 2: {
			RegionViewController *regionViewController = [[RegionViewController alloc] init];
			regionViewController.regionType = RegionTypeCountry;
			regionViewController.regionSelected = ^(NSString *region) {
				[AppConfigure setValue:region forKey:REGISTER_USER_CITY_NAME];
				[weakSelf setUserProfileWithInfo:region forRowAtIndexPath:indexPath];
			};
			[self.navigationController pushViewController:regionViewController animated:YES];
		}
			break;
	}
}

#pragma mark - ModifyViewControllerDelegate

- (void)modifyFinishedWithType:(ModifyType)modifyType modifiedValue:(NSString *)value {
	if (modifyType == ModifyTypeBirthday) {
		[self setUserProfileWithInfo:value forRowAtIndexPath:selectedIndexPath];
		[AppConfigure setValue:value forKey:REGISTER_USER_BIRTHDAY];
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
