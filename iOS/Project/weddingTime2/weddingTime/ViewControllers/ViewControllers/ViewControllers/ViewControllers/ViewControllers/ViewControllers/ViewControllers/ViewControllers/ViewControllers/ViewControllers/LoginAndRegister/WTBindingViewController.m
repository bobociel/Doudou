//
//  WTBindingViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBindingViewController.h"
#import "WTMainViewController.h"
#import "WTChangePasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CountdownButton.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "WTProgressHUD.h"
#import "UserService.h"
#import "LoginManager.h"
#import "QHNavigationController.h"
#define topGap           232.f
#define leftGap          60.f
#define itemGap          36.f
#define lineViewLeftGap  8.f
#define countDownBtnWidth 100
@interface WTBindingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyTextFidld;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet CountdownButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@end

@implementation WTBindingViewController
+ (instancetype)instanceWTBindingViewController
{
	WTBindingViewController *VC = [[WTBindingViewController alloc] initWithNibName:@"WTBindingViewController" bundle:nil];
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.translucent = NO;
	self.title = @"验证本人手机";

	_scrollView.backgroundColor = WeddingTimeBaseColor;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[_scrollView addGestureRecognizer:tap];

	_phoneTextField.placeholder = @"手机号";
	_phoneTextField.font = DefaultFont14;
	_phoneTextField.tintColor = WHITE;
	_phoneTextField.returnKeyType=UIReturnKeyNext;
	_phoneTextField.keyboardType = UIKeyboardTypePhonePad;
	[_phoneTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

	_verifyTextFidld.placeholder = @"验证码";
	_verifyTextFidld.tintColor = WHITE;
	_verifyTextFidld.font = DefaultFont14;
	_verifyTextFidld.returnKeyType=UIReturnKeyNext;
	_verifyTextFidld.keyboardType = UIKeyboardTypeNumberPad;
	[_verifyTextFidld setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

	_sendCodeBtn.titleLabel.font = DefaultFont14;
	_sendCodeBtn.layer.cornerRadius = 11.0;
	[_sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
	[_sendCodeBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];

	_nextBtn.layer.cornerRadius = 25.0;
	_nextBtn.backgroundColor = WHITE;
	[_nextBtn setTitle:@"绑定" forState:UIControlStateNormal];
	[_nextBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];

	[_sendCodeBtn setCountChangeBlock:^(CountdownButton *btn, NSInteger total, NSInteger left) {
		btn.enabled = NO;
		[btn setTitle:[NSString stringWithFormat:@"重新验证  %li",(long)left] forState:UIControlStateNormal];
	}];

	[_sendCodeBtn setEndBlock:^(CountdownButton *btn){
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

- (IBAction)backAction:(UIButton *)sender
{
	if(self.navigationController)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (IBAction)next
{
    if (![LWUtil validatePhoneNumber:_phoneTextField.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:KEY_WINDOW];
        return;
    }
    if (![_phoneTextField.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:KEY_WINDOW];
        return;
    }
    
    [self showLoadingView];

	NSString *token = TOKEN.length > 0 ? TOKEN : [LWUtil getString:self.result[@"token"] andDefaultStr:@""] ;
    [UserService bindPhoneWthPhone:_phoneTextField.text  andConfrimCode:_verifyTextFidld.text withToken:token withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doregisterFinishWithResult:result andError:error];
    }];
}

- (void)doregisterFinishWithResult:(NSDictionary *)result andError:(NSError *)err {
    if (err||!result||![result isKindOfClass:[NSDictionary class]]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:err andDefaultStr:@"出错啦,请稍后再试"] showInView:KEY_WINDOW];
        
    }else {
        [WTProgressHUD ShowTextHUD:@"绑定成功" showInView:KEY_WINDOW];
        [LoginManager loginSucceedAfter:self.result];
        [UserInfoManager instance].phone_self = _phoneTextField.text;
        [[UserInfoManager instance] saveToUserDefaults];
        [self addAnimation];
		if([UserInfoManager instance].noPSW)
		{
			WTChangePasswordViewController *VC = [[WTChangePasswordViewController alloc] init];
			[self.navigationController pushViewController:VC animated:YES];
		}
		else
		{
			if (self.navigationController) {
				[self.navigationController popToRootViewControllerAnimated:NO];
			}
			[self dismissViewControllerAnimated:YES completion:nil];
		}
    }
}

-(void)addAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = @"reveal";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

- (IBAction)getVerifyCode:(CountdownButton *)sender {
    [self showLoadingView];
    [UserService getVerifyCodeWithPhone:_phoneTextField.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"成功发送验证码" showInView:KEY_WINDOW];
            [sender startCountDownWithTime:60];
            
        }else{
            NSString *errstr ;
            if ([result isKindOfClass:[NSDictionary class]])
			{
                if ([[LWUtil getString:result[@"status"] andDefaultStr:@""] isEqualToString:@"4001"]) {
                    errstr = @"该手机号已经被绑定,绑定失败";
                }else {
                    errstr = @"您的操作过于频繁,请稍后再试";
                }
            }
			else {
                errstr = @"服务器出错啦,请稍后再试";
            }
            [WTProgressHUD ShowTextHUD:errstr showInView:KEY_WINDOW];
        }
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.view endEditing:YES];
}


@end
