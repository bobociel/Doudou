//
//  WTSetPasswordViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSetPasswordViewController.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "UserService.h"
#import "WTProgressHUD.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
#define kButtonHeight 44.0
@interface WTSetPasswordViewController ()<UITextFieldDelegate>

@end

@implementation WTSetPasswordViewController
{
    UIScrollView *scrollView;
    UITextField  *passwordTextField_base;
    UITextField  *passwordTextField;
    UIButton     *loginBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    self.view.backgroundColor=[UIColor whiteColor];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    self.title                     = @"密码修改";
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:scrollView];
    
    passwordTextField_base             = [[UITextField alloc] init];
    passwordTextField_base.left        = 16;
    passwordTextField_base.top         = 30;
    passwordTextField_base.width       = screenWidth-passwordTextField_base.left;
    passwordTextField_base.height      =30;
    passwordTextField_base.delegate    = self;
    passwordTextField_base.placeholder = @"输入新密码";
    passwordTextField_base.returnKeyType=UIReturnKeyNext;
    passwordTextField_base.secureTextEntry=YES;
    [scrollView addSubview:passwordTextField_base];
    
    passwordTextField             = [[UITextField alloc] init];
    passwordTextField.bottom     = passwordTextField_base.bottom+topGap;
    passwordTextField.left       = 16;
    passwordTextField.width      = screenWidth-passwordTextField.left;
    passwordTextField.height     = 30;
    passwordTextField.delegate    = self;
    passwordTextField.placeholder = @"重复新密码";
    passwordTextField.secureTextEntry=YES;
    passwordTextField.returnKeyType=UIReturnKeyGo;
    [scrollView addSubview:passwordTextField];
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight-64-kButtonHeight, screenWidth, kButtonHeight)];
    loginBtn.centerX  =screenWidth/2.f;
    [loginBtn addTarget:self action:@selector(setPass) forControlEvents:
     UIControlEventTouchUpInside];
    [loginBtn setTitle:@"确认" forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:18];
    loginBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [self.view addSubview:loginBtn];

    UIButton *backbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backbtn.frame=CGRectMake(0, 0, 36, 32);
    [backbtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [backbtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backbtn];
    [backbtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:backItem];

    for(int i=0;i<2;i++) {
        UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(lineViewLeftGap, passwordTextField_base.bottom+i*(topGap+passwordTextField.height), screenWidth - 2*lineViewLeftGap, 0.5f)];
        lineView.backgroundColor = rgba(153, 153, 153, 0.5);
        [scrollView addSubview:lineView];
    }
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}
- (void)tapBackGround {
    
    for(UITextField *textField in scrollView.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self setPass];
    return YES;
}
- (void)setPass {
    if (passwordTextField_base.text.length<6) {
        [WTProgressHUD ShowTextHUD:@"新密码太短了哦" showInView:self.view];
        return;
    }
    
    if (![passwordTextField_base.text isEqualToString:passwordTextField.text]) {
        [WTProgressHUD ShowTextHUD:@"两次密码不一致" showInView:self.view];
        return;
    }
    
    [self showLoadingView];
    [UserService postPassWithPhoneOrEmail:_account_info Verify:_confirm_key pass:passwordTextField_base.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error||[result[@"msg"]isEqualToString:@"failure"]) {
            NSString *errStr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,请稍后再试"];
            
            [WTProgressHUD ShowTextHUD:errStr showInView:self.view];
            
        }else {
            [WTProgressHUD ShowTextHUD:@"修改密码成功" showInView:self.view];
            [self performSelector:@selector(backLogin) withObject:nil afterDelay:1.5];
        }
    }];
}

-(void)backLogin
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
