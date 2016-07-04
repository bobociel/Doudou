//
//  WTLoginViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//


#import "WTLoginViewController.h"
#import "WTRegisterViewController.h"
#import "WTMainViewController.h"
#import "WTFindBackPasswordViewController.h"
#import "ImproveMyInformationViewController.h"
#import "UIView+QHUIViewCtg.h"
#import "LWUtil.h"
#import "WTProgressHUD.h"
#import "LoginManager.h"
#import "BlingHelper.h"
#define kBottomHeight 50.0
#define UserDidLoginSucceedNotify                @"UserDidLoginSucceedNotify"
#define kViewHeight  (screenHeight - kNavBarHeight - kBottomHeight - 20) / 2.0
@interface WTLoginViewController ()<UITextFieldDelegate,LoginManagerDelegate,WXApiDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *orView;
@property (weak, nonatomic) IBOutlet UIControl *loginWXView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic,strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic,strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic,strong) IBOutlet UIButton    *loginBtn;
@property (nonatomic,strong) IBOutlet UIButton    *forgetPsaawordBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@end
@implementation WTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    loginManager=[[LoginManager alloc]init];
    loginManager.delegate = self;
	self.scrollView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	_topViewHeight.constant = kViewHeight;
	_bottomViewHeight.constant = kViewHeight;
	self.loginBtn.layer.cornerRadius = 25.0;
	self.phoneTextField.tintColor = WHITE;
	self.passwordTextField.tintColor = WHITE;
	[_phoneTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	[_passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

	_loginWXView.hidden = ![WXApi isWXAppInstalled];
	_orView.hidden = ![WXApi isWXAppInstalled];
	[self.view bringSubviewToFront:_backButton];
	[self.view bringSubviewToFront:self.bottomView];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[_scrollView addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
	_scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 10);
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
		_scrollViewTop.constant = -offsetY;
		_scrollViewBottom.constant = offsetY;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		_scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 10);
	}];
}

- (void)hideKeyboard{
	[self.view endEditing:YES];
}

#pragma mark - Action
-(IBAction)back{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)loginWithPhone{
	[self showLoadingView];
	[loginManager loginWithPhone:_phoneTextField.text andpassword:_passwordTextField.text];
}

- (IBAction)loginWX{
	[self.view endEditing:YES];
	SendAuthReq *req = [[SendAuthReq alloc] init];
	req.scope = WeChatScope;
	[WXApi sendReq:req];
}

- (IBAction)forgetPassword{
	WTFindBackPasswordViewController *findbackVC=[WTFindBackPasswordViewController new];
	[self.navigationController pushViewController:findbackVC animated:YES];
}

- (IBAction)registerAction{
	WTRegisterViewController *registerVC=[WTRegisterViewController new];
	[self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self loginWithPhone];
	return YES;
}

#pragma mark - LoginDelegate
- (void)logoutFaild:(NSString *)errInfo {
    [loadingHUD hide:NO];
    [WTProgressHUD ShowTextHUD:errInfo showInView:self.view];
}

- (void)loginSucceed:(NSDictionary*)result {
    [loadingHUD hide:YES];
    if([result[@"user_type"] isEqualToString:@"supplier"]){
        [WTProgressHUD ShowTextHUD:@"别调皮啦，您是商家用户～" showInView:self.view];
        return;
    }

	if(![result[@"is_perfect"] boolValue])
	{
		[self.navigationController pushViewController:[ImproveMyInformationViewController instanceVCWithPhone:_phoneTextField.text pwd:_passwordTextField.text token:result[@"token"]] animated:YES];
	}
	else
	{
		[LoginManager loginSucceedAfter:result];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

@end
