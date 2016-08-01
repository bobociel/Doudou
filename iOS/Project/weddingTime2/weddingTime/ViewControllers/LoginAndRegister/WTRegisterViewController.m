//
//  WTRegisterViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTRegisterViewController.h"
#import "ImproveMyInformationViewController.h"
#import "CountdownButton.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "WTProgressHUD.h"
#import "UserService.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
@interface WTRegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UITextField *verifyTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet CountdownButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@end

@implementation WTRegisterViewController
{
    UILabel *serviceLabel;
    UIButton *serviceBtn;
    UIButton *privacyBtn;

}
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"注册";
	self.scrollView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	self.scrollView.showsVerticalScrollIndicator = NO;

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[_scrollView addGestureRecognizer:tap];

	self.passwordTextfield.tintColor = WHITE;
	[_passwordTextfield setValue:WHITE forKeyPath:@"_placeholderLabel.textColor"];
	self.phoneTextfield.tintColor = WHITE;
	[_phoneTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	self.verifyTextfield.tintColor = WHITE;
	[_verifyTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	
	self.verifyBtn.layer.cornerRadius = 11.0;
	self.registerBtn.layer.cornerRadius = 25.0;
	[_verifyBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	
	[_verifyBtn setCountChangeBlock:^(CountdownButton *btn, NSInteger total, NSInteger left) {
		btn.enabled = NO;
		[btn setTitle:[NSString stringWithFormat:@"重新验证  %li",(long)left] forState:UIControlStateNormal];
	}];

	[_verifyBtn setEndBlock:^(CountdownButton *btn){
		btn.enabled = YES;
		[btn setTitle:@"获取验证码" forState:UIControlStateNormal];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardFrameChanged:(NSNotification *)noti
{
	double aniDur = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offsetY = keyboardFrame.origin.y == screenHeight ? 0 : keyboardFrame.size.height;
	[UIView animateWithDuration:offsetY == 0 ? aniDur : aniDur + 0.5 delay:0 options:7 animations:^{
		_scrollViewBottom.constant = offsetY;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {

	}];
}

- (void)hideKeyboard
{
	[self.view endEditing:YES];
}

- (IBAction)tapBackGround {
	[self.view endEditing:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self Next];
    return YES;
}

-(IBAction)Next
{
    if (![LWUtil validatePhoneNumber:_phoneTextfield.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    if (![_verifyTextfield.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:self.view];
        return;
    }
    
    if (_passwordTextfield.text.length<6) {
        [WTProgressHUD ShowTextHUD:@"密码不足6位" showInView:self.view];
        return;
    }
    [self showLoadingView];
    [UserService registerWithPhone:_phoneTextfield.text andPassword:_passwordTextfield.text andConfrimCode:_verifyTextfield.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doregisterFinishWithResult:result andError:error];
    }];
}

- (void)doregisterFinishWithResult:(NSDictionary *)result andError:(NSError *)err {
    if (err||!result||![result isKindOfClass:[NSDictionary class]]||!result[@"token"]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:err andDefaultStr:@"出错啦,请稍后再试"] showInView:self.view];
    }else {
        [self.navigationController pushViewController:[ImproveMyInformationViewController instanceVCWithPhone:_phoneTextfield.text pwd:_passwordTextfield.text token:result[@"token"]] animated:YES];
    }
}

- (IBAction)getVerifyCode:(CountdownButton *)sender {
    if (![LWUtil validatePhoneNumber:_phoneTextfield.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    [self showLoadingView];
    [UserService getVerifyCodeWithPhone:_phoneTextfield.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"成功发送验证码" showInView:self.view];
            [sender startCountDownWithTime:60];
            
        }else{
            NSString *errstr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出问题啦,请稍后再试"];
            
            if (error.code==403) {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    if ([[LWUtil getString:result[@"status"] andDefaultStr:@""] isEqualToString:@"4001"]) {
                        errstr = @"该手机号已经被注册,您可以直接登录";
                    }else {
                        errstr = @"您的操作过于频繁,请稍后再试";
                    }
                }else {
                    errstr = @"服务器出错啦,请稍后再试";
                }
            }
            
            [WTProgressHUD ShowTextHUD:errstr showInView:self.view];
        }
    }];
}

- (IBAction)registerSupplier:(UIButton *)sender
{
	if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weddingTreasure://"]]){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/hun-li-shi-guang/id1024931719"]];
	}
}

-(void)showService{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/service_term"]];
}

-(IBAction)showPrivacy{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/privacy_term"]];
}

@end
