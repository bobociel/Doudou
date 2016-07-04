//
//  WTWithdrawInfoViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWithdrawInfoViewController.h"
#import "WTTicketDetailViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CountdownButton.h"
#import "UserService.h"
#define kTop 20.0
#define kGap 20.0
#define kViewWidth (screenWidth - kGap)
#define kViewHeight 50.0
@interface WTWithdrawInfoViewController () <UITextFieldDelegate>
@property (nonatomic,strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic,strong) CountdownButton  *verifyBtn;
@property (nonatomic,strong) UITextField  *priceTextField;
@property (nonatomic,strong) UITextField  *accountTextField;
@property (nonatomic,strong) UITextField  *verifyTextField;
@property (nonatomic,strong) UIButton     *commitButton;
@property (nonatomic,strong) WTTicket *ticket;
@end
@implementation WTWithdrawInfoViewController
+ (instancetype)instanceWithTicket:(WTTicket *)ticket
{
	WTWithdrawInfoViewController *VC = [WTWithdrawInfoViewController new];
	ticket.company = [LWUtil getString:ticket.company andDefaultStr:@""];
	ticket.avatar = [LWUtil getString:ticket.avatar andDefaultStr:@""];
	VC.ticket = ticket;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"婚礼宝提现";
	[self setupView];
}

#pragma mark - Action
- (void)commitAction
{
	if (![LWUtil validatePhoneNumber:_accountTextField.text] && ![LWUtil validateEmail:_accountTextField.text]) {
		[WTProgressHUD ShowTextHUD:@"请输入支付宝账号" showInView:self.view];
		return;
	}
	if (![_verifyTextField.text isNotEmptyCtg]) {
		[WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:self.view];
		return;
	}

	[self showLoadingView];
	[UserService postAliAccountWithTicketID:_ticket.ID andCode:_verifyTextField.text andAccount:_accountTextField.text block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error && [result[@"success"] boolValue]){
			[self.view endEditing:YES];
			_ticket.alipay_account = _accountTextField.text;
			_ticket.status = WTTicketStateWithdrawing;
			if(self.block){ self.block(_ticket); }
			[self.navigationController popViewControllerAnimated:YES];
		}else{
			[WTProgressHUD ShowTextHUD:result[@"error_message"] ? : @"网络错误，请稍后重试" showInView:self.view];
		}
	}];
}

- (void)getVerifyCode:(CountdownButton *)sender {
	if (![LWUtil validatePhoneNumber:_accountTextField.text] && ![LWUtil validateEmail:_accountTextField.text]) {
		[WTProgressHUD ShowTextHUD:@"请输入支付宝账号" showInView:self.view];
		return;
	}
	[self showLoadingView];
	[UserService getAliCodeWithPhoneOrEmail:_accountTextField.text withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (!error) {
			[WTProgressHUD ShowTextHUD:@"成功发送验证码" showInView:self.view];
			[sender startCountDownWithTime:60];
		}else{
			[WTProgressHUD ShowTextHUD:result[@"msg"] ? : @"服务器出错啦,请稍后再试" showInView:self.view];
		}
	}];
}

#pragma mark - View
- (void)setupView
{
	_scrollView = [[TPKeyboardAvoidingScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight - kTabBarHeight)];
	_scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	[self.view addSubview:_scrollView];

	UITextField *(^TFVIewBlock)(NSString *place,CGRect frame) = ^(NSString *place,CGRect frame){
		UIView *tfView = [[UIView alloc] initWithFrame:frame];
		tfView.backgroundColor = [UIColor clearColor];
		[self.scrollView addSubview:tfView];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, tfView.height-0.5, kViewWidth, 0.5)];
		lineView.backgroundColor = rgba(231, 231, 231, 1);
		[tfView addSubview:lineView];

		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kGap, tfView.bottom - kGap, kViewWidth, kGap)];
		textField.font = DefaultFont16;
		textField.returnKeyType = UIReturnKeyNext;
		textField.placeholder = place;
		textField.delegate = self;
		[_scrollView addSubview:textField];

		return textField;
	};

	_priceTextField = TFVIewBlock(@"可提现金额",CGRectMake(kGap,kTop,kViewWidth,kViewHeight));
	_accountTextField = TFVIewBlock(@"支付宝账号",CGRectMake(kGap,kTop+kViewHeight,kViewWidth,kViewHeight));
	_verifyTextField = TFVIewBlock(@"输入验证码",CGRectMake(kGap,kTop+kViewHeight*2,kViewWidth,kViewHeight));

	_priceTextField.enabled = NO;
	_priceTextField.attributedText = [LWUtil attributeStringWithdrawPrice:_ticket.amount];
	_verifyTextField.keyboardType = UIKeyboardTypeNumberPad;

	_verifyBtn = [[CountdownButton alloc] initWithFrame:CGRectMake(_accountTextField.right-110,_accountTextField.top, 100, kGap)];
	_verifyBtn.titleLabel.font = DefaultFont16;
    [_verifyBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	[_verifyBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
	[self.scrollView addSubview:_verifyBtn];
	[_verifyBtn addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];

	[_verifyBtn setCountChangeBlock:^(CountdownButton *btn, NSInteger total, NSInteger left) {
		btn.enabled = NO;
		[btn setTitle:[NSString stringWithFormat:@"重新验证  %li",(long)left] forState:UIControlStateNormal];
		[btn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	}];
	[_verifyBtn setEndBlock:^(CountdownButton *btn){
		btn.enabled = YES;
		[btn setTitle:@"获取验证码" forState:UIControlStateNormal];
		[btn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	}];

	_commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commitButton.frame = CGRectMake(0, screenHeight - kNavBarHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	_commitButton.backgroundColor = WeddingTimeBaseColor;
	[_commitButton setTitle:@"提交" forState:UIControlStateNormal];
	[_commitButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.view addSubview:_commitButton];
	[_commitButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];

	_scrollView.contentSize = CGSizeMake(_scrollView.width,MAX(_scrollView.height + 15, _commitButton.bottom + 15));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
