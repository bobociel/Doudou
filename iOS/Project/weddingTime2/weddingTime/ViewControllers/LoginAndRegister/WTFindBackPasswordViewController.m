//
//  FindBackPasswordViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFindBackPasswordViewController.h"
#import "CountdownButton.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "WTProgressHUD.h"
#import "UserService.h"
#import "WTSetPasswordViewController.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
#define countDownBtnWidth 100
@interface WTFindBackPasswordViewController ()<UITextFieldDelegate>

@end

@implementation WTFindBackPasswordViewController
{
    UIScrollView *scrollView;
    UIButton     *nextBtn;
    UIButton     *serviceBtn;
    CountdownButton     *sendCodeBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    self.title=@"密码找回";
    self.view.backgroundColor      = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];

    _phoneTextField             = [[UITextField alloc] init];
    _phoneTextField.left        = 16;
    _phoneTextField.top         = topGap;
    _phoneTextField.height      = 30;
    _phoneTextField.width       = screenWidth-_phoneTextField.left;
    _phoneTextField.delegate    = self;
    _phoneTextField.placeholder = @"手机号";
    _phoneTextField.returnKeyType=UIReturnKeyNext;
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [scrollView addSubview:_phoneTextField];
    
    
    sendCodeBtn = [[CountdownButton alloc] initWithFrame:CGRectMake(screenWidth-countDownBtnWidth-10, 0, countDownBtnWidth, 30)];
    [sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [sendCodeBtn addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    sendCodeBtn.centerY                    = _phoneTextField.centerY;
    sendCodeBtn.titleLabel.font            = [WeddingTimeAppInfoManager fontWithSize:14];
    sendCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [sendCodeBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    [scrollView addSubview:sendCodeBtn];
    
    [sendCodeBtn setCountChangeBlock:^(CountdownButton *btn, NSInteger total, NSInteger left) {
        btn.enabled = NO;
        [btn setTitle:[NSString stringWithFormat:@"重新验证  %li",(long)left] forState:UIControlStateNormal];
    }];
    
    [sendCodeBtn setEndBlock:^(CountdownButton *btn){
        btn.enabled = YES;
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }];
    
    _verifyTextFidld             = [[UITextField alloc] init];
    _verifyTextFidld.left        = 16;
    _verifyTextFidld.top         =_phoneTextField.bottom+ topGap;
    _verifyTextFidld.width       =screenWidth-_verifyTextFidld.left;
    _verifyTextFidld.height      =30;
    _verifyTextFidld.delegate    = self;
    _verifyTextFidld.placeholder = @"验证码";
    _verifyTextFidld.returnKeyType=UIReturnKeyGo;
    _verifyTextFidld.keyboardType = UIKeyboardTypeNumberPad;
    [scrollView addSubview:_verifyTextFidld];
    
    
    nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight-64-50, screenWidth, 50)];
    nextBtn.centerX  =screenWidth/2.f;
    [nextBtn addTarget:self action:@selector(next) forControlEvents:
     UIControlEventTouchUpInside];
    [nextBtn setTitle:@"确认" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    nextBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [self.view addSubview:nextBtn];
    
    for(int i=0;i<2;i++) {
        UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(lineViewLeftGap, _phoneTextField.bottom+i*(topGap+30), screenWidth - 2*lineViewLeftGap, 0.5f)];
        lineView .backgroundColor=rgba(200, 200, 200, 1.0);
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

- (void)getVerifyCode:(CountdownButton *)sender{
    if (![LWUtil validatePhoneNumber:_phoneTextField.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    [self showLoadingView];
    
    [UserService getVerifyCodeWithPhoneOrEmail:_phoneTextField.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"成功发送验证码" showInView:self.view];
            [sender startCountDownWithTime:60];
        }else{
            NSString *errstr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出问题啦,请稍后再试"];
            
            if (error.code==403) {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    if ([[LWUtil getString:result[@"status"] andDefaultStr:@""] isEqualToString:@"4001"]) {
                        errstr = @"验证码错误，请重新输入";
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

- (void)next {
    if (![LWUtil validatePhoneNumber:_phoneTextField.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
        return;
    }
    if (![_verifyTextFidld.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:self.view];
        return;
    }
    
    [self showLoadingView];
    [UserService postVerifyCodeWithPhoneOrEmail:_phoneTextField.text Verify:_verifyTextFidld.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doregisterFinishWithResult:result andError:error];
    }];
}

- (void)doregisterFinishWithResult:(NSDictionary *)result andError:(NSError *)err {
    if (err||!result||![result isKindOfClass:[NSDictionary class]]||[result[@"msg"]isEqualToString:@"failure"]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:err andDefaultStr:@"出错啦,请稍后再试"] showInView:self.view];
    }else {
        WTSetPasswordViewController *next=[WTSetPasswordViewController new];
        next.account_info=_phoneTextField.text;
        next.confirm_key=_verifyTextFidld.text;
        [self.navigationController pushViewController:next animated:YES];
    }
}

@end
