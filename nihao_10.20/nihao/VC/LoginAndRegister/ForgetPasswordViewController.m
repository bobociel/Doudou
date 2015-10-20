//
//  ForgetPasswordViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/26.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import <JVFloatLabeledTextField.h>
#import "SelectCountryCodeViewController.h"
#import "HttpManager.h"
#import "PPPwdViewController.h"
#import "AppConfigure.h"

@interface ForgetPasswordViewController () <UIScrollViewDelegate> {
    int _second;
    int _totalSeconds;
    
    NSTimer *_timer;
    NSDate *_startDate;
    
    NSDictionary *userRegisterInfo;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) JVFloatLabeledTextField *phoneNumberTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *authCodeTextField;
@property (strong, nonatomic) UIButton *getAuthCodeBtn;
@property (strong, nonatomic) UIButton *countryCodeBtn;
@property (strong, nonatomic) UILabel *countryCodeLabel;
@property (strong, nonatomic) UIButton *resetPsdBtn;


@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Forget Password";
    [self dontShowBackButtonTitle];
    [self initViews];
}

- (void) initViews {
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
    
    // 初始化注册Next按钮
    self.resetPsdBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(whiteView.frame) + 20, SCREEN_WIDTH - 40, 40)];
    self.resetPsdBtn.backgroundColor = AppBlueColor;
    [self.resetPsdBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [self.resetPsdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetPsdBtn.titleLabel.font = FontNeveLightWithSize(18.0);
    [self.resetPsdBtn addTarget:self action:@selector(setPsdClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.resetPsdBtn];
    
    [self.view addSubview:self.scrollView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click events
- (void) setPsdClick {
    NSString *authCode = self.authCodeTextField.text;
    if (![authCode isEqualToString:userRegisterInfo[@"ci_password"]]) {// 验证码错误
        [self showHUDErrorWithText:@"Verification code not correct, please try again"];
    } else {// 验证码正确
        PPPwdViewController *pwdViewController = [[PPPwdViewController alloc] init];
        pwdViewController.setPasswordFromType = SetPasswordFromTypeForgotPWD;
        UINavigationController *nav = [self navigationControllerWithRootViewController:pwdViewController navBarTintColor:AppBlueColor];
        [self.navigationController presentViewController:nav animated:YES completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

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

- (void)selectedCountryName:(NSString *)countryName andCode:(NSString *)code {
    self.countryCodeLabel.text = code;
    NSString *placeholder = [NSString stringWithFormat:@"%@ %@", countryName, code];
    self.phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:HintTextColor}];
    
    
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
        
        [HttpManager getAuthCodeByPhoneNumber:phoneNumber chc_type:@"2" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            userRegisterInfo = (NSDictionary *)responseObject[@"result"];
            NSInteger rtnCode = [responseObject[@"code"] integerValue];
            [AppConfigure setValue:responseObject[@"result"][@"ci_id"] forKey:REGISTER_USER_ID];
            if (rtnCode == 0) {
                NSString *msg = [NSString stringWithFormat:@"Verification code sent to your %@ Phone Number", phoneNumber];
                [self showHUDDoneWithText:msg];
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

@end