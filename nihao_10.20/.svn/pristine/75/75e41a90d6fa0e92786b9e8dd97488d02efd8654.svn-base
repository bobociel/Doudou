//
//  ModifyViewController.m
//  nihao
//
//  Created by HelloWorld on 7/31/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ModifyViewController.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import "GTMNSString+URLArguments.h"

#define NicknameTextFieldTag 11

@interface ModifyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIDatePicker *birthDayDatePicker;

@end

@implementation ModifyViewController {
	// 性别
	NSArray *genders;
	// 当前 ModifyType 对应的 Cell 的 ID
	NSString *CellIdentifier;
	NSString *newNickname;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	if (!(self.modifyType < ModifyTypeNickname || self.modifyType > ModifyTypeBirthday)) {
		[self setTitleWithType:self.modifyType];
		[self setUpViews];
	}
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self.tableView removeFromSuperview];
	self.tableView = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setTitleWithType:(ModifyType)modifyType {
	if (modifyType != ModifyTypeNickname) {
		[self dontShowBackButtonTitle];
	}
	
	switch (modifyType) {
		case ModifyTypeNickname: {
			self.title = @"Nickname";
			// Cancel 按钮
			UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
			self.navigationItem.leftBarButtonItem = cancelItem;
			// Save 按钮
			UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
			self.navigationItem.rightBarButtonItem = saveItem;
			
			CellIdentifier = @"NicknameCell";
		}
			break;
		case ModifyTypeAge: {
			self.title = @"Age";
			
			CellIdentifier = @"AgeCell";
		}
			break;
		case ModifyTypeGender: {
			self.title = @"Gender";
			genders = @[@"Female", @"Male"];
			
			CellIdentifier = @"GenderCell";
		}
			break;
		case ModifyTypeOccupation: {
			self.title = @"Occupation";
			
			CellIdentifier = @"OccupationCell";
		}
			break;
		case ModifyTypeHobbies: {
			self.title = @"Hobbies";
			
			CellIdentifier = @"HobbiesCell";
		}
			break;
		case ModifyTypeBirthday: {
			self.title = @"Birthday";
			
			CellIdentifier = @"AgeCell";
		}
			break;
		}
}

- (void)setUpViews {
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.rowHeight = 50;
	self.tableView.backgroundColor = self.view.backgroundColor;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.view addSubview:self.tableView];
	
	if (self.modifyType == ModifyTypeAge || self.modifyType == ModifyTypeBirthday) {
		self.birthDayDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
		self.birthDayDatePicker.datePickerMode = UIDatePickerModeDate;
//		if (self.modifyType == ModifyTypeAge) {
		self.selectedBirthday = [AppConfigure valueForKey:LOGINED_USER_BIRTHDAY];
//		}
		if (IsStringEmpty(self.selectedBirthday)) {
			self.selectedBirthday = @"1987-01-01 00:00:00";
		}
		
		self.birthDayDatePicker.date = [BaseFunction longDateFromString:self.selectedBirthday];
		self.birthDayDatePicker.maximumDate = [NSDate date];
		[self.birthDayDatePicker addTarget:self action:@selector(birthdayChanged) forControlEvents:UIControlEventValueChanged];
		
		self.tableView.tableFooterView = self.birthDayDatePicker;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	switch (self.modifyType) {
		case ModifyTypeNickname:
			numberOfRows = 1;
			break;
		case ModifyTypeAge:
		case ModifyTypeBirthday:
			numberOfRows = 1;
			break;
		case ModifyTypeGender:
			numberOfRows = 2;
			break;
		case ModifyTypeOccupation:
			numberOfRows = 0;
			break;
		case ModifyTypeHobbies:
			numberOfRows = 0;
			break;
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	switch (self.modifyType) {
		case ModifyTypeNickname: {
			if (cell.contentView.subviews.count < 3) {
				UITextField *nicknameTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 16, 40)];
				nicknameTF.clearButtonMode = UITextFieldViewModeAlways;
				nicknameTF.font = FontNeveLightWithSize(14);
				nicknameTF.textColor = TextFieldEndEditingColor;
				nicknameTF.tag = NicknameTextFieldTag;
				nicknameTF.text = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
				[nicknameTF setValue:@16 forKey:@"limit"];
				[cell.contentView addSubview:nicknameTF];
				nicknameTF.keyboardType = UIKeyboardTypeASCIICapable;
				nicknameTF.center = CGPointMake(SCREEN_WIDTH / 2.0, cell.contentView.center.y);
				[nicknameTF becomeFirstResponder];
			}
		}
			break;
		case ModifyTypeAge:
		case ModifyTypeBirthday: {
			cell.textLabel.text = @"Birthday";
			UILabel *ageLabel = [UILabel new];
			//NSString *ageString = [NSString stringWithFormat:@"%ld", [BaseFunction calculateAgeByBirthday:self.birthDayDatePicker.date]];
            ageLabel.text = [self.selectedBirthday componentsSeparatedByString:@" "][0];
			[ageLabel sizeToFit];
			cell.accessoryView = ageLabel;
		}
			break;
		case ModifyTypeGender: {
			cell.textLabel.text = genders[indexPath.row];
			cell.textLabel.font = FontNeveLightWithSize(14);
			cell.textLabel.textColor = TextFieldEndEditingColor;
			NSInteger userSex = [[AppConfigure objectForKey:LOGINED_USER_SEX] integerValue];
			if (indexPath.row == userSex) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
			break;
		case ModifyTypeOccupation: {
			cell = nil;
		}
			break;
		case ModifyTypeHobbies: {
			cell = nil;
		}
			break;
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (self.modifyType == ModifyTypeGender) {
		NSString *selectedSex = [NSString stringWithFormat:@"%ld", indexPath.row];
		if ([self.delegate respondsToSelector:@selector(modifyFinishedWithType:modifiedValue:)]) {
			[self.delegate modifyFinishedWithType:self.modifyType modifiedValue:selectedSex];
		}
		[self back];
	}
}

#pragma mark - Touch Events

- (void)back {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)save {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UITextField *nicknameTF = (UITextField *)[cell.contentView viewWithTag:NicknameTextFieldTag];
	newNickname = nicknameTF.text;
	if (IsStringEmpty(newNickname)) {
		[self showHUDErrorWithText:@"Please enter your nickname"];
		return ;
	}
	
	if (![BaseFunction validateNickname:newNickname]) {
		[self showHUDErrorWithText:@"Error, nickname should contain only letters, numbers, - or _"];
		NSLog(@"Invalidate nickname");
		return;
	}
	
	// 验证用户昵称唯一性
	[self showWithLabelText:@"" executing:@selector(verifyNicknameUnique)];
}

- (void)birthdayChanged {
	self.selectedBirthday = [BaseFunction stringFromDate:self.birthDayDatePicker.date format:@"yyyy-MM-dd HH:mm:ss"];
//	NSLog(@"self.selectedBirthday = %@", self.selectedBirthday);
	if (self.modifyType == ModifyTypeAge) {
		[AppConfigure setValue:self.selectedBirthday forKey:LOGINED_USER_BIRTHDAY];
	}
	
	if ([self.delegate respondsToSelector:@selector(modifyFinishedWithType:modifiedValue:)]) {
		[self.delegate modifyFinishedWithType:self.modifyType modifiedValue:self.selectedBirthday];
	}
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Networking
#pragma mark 验证昵称唯一性
- (void)verifyNicknameUnique {
	NSString *userID = [AppConfigure valueForKey:LOGINED_USER_ID];
	[HttpManager verifyUserNameUnique:newNickname userID:userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		//		{"code":"1","message":"该昵称已被使用"}
		//		{"code":"0","message":"该昵称有效"}
		if (rtnCode == 0) {
			if ([self.delegate respondsToSelector:@selector(modifyFinishedWithType:modifiedValue:)]) {
				[self.delegate modifyFinishedWithType:self.modifyType modifiedValue:newNickname];
			}
			[AppConfigure setValue:newNickname forKey:LOGINED_USER_NICKNAME];
			[self cancel];
		} else {
			if (rtnCode == 1) {
				[self showHUDErrorWithText:@"Nickname is already in use"];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
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
