//
//  WTLoginViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//


#import "WTLoginViewController.h"
#import "UIView+QHUIViewCtg.h"
#import "WTBindingViewController.h"
#import "WTRegisterViewController.h"
#import "LWUtil.h"
#import "WTFindBackPasswordViewController.h"
#import "WTProgressHUD.h"
#import "LoginManager.h"
#import "WTMainViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "BlingHelper.h"
#import "WTPCViewController.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
#define UserDidLoginSucceedNotify                @"UserDidLoginSucceedNotify"

@interface WTLoginViewController ()<UITextFieldDelegate,LoginManagerDelegate>
@end
@implementation WTLoginViewController
{
    TPKeyboardAvoidingScrollView *scrollView;
    UITextField  *phoneTextField;
    UITextField  *passwordTextField;
    UIButton     *loginBtn;
    UIButton     *forgetPsaawordBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    loginManager=[[LoginManager alloc]init];
    loginManager.delegate       = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self loginWithPhone];
    return YES;
}

-(void)initView{
    UIView *firstView=[[UIView alloc] initWithFrame:self.view.bounds];
    firstView.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:firstView];
    
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.clipsToBounds=NO;
    self.title                     = @"登录";
    self.view.backgroundColor      = [UIColor whiteColor];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    [self.view addSubview:scrollView];
    
    phoneTextField             = [[UITextField alloc] init];
    phoneTextField.top         = 30;
    phoneTextField.left = 16;
    phoneTextField.width = screenWidth - phoneTextField.left;
    phoneTextField.height=30.f;
    [phoneTextField setFont:[WeddingTimeAppInfoManager fontWithSize:16]];
    [phoneTextField setTextColor:titleLableColor];
    phoneTextField.delegate    = self;
    phoneTextField.placeholder = @"邮箱/手机号";
    phoneTextField.returnKeyType=UIReturnKeyNext;
    [scrollView addSubview:phoneTextField];
    
    passwordTextField             = [[UITextField alloc] init];
    passwordTextField .bottom     = phoneTextField.bottom+topGap;
    passwordTextField.left = 16;
    passwordTextField.width = screenWidth - passwordTextField.left;
    passwordTextField.height=30.f;
    [passwordTextField setFont:[WeddingTimeAppInfoManager fontWithSize:16]];
    [passwordTextField setTextColor:titleLableColor];
    passwordTextField.font        = [WeddingTimeAppInfoManager fontWithSize:16];
    passwordTextField.textColor   = titleLableColor;
    passwordTextField.delegate    = self;
    passwordTextField.placeholder = @"密码";
    passwordTextField.secureTextEntry=YES;
    passwordTextField.returnKeyType=UIReturnKeyGo;
    [scrollView addSubview:passwordTextField];
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.height-64-50, screenWidth, 50)];
    [loginBtn addTarget:self action:@selector(loginWithPhone) forControlEvents:
     UIControlEventTouchUpInside];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    loginBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:18];
    [self.view addSubview:loginBtn];
    
    forgetPsaawordBtn=[[UIButton alloc]initWithFrame:CGRectMake(16, passwordTextField.bottom+20, 70, 50)];
    [forgetPsaawordBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [forgetPsaawordBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    forgetPsaawordBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    forgetPsaawordBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    [forgetPsaawordBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    [scrollView addSubview:forgetPsaawordBtn];
    
    for(int i=0;i<2;i++) {
        UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(lineViewLeftGap, phoneTextField.bottom+i*(topGap+passwordTextField.height), screenWidth - 2*lineViewLeftGap, 0.5f)];
        lineView.backgroundColor=[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.5] ;
        [scrollView addSubview:lineView];
    }
    
    [self setRightBtnWithTitle:@"注册"];
    
    UIButton *backbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backbtn.frame=CGRectMake(0, 0, 36, 32);
    [backbtn setImage:[UIImage imageNamed:@"close_nav"] forState:UIControlStateNormal];
    [backbtn setImage:[UIImage imageNamed:@"close_nav"] forState:UIControlStateHighlighted];
    [backbtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backbtn];
    [backbtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)logoutFaild:(NSString *)errInfo {
    [loadingHUD hide:NO];
    [WTProgressHUD ShowTextHUD:errInfo showInView:self.view];
}

- (void)loginSucceed:(NSDictionary*)result {
    [loadingHUD hide:YES];
    if([result[@"user_type"] isEqualToString:@"supplier"])
    {
        [WTProgressHUD ShowTextHUD:@"别调皮啦，您是商家用户～" showInView:self.view];
        return;
    }
    
    if(![result[@"phone"] isNotEmptyCtg])
    {
        //进入绑定界面
        WTBindingViewController *next=[WTBindingViewController new];
        next.result=result;
        [self.navigationController  pushViewController:next animated:YES];
        return;
    }
    
    [LoginManager loginSucceedAfter:result];

    [self dismissViewControllerAnimated:YES completion:^{
        [BlingHelper updateInviteState];
    }];
}

-(void)loginWithPhone{
    [self showLoadingView];
    [loginManager loginWithPhone:phoneTextField.text andpassword:passwordTextField.text];
}

-(void)forgetPassword{
    WTFindBackPasswordViewController *findbackVC=[WTFindBackPasswordViewController new];
    [self.navigationController pushViewController:findbackVC animated:YES];
}

-(void)rightNavBtnEvent{
    WTRegisterViewController *registerVC=[WTRegisterViewController new];
    [self.navigationController pushViewController:registerVC animated:YES];
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}
@end
