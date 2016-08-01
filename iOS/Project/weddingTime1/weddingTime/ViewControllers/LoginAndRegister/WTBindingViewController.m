//
//  WTBindingViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBindingViewController.h"
#import "CountdownButton.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "WTProgressHUD.h"
#import "UserService.h"
#import "LoginManager.h"
#import "WTMainViewController.h"
#import "QHNavigationController.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
#define countDownBtnWidth 100
@interface WTBindingViewController ()<UITextFieldDelegate>

@end

@implementation WTBindingViewController
{
    UIScrollView *scrollView;
    UITextField  *phoneTextField;
    UITextField  *verifyTextFidld;
    UIButton     *nextBtn;
    UIButton     *serviceBtn;
    CountdownButton     *sendCodeBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}


- (void)next {
    if (![LWUtil validatePhoneNumber:phoneTextField.text]) {
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:KEY_WINDOW];
        return;
    }
    if (![verifyTextFidld.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"请输入验证码" showInView:KEY_WINDOW];
        return;
    }
    
    [self showLoadingView];
    
    [UserService bindPhoneWthPhone:phoneTextField.text  andConfrimCode:verifyTextFidld.text withToken:[LWUtil getString:self.result[@"token"] andDefaultStr:@""] withBlock:^(NSDictionary *result, NSError *error) {
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
        [UserInfoManager instance].phone_self=phoneTextField.text;
        [[UserInfoManager instance] saveToUserDefaults];
        [self addAnimation];
        if (self.navigationController) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)getVerifyCode:(CountdownButton *)sender {
    [self showLoadingView];
    [UserService getVerifyCodeWithPhone:phoneTextField.text withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"成功发送验证码" showInView:KEY_WINDOW];
            [sender startCountDownWithTime:60];
            
        }else{
            NSString *errstr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出问题啦,请稍后再试"];
            if ([result isKindOfClass:[NSDictionary class]]) {
                if ([[LWUtil getString:result[@"status"] andDefaultStr:@""] isEqualToString:@"4001"]) {
                    errstr = @"该手机号已经被绑定,绑定失败";
                }else {
                    errstr = @"您的操作过于频繁,请稍后再试";
                }
            }else {
                errstr = @"服务器出错啦,请稍后再试";
            }
            [WTProgressHUD ShowTextHUD:errstr showInView:KEY_WINDOW];
        }
    }];
}

#pragma mark - init
- (void)initView {
    self.title = @"绑定";
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    self.view.backgroundColor=[UIColor whiteColor];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:scrollView];
    
    phoneTextField             = [[UITextField alloc] init];
    phoneTextField.left        = 16;
    phoneTextField.top         = topGap;
    phoneTextField.width       = screenWidth-phoneTextField.left;
    phoneTextField.height=30;
    phoneTextField.delegate    = self;
    phoneTextField.placeholder = @"手机号";
    phoneTextField.font=[WeddingTimeAppInfoManager fontWithSize:14];
    phoneTextField.returnKeyType=UIReturnKeyNext;
    phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [scrollView addSubview:phoneTextField];
    
    
    sendCodeBtn = [[CountdownButton alloc] initWithFrame:CGRectMake(phoneTextField.right-countDownBtnWidth-10, 0, countDownBtnWidth, 30)];
    [sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [sendCodeBtn addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    sendCodeBtn.centerY                    = phoneTextField.centerY;
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
    
    verifyTextFidld             = [[UITextField alloc] init];
    verifyTextFidld.left        =16;
    verifyTextFidld.width       =screenWidth-verifyTextFidld.left;
    verifyTextFidld.height      =30;
    verifyTextFidld.top         =phoneTextField.bottom+ topGap;
    verifyTextFidld.delegate    = self;
    verifyTextFidld.placeholder = @"验证码";
    verifyTextFidld.returnKeyType=UIReturnKeyNext;
    verifyTextFidld.keyboardType = UIKeyboardTypeNumberPad;
    [scrollView addSubview:verifyTextFidld];
    
    nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight-64-50, screenWidth, 50)];
    nextBtn.centerX  =screenWidth/2.f;
    [nextBtn addTarget:self action:@selector(next) forControlEvents:
     UIControlEventTouchUpInside];
    [nextBtn setTitle:@"绑定" forState:UIControlStateNormal];
    nextBtn.height=50.f;
    nextBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
    
    for(int i=0;i<2;i++) {
        UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(lineViewLeftGap, phoneTextField.bottom+i*(topGap+30), screenWidth - 2*lineViewLeftGap, 0.5f)];
        lineView.backgroundColor=[UIColor colorWithRed:153/255.0 green:153/255.0  blue:153/255.0  alpha:1.0];
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

@end
