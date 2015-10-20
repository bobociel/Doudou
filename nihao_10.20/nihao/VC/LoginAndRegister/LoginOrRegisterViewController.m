//
//  LoginOrRegisterViewController.m
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "LoginOrRegisterViewController.h"
#import <JVFloatLabeledTextField.h>
#import "LimitInput.h"
#import "HttpManager.h"
#import "CheckBox.h"
#import "PPPwdViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppConfigure.h"
#import "SelectCountryCodeViewController.h"
#import "BaseFunction.h"
#import "PolicyViewController.h"
#import "ForgetPasswordViewController.h"
#import "GuideView.h"

@interface LoginOrRegisterViewController () <CheckBoxDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UIAlertViewDelegate> {
    int _second;
    int _totalSeconds;
    
    NSTimer *_timer;
    NSDate *_startDate;
    
//    CLLocationManager *_locationManager;
//    CLGeocoder *_geocoder;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) JVFloatLabeledTextField *phoneNumberTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *authCodeTextField;
@property (strong, nonatomic) UIButton *getAuthCodeBtn;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *forgotPwdBtn;
@property (strong, nonatomic) UIButton *registerNextBtn;
@property (strong, nonatomic) UIButton *countryCodeBtn;
@property (strong, nonatomic) UILabel *countryCodeLabel;

@end

@implementation LoginOrRegisterViewController {
	// 用户注册之后返回的用户信息
    NSDictionary *userRegisterInfo;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = ColorF4F4F4;
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetHeight(self.view.frame) - 64);
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.delegate = self;
	
	// 初始化白色背景 View
	UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 100)];
	whiteView.backgroundColor = [UIColor whiteColor];
	[self.scrollView addSubview:whiteView];
	
	// 初始化手机号国家前缀按钮
	self.countryCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(24, 5, 58, 40)];
	[self.countryCodeBtn addTarget:self action:@selector(selectCountryCode) forControlEvents:UIControlEventTouchUpInside];
	[whiteView addSubview:self.countryCodeBtn];
	
	self.countryCodeLabel = [[UILabel alloc] initWithFrame:self.countryCodeBtn.frame];
	self.countryCodeLabel.font = FontNeveLightWithSize(16);
	self.countryCodeLabel.textColor = TextColor575757;
	self.countryCodeLabel.text = @"+86";
	[whiteView addSubview:self.countryCodeLabel];
	
	// 初始化手机号国家前缀按钮右下角三角形
	UIImageView *triangleIV = [[UIImageView alloc] initWithFrame:CGRectMake(24 + CGRectGetWidth(self.countryCodeBtn.frame) - 8, 50 - 5 - 8, 8, 8)];
	triangleIV.image = [UIImage imageNamed:@"icon_bottom_right_corner_triangle"];
	[whiteView addSubview:triangleIV];
	
    // 初始化手机号输入框
    self.phoneNumberTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24 + CGRectGetWidth(self.countryCodeBtn.frame) + 15, 2, SCREEN_WIDTH - 24 - CGRectGetWidth(self.countryCodeBtn.frame) - 15 - 15, 46)];
    self.phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone number" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
    self.phoneNumberTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
    self.phoneNumberTextField.floatingLabelTextColor = AppBlueColor;
    self.phoneNumberTextField.font = FontNeveLightWithSize(16);
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.phoneNumberTextField.borderStyle = UITextBorderStyleNone;
    [whiteView addSubview:self.phoneNumberTextField];
	
	// 中间的分割线
	UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(15, 50, SCREEN_WIDTH - 30, 0.5)];
	middleLine.backgroundColor = SeparatorColor;
	[whiteView addSubview:middleLine];
	
	if (self.loginOrRegisterType == LoginOrRegisterTypeLogin) {// 登录
		// 初始化密码输入框
		self.passwordTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24, 52, SCREEN_WIDTH - 24 - 15, 46)];
		self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
		self.passwordTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
		self.passwordTextField.floatingLabelTextColor = AppBlueColor;
		self.passwordTextField.font = FontNeveLightWithSize(16);
		self.passwordTextField.secureTextEntry = YES;
		self.passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
		self.passwordTextField.borderStyle = UITextBorderStyleNone;
		[whiteView addSubview:self.passwordTextField];
		
		// 初始化登录按钮
		self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(whiteView.frame) + 40, SCREEN_WIDTH - 40, 40)];
		self.loginBtn.backgroundColor = AppBlueColor;
		[self.loginBtn setTitle:@"Log in" forState:UIControlStateNormal];
		[self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		self.loginBtn.titleLabel.font = FontNeveLightWithSize(18);
		[self.loginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:self.loginBtn];
		
		// 初始化忘记密码按钮
		self.forgotPwdBtn = [[UIButton alloc] initWithFrame:CGRectZero];
		[self.forgotPwdBtn setTitle:@"Forgot Password?" forState:UIControlStateNormal];
		[self.forgotPwdBtn setTitleColor:[UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1] forState:UIControlStateNormal];
        [self.forgotPwdBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
		self.forgotPwdBtn.titleLabel.font = FontNeveLightWithSize(14);
		[self.forgotPwdBtn sizeToFit];
		[self.scrollView addSubview:self.forgotPwdBtn];
		self.forgotPwdBtn.center = CGPointMake(SCREEN_WIDTH / 2, CGRectGetMaxY(self.loginBtn.frame) + 20 + CGRectGetHeight(self.forgotPwdBtn.frame) / 2);
        
	} else {// 注册
		// 初始化获取验证码按钮
		self.getAuthCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 24 - 135, 57, 135, 36)];
		[self.getAuthCodeBtn setTitle:@"Get verification code" forState:UIControlStateNormal];
		[self.getAuthCodeBtn addTarget:self action:@selector(getAuthCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
		self.getAuthCodeBtn.layer.masksToBounds = YES;
		self.getAuthCodeBtn.titleLabel.font = FontNeveLightWithSize(12.0);
		self.getAuthCodeBtn.layer.borderWidth = 1;
		[self.getAuthCodeBtn setTitleColor:AppBlueColor forState:UIControlStateNormal];
		[self.getAuthCodeBtn setTitleColor:HintTextColor forState:UIControlStateDisabled];
		self.getAuthCodeBtn.backgroundColor = [UIColor whiteColor];
		[whiteView addSubview:self.getAuthCodeBtn];
		[self updateButtonState:ButtonStateClickable];
		
		// 初始化验证码输入框
		self.authCodeTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24, 52, CGRectGetMinX(self.getAuthCodeBtn.frame) - 24 - 8, 46)];
		self.authCodeTextField.secureTextEntry = YES;
		self.authCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
		self.authCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Verification code" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
		self.authCodeTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
		self.authCodeTextField.floatingLabelTextColor = AppBlueColor;
		self.authCodeTextField.font = FontNeveLightWithSize(16.0);
		self.authCodeTextField.clearButtonMode = UITextFieldViewModeAlways;
		[self.authCodeTextField setValue:@4 forKey:@"limit"];
		self.authCodeTextField.borderStyle = UITextBorderStyleNone;
		[whiteView addSubview:self.authCodeTextField];
		
		CheckBox *protocolCheckBox = [[CheckBox alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(whiteView.frame) + 30, 14, 14)];
		[protocolCheckBox setImage:[UIImage imageNamed:@"img_checkbox_unchecked"] forState:UIControlStateNormal];
		[protocolCheckBox setImage:[UIImage imageNamed:@"img_checkbox_checked"] forState:UIControlStateSelected];
		protocolCheckBox.delegate = self;
		[protocolCheckBox setSelected:YES];
		[self.scrollView addSubview:protocolCheckBox];
		
		CGFloat labelX = CGRectGetMaxX(protocolCheckBox.frame) + 10;
		UILabel *protocolLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMinY(protocolCheckBox.frame), SCREEN_WIDTH - labelX - 24, CGRectGetHeight(protocolCheckBox.frame))];
		protocolLabel.text = @"I agree and confirm that I have read NiHao Terms.";
		protocolLabel.textColor = NormalTextColor;
		protocolLabel.font = FontNeveLightWithSize(12.0);
		protocolLabel.numberOfLines = 0;
		protocolLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[protocolLabel sizeToFit];
		[protocolLabel setNeedsDisplay];
		CGRect protocolLabelFrame = protocolLabel.frame;
		CGFloat protocolLabelHeight = protocolLabelFrame.size.height;
		protocolLabelFrame.origin.y -= protocolLabelHeight / 2;
		protocolLabelFrame.origin.y += CGRectGetHeight(protocolCheckBox.frame) / 2;
		protocolLabel.frame = protocolLabelFrame;
		protocolLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPolicyVC)];
		[protocolLabel addGestureRecognizer:tapGestureRecognizer];
		[self.scrollView addSubview:protocolLabel];
		
		// 初始化注册Next按钮
		self.registerNextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(protocolLabel.frame) + 30, SCREEN_WIDTH - 40, 40)];
		self.registerNextBtn.backgroundColor = AppBlueColor;
		[self.registerNextBtn setTitle:@"Next" forState:UIControlStateNormal];
		[self.registerNextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		self.registerNextBtn.titleLabel.font = FontNeveLightWithSize(18.0);
		[self.registerNextBtn addTarget:self action:@selector(registerNextBtnClick) forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:self.registerNextBtn];
	}
	
    if (self.loginOrRegisterType == LoginOrRegisterTypeLogin) {// 登录
        self.title = @"NiHao";
		
        // 设置导航栏按钮的点击执行方法等
        UIBarButtonItem *signUpItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign up" style:UIBarButtonItemStylePlain target:self action:@selector(signUpClick)];
        NSArray *rightButtonItems = @[signUpItem];
        self.navigationItem.rightBarButtonItems = rightButtonItems;
    } else {// 注册
		self.title = @"New User Registration";
        [self dontShowBackButtonTitle];
		
        self.phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"China +86" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
    }
    
    [self.view addSubview:self.scrollView];
    
    [self showGuide];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	_timer = nil;
}

#pragma mark - Private

// 定位
//- (void)requestLocation {
//    if (!_locationManager) {
//        _locationManager = [[CLLocationManager alloc] init];
//    }
//    
//    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [_locationManager requestAlwaysAuthorization]; // 永久授权
//    }
//    
//    _locationManager.delegate = self;
//    // 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    // 开始定位
//    [_locationManager startUpdatingLocation];
//    
//    _geocoder = [[CLGeocoder alloc] init];
//}

#pragma mark - click events
// 选择手机号国家前缀
- (void)selectCountryCode {
	__weak typeof(self) weakSelf = self;
	SelectCountryCodeViewController *selectCountryCodeViewController = [[SelectCountryCodeViewController alloc] init];
	selectCountryCodeViewController.countryCodeSelected = ^(NSString *countryName, NSString *code) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf selectedCountryName:countryName andCode:code];
	};
	UINavigationController *nav = [self navigationControllerWithRootViewController:selectCountryCodeViewController navBarTintColor:AppBlueColor];
	[self presentViewController:nav animated:YES completion:nil];
}

// 点击登录
- (void)loginBtnClick {
	if (self.phoneNumberTextField.text.length == 0) {
		[self showHUDErrorWithText:@"Please enter your phone number"];
		return;
	}
	
	if (self.passwordTextField.text.length == 0) {
		[self showHUDErrorWithText:@"Please enter your password"];
		return;
	}
	
	[self showWithLabelText:@"Login..." executing:@selector(userLogin)];
}

// 点击注册
- (void)registerNextBtnClick {
//#warning Test
//	// 打开到设置密码界面
//	PPPwdViewController *pwdViewController = [[PPPwdViewController alloc] init];
//	UINavigationController *nav = [self navigationControllerWithRootViewController:pwdViewController navBarTintColor:AppBlueColor];
//	[self presentViewController:nav animated:YES completion:nil];
	
	if (self.phoneNumberTextField.text.length == 0) {
		[self showHUDErrorWithText:@"Please enter your phone number"];
		return;
	}
	
	if (self.authCodeTextField.text.length == 0) {
		[self showHUDErrorWithText:@"Please enter your verification code"];
		return;
	}
	
	[self userRegister];
}

- (void)forgetPassword {
    ForgetPasswordViewController *controller = [[ForgetPasswordViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateButtonState:(ButtonState)state {
	if (state == ButtonStateClickable) {
		self.getAuthCodeBtn.enabled = YES;
		self.getAuthCodeBtn.layer.borderColor = AppBlueColor.CGColor;
	} else {
		self.getAuthCodeBtn.enabled = NO;
		self.getAuthCodeBtn.layer.borderColor = Color9E9E9E.CGColor;
	}
}

- (void)openPolicyVC {
	PolicyViewController *policyViewController = [[PolicyViewController alloc] init];
	[self.navigationController pushViewController:policyViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view endEditing:YES];
}

#pragma mark - Network

// 登录网络请求方法
- (void)userLogin {
	// 组装请求数据
    NSString *phoneNumber = [self.phoneNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *countryCode = self.countryCodeLabel.text;
	phoneNumber = [NSString stringWithFormat:@"%@ %@", countryCode, phoneNumber];
    NSString *password = [BaseFunction md5Digest:self.passwordTextField.text];
    [HttpManager userLoginWithPhoneNumber:phoneNumber password:password success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        NSLog(@"当前登录的用户信息：%@", resultDict);
        if (rtnCode == 0) {
            // 保存当前登录的用户信息
            [self saveLoginUserInfo:resultDict[@"result"]];
			// 登录成功
			if (self.loginSucceed) {
				self.loginSucceed();
			}
        } else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
		[self showHUDNetError];
    }];
}

- (void)userRegister {
	NSString *authCode = self.authCodeTextField.text;

	if (![authCode isEqualToString:userRegisterInfo[@"ci_password"]]) {// 验证码错误
		[self showHUDErrorWithText:@"Verification code not correct, please try again"];
	} else {// 验证码正确
		// 保存当前注册的用户信息
		[AppConfigure saveRegisterUserProfile:userRegisterInfo];
	
		// 打开到设置密码界面
		PPPwdViewController *pwdViewController = [[PPPwdViewController alloc] init];
		if (self.loginOrRegisterType == LoginOrRegisterTypeRegister) {
			pwdViewController.setPasswordFromType = SetPasswordFromTypeRegister;
		} else {
			pwdViewController.setPasswordFromType = SetPasswordFromTypeForgotPWD;
		}
		UINavigationController *nav = [self navigationControllerWithRootViewController:pwdViewController navBarTintColor:AppBlueColor];
		[self presentViewController:nav animated:YES completion:nil];
	}
}

// 点击获取验证码按钮
- (void)getAuthCodeBtnClick {
	NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *phoneNumber = [self.phoneNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	// 验证手机号码
    if (phoneNumber.length == 0) {
        [self showHUDErrorWithText:@"Please enter your phone number"];
    } else {
		[self.authCodeTextField becomeFirstResponder];
		// 开始倒数计时
		[self startWithSeconds:60];
		[self updateButtonState:ButtonStateDisable];
		
		NSString *countryCode = self.countryCodeLabel.text;
		phoneNumber = [NSString stringWithFormat:@"%@ %@", countryCode, phoneNumber];
        
      [HttpManager getAuthCodeByPhoneNumber:phoneNumber chc_type:@"1" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            userRegisterInfo = (NSDictionary *)responseObject[@"result"];
            NSInteger rtnCode = [responseObject[@"code"] integerValue];
			if (rtnCode == 0) {
				NSString *msg = [NSString stringWithFormat:@"Verification code sent to your %@ Phone Number", phoneNumber];
				[self showHUDDoneWithText:msg];
//				self.authCodeTextField.text = userRegisterInfo[@"ci_password"];
			} else if (rtnCode == 1) {// 已经注册过了
				[self resetTimer];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"This number is already registered to a NiHao account. Do you want to log in to NiHao now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
				[alertView show];
			} else {
				[self resetTimer];
				[self processServerErrorWithCode:rtnCode andErrorMsg:[responseObject objectForKey:@"message"]];
			}
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
			[self showHUDNetError];
			[self stop];
        }];
    }
}

// 标记用户已经完善过信息了
- (void)markUserCompleteInfo {
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[AppConfigure objectForKey:REGISTER_USER_ID] forKey:@"ci_id"];
    [HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

// 点击注册按钮
- (void)signUpClick {
    LoginOrRegisterViewController *registerViewController = [[LoginOrRegisterViewController alloc] init];
    registerViewController.loginOrRegisterType = LoginOrRegisterTypeRegister;
    [self.navigationController pushViewController:registerViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {// OK
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - CheckBoxDelegate
// 根据用户勾选状态来改变注册按钮的样式
- (void)checkBox:(CheckBox *)checkBox didChangedSelectedStatus:(BOOL)status {
    if (status) {
        self.registerNextBtn.backgroundColor = AppBlueColor;
        self.registerNextBtn.enabled = YES;
    } else {
        self.registerNextBtn.backgroundColor = [UIColor lightGrayColor];
        self.registerNextBtn.enabled = NO;
    }
}

#pragma mark - other functions
// 用户选择完手机号国家前缀之后刷新界面
- (void)selectedCountryName:(NSString *)countryName andCode:(NSString *)code {
	self.countryCodeLabel.text = code;
	NSString *placeholder = [NSString stringWithFormat:@"%@ %@", countryName, code];
	self.phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:HintTextColor}];
}

// 保存登录的用户数据
- (void)saveLoginUserInfo:(NSDictionary *)userInfo {
    NSLog(@"userInfo = %@", userInfo);
	[AppConfigure saveUserProfile:userInfo];
}

#pragma mark - locate delegate
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation *location = [locations lastObject];
//    [manager stopUpdatingLocation];
//	// 保存当前注册用户的定位坐标
//    [AppConfigure setValue:[NSString stringWithFormat:@"%lf", location.coordinate.latitude] forKey:REGISTER_USER_LATITUDE];
//    [AppConfigure setValue:[NSString stringWithFormat:@"%lf", location.coordinate.longitude] forKey:REGISTER_USER_LONGITUDE];
//}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can't get your location" message:@"please open app location service in settings" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
//        
//    }
//}

#pragma - mark count down method
// 开始倒数计时
-(void)startWithSeconds:(int)totalSecond {
    _totalSeconds = totalSecond;
    _second = totalSecond;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
    _startDate = [NSDate date];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)timerStart:(NSTimer *)theTimer {
    double deltaTime = [[NSDate date] timeIntervalSinceDate:_startDate];
    _second = _totalSeconds - (int)(deltaTime + 0.5) ;
    
    if (_second < 0.0) {
        [self stop];
    } else {
        NSString *title = [NSString stringWithFormat:@"%d seconds", _second];
        [self.getAuthCodeBtn setTitle:title forState:UIControlStateNormal];
        [self.getAuthCodeBtn setTitle:title forState:UIControlStateDisabled];
    }
}

// 停止倒数计时
- (void)stop {
	[self stopTimerWithText:@"Resend Code"];
}

// 重置倒数计时
- (void)resetTimer {
	[self stopTimerWithText:@"Get verification code"];
}

- (void)stopTimerWithText:(NSString *)text {
	if (_timer) {
		if ([_timer respondsToSelector:@selector(isValid)]) {
			if ([_timer isValid]) {
				[_timer invalidate];
				_second = _totalSeconds;
				
				[self.getAuthCodeBtn setTitle:text forState:UIControlStateNormal];
				[self.getAuthCodeBtn setTitle:text forState:UIControlStateDisabled];
				[self updateButtonState:ButtonStateClickable];
			}
		}
	}
}

- (void) showGuide {
    BOOL isNotFirstOpen = [AppConfigure boolForKey:FIRST_OPEN_REGISTER];
    if(!isNotFirstOpen) {
        GuideView *postGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_register"];
        [[UIApplication sharedApplication].keyWindow addSubview:postGuide];
        [AppConfigure setBool:YES forKey:FIRST_OPEN_REGISTER];
    }

}

@end
