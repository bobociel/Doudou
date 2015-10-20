//
//  PPPwdViewController.m
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PPPwdViewController.h"
#import "RadioButton.h"
#import <JVFloatLabeledTextField.h>
#import "PPInfoViewController.h"
#import "HttpManager.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "MBProgressHUD.h"

@interface PPPwdViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *confirmPwdTextField;
@property (strong, nonatomic) UIButton *nextBtn;

@end

@implementation PPPwdViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	if (self.setPasswordFromType == SetPasswordFromTypeRegister) {
		self.title = @"Password";
	} else {
		self.title = @"Reset Password";
	}
	
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = ColorF4F4F4;
    self.scrollView.contentSize = CGSizeMake(0, 0);
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.delegate = self;
	
	// 初始化白色背景 View
	UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 100)];
	whiteView.backgroundColor = [UIColor whiteColor];
	[self.scrollView addSubview:whiteView];
	
	// 初始化密码输入框
	self.passwordTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24, 2, SCREEN_WIDTH - 48, 46)];
	self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
	self.passwordTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
	self.passwordTextField.floatingLabelTextColor = AppBlueColor;
	self.passwordTextField.font = FontNeveLightWithSize(16);
	self.passwordTextField.secureTextEntry = YES;
	self.passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
	self.passwordTextField.borderStyle = UITextBorderStyleNone;
	[whiteView addSubview:self.passwordTextField];
	
	// 初始化确认密码输入框
	self.confirmPwdTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24, 52, SCREEN_WIDTH - 48, 46)];
	self.confirmPwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm password" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
	self.confirmPwdTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
	self.confirmPwdTextField.floatingLabelTextColor = AppBlueColor;
	self.confirmPwdTextField.font = FontNeveLightWithSize(16);
	self.confirmPwdTextField.secureTextEntry = YES;
	self.confirmPwdTextField.clearButtonMode = UITextFieldViewModeAlways;
	self.confirmPwdTextField.borderStyle = UITextBorderStyleNone;
	[whiteView addSubview:self.confirmPwdTextField];
	
	// 初始化分割线
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 50, SCREEN_WIDTH - 30, 0.5)];
	line.backgroundColor = SeparatorColor;
	[whiteView addSubview:line];
	
	// 初始化 Next 按钮
	self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(whiteView.frame) + 40, SCREEN_WIDTH - 40, 40)];
	self.nextBtn.backgroundColor = AppBlueColor;
	[self.nextBtn setTitle:@"Next" forState:UIControlStateNormal];
	[self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.nextBtn.titleLabel.font = FontNeveLightWithSize(18);
	[self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollView addSubview:self.nextBtn];
	
	[self.view addSubview:self.scrollView];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - click events
// 点击下一步按钮
- (void)nextBtnClick {
//#warning Test
//	PPInfoViewController *infoViewController = [[PPInfoViewController alloc] init];
//	[self.navigationController pushViewController:infoViewController animated:YES];
	
	// 验证密码合法性
	NSString *pwd = self.passwordTextField.text;
	NSString *confirmPwd = self.confirmPwdTextField.text;
	if (pwd.length == 0) {
		[self showHUDErrorWithText:@"Please enter your password"];
		return;
	}
	
	if (confirmPwd.length == 0) {
		[self showHUDErrorWithText:@"Please confirm your password"];
		return;
	}
	
	if (![pwd isEqualToString:confirmPwd]) {
		[self showHUDErrorWithText:@"Password and password confirmation don't match, please try again"];
		return;
	}
	
	[self showWithLabelText:@"" executing:@selector(setUserLoginPwd)];
}

- (void)setUserLoginPwd {
	NSString *pwd = self.passwordTextField.text;
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[AppConfigure valueForKey:REGISTER_USER_ID] forKey:REGISTER_USER_ID];
	NSString *sPwd = [BaseFunction md5Digest:pwd];
	[parameters setObject:sPwd forKey:@"ci_login_password"];
	
	// 设置密码
	[HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSInteger rtnCode = [responseObject[@"code"] integerValue];
		if (rtnCode == 0) {
			// 暂时保存加密过的密码，完成完善信息之后清除
			[AppConfigure setObject:sPwd ForKey:REGISTER_USER_PWD];
            if(self.setPasswordFromType == SetPasswordFromTypeForgotPWD) {
                [AppConfigure setValue:@"" forKey:REGISTER_USER_ID];
                [self showResetDoneHud];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                // 设置成功，进入下一个界面
                PPInfoViewController *infoViewController = [[PPInfoViewController alloc] init];
                [self.navigationController pushViewController:infoViewController animated:YES];
            }
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) showResetDoneHud {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_right"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Your password has been reset successfully";
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

@end
