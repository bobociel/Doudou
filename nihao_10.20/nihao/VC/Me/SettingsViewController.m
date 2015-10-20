//
//  SettingsViewController.m
//  nihao
//
//  Created by HelloWorld on 7/8/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "SettingsViewController.h"
#import "MeTableViewCell.h"
#import "FeedbackViewController.h"
#import "AboutnihaoViewController.h"
#import "UserGuideViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *SettingsCellReuseIdentifier = @"SettingsTableViewCell";

@implementation SettingsViewController {
	NSArray *textArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Settings";
	[self dontShowBackButtonTitle];
	
	[self initViews];
	
	textArray = [NSArray arrayWithObjects:@"Feedback", @"About NiHao", @"User Guide", nil];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews {
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.view.frame) - 64)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 51.0;
	self.tableView.backgroundColor = self.view.backgroundColor;
	[self.tableView registerNib:[UINib nibWithNibName:@"MeTableViewCell" bundle:nil] forCellReuseIdentifier:SettingsCellReuseIdentifier];
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
	footerView.backgroundColor = self.view.backgroundColor;
	UIButton *logOutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, 40)];
	[logOutBtn setTitle:@"Log Off" forState:UIControlStateNormal];
	[logOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	logOutBtn.titleLabel.font = FontNeveLightWithSize(18.0);
	[logOutBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:109/255.0 alpha:1.0]];
	[logOutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:logOutBtn];
	logOutBtn.center = footerView.center;
	
	self.tableView.tableFooterView = footerView;
	[self.view addSubview:self.tableView];
}

#pragma mark - click events
- (void)logOut {
	// 显示确认对话框
	UIAlertView *logOutAlert = [[UIAlertView alloc] initWithTitle:@"Log Off" message:@"Log Off will not delete any data. You can still log in with this account." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Off", nil];
	[logOutAlert show];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return textArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MeTableViewCell *cell = (MeTableViewCell  *)[tableView dequeueReusableCellWithIdentifier:SettingsCellReuseIdentifier forIndexPath:indexPath];
	[cell configureCellWithIconName:@""	andLabelText:textArray[indexPath.row] hasIcon:NO hasRedPoint:NO];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	switch (indexPath.row) {
		case 0: {// Feedback
            FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc]init];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
		}
			break;
		case 1: {// About NiHao
            AboutnihaoViewController *aboutnihaoViewController = [[AboutnihaoViewController alloc]init];
            [self.navigationController pushViewController:aboutnihaoViewController animated:YES];
		}
			break;
		case 2: {// User Guide
            UserGuideViewController *userguideViewController = [[UserGuideViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:userguideViewController];
            [self presentViewController:nav animated:YES completion:nil];

		}
			break;
		default:
			break;
	}
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {// Log Out
		// 1. 环信主动退出登录
		__weak SettingsViewController *weakSelf = self;
		[self showHudInView:self.view hint:@"Logging off..."];
		[[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
			[weakSelf hideHud];
			if (error && error.errorCode != EMErrorServerNotLogin) {
				[weakSelf showHint:error.description];
			} else {
				// 2. 调用 AppDelegate 的 userLogOut 方法
				AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
				[appDelegate userLogOut];
			}
		} onQueue:nil];
	}
}

@end
