//
//  WTRegisterViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTRegisterViewController.h"
#import "WTLoginViewController.h"
#import "ImproveMyInformationViewController.h"
#import "CountdownButton.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "WTProgressHUD.h"
#import "UserService.h"
#import "WTBindingViewController.h"
#import "UserInfoManager.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
@interface WTRegisterViewController ()<UITextFieldDelegate>

@end

@implementation WTRegisterViewController
{
    UITextField *phoneTextfield;
    UITextField *verifyTextfield;
    UITextField *passwordTextfield;
    CountdownButton *verifyBtn;
    UIButton *registerBtn;
    UIButton *backBtn;
    UIScrollView *scrollView;
    UILabel *serviceLabel;
    UIButton *serviceBtn;
    UIButton *privacyBtn;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
}

-(void)initView{
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    self.title=@"注册";
    self.view.backgroundColor      = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight)];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    
    phoneTextfield             = [[UITextField alloc] init];
    phoneTextfield.top         = 30;
    phoneTextfield.left = 16;
    phoneTextfield.width = screenWidth - phoneTextfield.left;
    phoneTextfield.height=30.f;
    [phoneTextfield setFont:[WeddingTimeAppInfoManager fontWithSize:16]];
    [phoneTextfield setTextColor:titleLableColor];
    phoneTextfield.delegate    = self;
    phoneTextfield.placeholder = @"输入手机号";
    phoneTextfield.returnKeyType=UIReturnKeyNext;
    phoneTextfield.keyboardType=UIKeyboardTypeNumberPad;
    [scrollView addSubview:phoneTextfield];
    
    verifyBtn = [[CountdownButton alloc] initWithFrame:CGRectMake(phoneTextfield.right-110, 0, 100, 30)];
    [verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [verifyBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    [verifyBtn addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    verifyBtn.centerY                    = phoneTextfield.centerY;
    verifyBtn.titleLabel.font            = [WeddingTimeAppInfoManager fontWithSize:16];
    verifyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [verifyBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    [scrollView addSubview:verifyBtn];
    
    [verifyBtn setCountChangeBlock:^(CountdownButton *btn, NSInteger total, NSInteger left) {
        btn.enabled = NO;
        [btn setTitle:[NSString stringWithFormat:@"重新验证  %li",(long)left] forState:UIControlStateNormal];
        [btn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    }];
    
    [verifyBtn setEndBlock:^(CountdownButton *btn){
        btn.enabled = YES;
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [btn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    }];
    
    verifyTextfield             = [[UITextField alloc] init];
    verifyTextfield .bottom     = phoneTextfield.bottom+topGap;
    verifyTextfield.left = 16;
    verifyTextfield.width = screenWidth - verifyTextfield.left;
    verifyTextfield.height=30.f;
    [verifyTextfield setFont:[WeddingTimeAppInfoManager fontWithSize:16]];
    [verifyTextfield setTextColor:titleLableColor];
    verifyTextfield.delegate    = self;
    verifyTextfield.placeholder = @"验证码";
    verifyTextfield.returnKeyType=UIReturnKeyGo;
    verifyTextfield.keyboardType=UIKeyboardTypeNumberPad;
    [scrollView addSubview:verifyTextfield];
    
    passwordTextfield             = [[UITextField alloc] init];
    passwordTextfield .bottom     = verifyTextfield.bottom+topGap;
    passwordTextfield.left = 16;
    passwordTextfield.width = screenWidth - passwordTextfield.left;
    passwordTextfield.height=30.f;
    [passwordTextfield setFont:[WeddingTimeAppInfoManager fontWithSize:16]];
    [passwordTextfield setTextColor:titleLableColor];
    passwordTextfield.delegate    = self;
    passwordTextfield.placeholder = @"设置密码";
    passwordTextfield.secureTextEntry=YES;
    passwordTextfield.returnKeyType=UIReturnKeyGo;
    [scrollView addSubview:passwordTextfield];
    
    serviceLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, passwordTextfield.bottom+20, 238, 15)];
    serviceLabel.text=@"婚礼时光的                                 ";
    serviceLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    serviceLabel.userInteractionEnabled=YES;
    serviceLabel.textColor=titleLableColor;
    UILabel *andLabel = [[UILabel alloc] initWithFrame:CGRectMake(113, 0, 13, 15)];
    andLabel.text = @"及";
    andLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    andLabel.textColor = titleLableColor;
    [serviceLabel addSubview:andLabel];
    serviceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    serviceBtn.frame=CGRectMake(62, 0, 48, 15);
    [serviceBtn setTitle:@"服务条款" forState:UIControlStateNormal];
    [serviceBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    serviceBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    [serviceBtn addTarget:self action:@selector(showService) forControlEvents:UIControlEventTouchUpInside];
    
    privacyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    privacyBtn.frame=CGRectMake(130, 0, 48, 15);
    [privacyBtn setTitle:@"隐私政策" forState:UIControlStateNormal];
    [privacyBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    privacyBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    [privacyBtn addTarget:self action:@selector(showPrivacy) forControlEvents:UIControlEventTouchUpInside];
    
    [serviceLabel addSubview:serviceBtn];
    [serviceLabel addSubview:privacyBtn];
    [scrollView addSubview:serviceLabel];

    for(int i=0;i<3;i++) {
        UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(lineViewLeftGap, phoneTextfield.bottom+i*(topGap+verifyTextfield.height), screenWidth - 2*lineViewLeftGap, 0.5f)];
        lineView.backgroundColor=[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.5] ;
        [scrollView addSubview:lineView];
    }
    
    registerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame=CGRectMake(0, self.view.height-64-50, screenWidth, 50);
    registerBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(Next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
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
    [self Next];
    return YES;
}

-(void)Next{
    if (![LWUtil validatePhoneNumber:phoneTextfield.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    if (![verifyTextfield.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:self.view];
        return;
    }
    
    if (passwordTextfield.text.length<6) {
        [WTProgressHUD ShowTextHUD:@"密码不足6位" showInView:self.view];
        return;
    }
    [self showLoadingView];
    [UserService registerWithPhone:phoneTextfield.text andPassword:passwordTextfield.text andConfrimCode:verifyTextfield.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doregisterFinishWithResult:result andError:error];
    }];
}

- (void)doregisterFinishWithResult:(NSDictionary *)result andError:(NSError *)err {
    if (err||!result||![result isKindOfClass:[NSDictionary class]]||!result[@"token"]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:err andDefaultStr:@"出错啦,请稍后再试"] showInView:self.view];
    }else {
        [UserInfoManager instance].tokenId_self  = result[@"token"];
        [UserInfoManager instance].userId_self   = [LWUtil getString:result[@"id"] andDefaultStr:@""] ;
        [UserInfoManager instance].phone_self=phoneTextfield.text;
        
        ImproveMyInformationViewController *next=[[ImproveMyInformationViewController alloc] init];
        next.pass_word=passwordTextfield.text;
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (void)getVerifyCode:(CountdownButton *)sender {
    if (![LWUtil validatePhoneNumber:phoneTextfield.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    [self showLoadingView];
    [UserService getVerifyCodeWithPhone:phoneTextfield.text withBlock:^(NSDictionary *result, NSError *error) {
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
-(void)showService{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/service_term"]];
}

-(void)showPrivacy{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/privacy_term"]];
}






@end
