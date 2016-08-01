//
//  ChangePasswordViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/6/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTChangePasswordViewController.h"
#import "UserService.h"
#import "LWAssistUtil.h"
#import "WTAlertView.h"
#import "WeddingTimeAppInfoManager.h"
#define leftGap 15.f
#define kButtonHeight 44.0
@interface WTChangePasswordViewController ()

@end

@implementation WTChangePasswordViewController
{
    UITextField *passwordBeforeInput;
    UITextField *passwordInput;
    UITextField *passwordAngainInput;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.title = @"修改密码";
}

- (void)tapBackGround {
    [self.view endEditing:YES];
}

- (void)done {
    if (![passwordBeforeInput.text isNotEmptyCtg]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"还没填写原密码哦" centerImage:nil];
        [alertView show];
        return;
    }
    
    if (passwordInput.text.length<6) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"新密码太短了哦" centerImage:nil];
        [alertView show];
        return;
    }

    if (![passwordInput.text isEqualToString:passwordAngainInput.text]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"两次密码不一致" centerImage:nil];
        [alertView show];
        return;
    }
    [self showLoadingView];
    [UserService postChangePasswordWithOld:passwordBeforeInput.text andnew:passwordInput.text WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            NSString *errStr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,请稍后再试"];
            if (error.code ==401) {
                errStr = @"原密码不正确";
            }
            WTAlertView *alertView=[[WTAlertView alloc]initWithText:errStr centerImage:nil];
            [alertView show];

        }else {
            WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"修改密码成功" centerImage:nil];
            [alertView show];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
        }
    }];
}

- (void)initView {
    self.view.backgroundColor=[UIColor whiteColor];

    NSArray *array=[NSArray arrayWithObjects:@"输入原密码",@"输入新密码",@"确认新密码", nil];
    for (int i = 0; i<array.count; i++) {
        UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(leftGap, 60+i*50, screenWidth-leftGap, 0.5)];
        [LWAssistUtil imageViewSetAsLineView:lineView color:[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:0.5f]];
        [self.view addSubview:lineView];
    }
    passwordBeforeInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap,15+2, screenWidth-2*leftGap, 50)];
    passwordBeforeInput.placeholder=array[0];
    passwordBeforeInput.secureTextEntry=YES;
    [self.view addSubview:passwordBeforeInput];
    
    
    passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap, passwordBeforeInput.bottom+2, screenWidth-2*leftGap, 50)];
    passwordInput.placeholder=array[1];
    passwordInput.secureTextEntry=YES;
    [self.view addSubview:passwordInput];
    
    passwordAngainInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap, passwordInput.bottom+2, screenWidth-2*leftGap, 50)];
    passwordAngainInput.placeholder=array[2];
    passwordAngainInput.secureTextEntry=YES;
    [self.view addSubview:passwordAngainInput];

    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight-kButtonHeight-64, screenWidth, kButtonHeight)];
    doneBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    doneBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:18];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.centerX=screenWidth/2.f;
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
@end
