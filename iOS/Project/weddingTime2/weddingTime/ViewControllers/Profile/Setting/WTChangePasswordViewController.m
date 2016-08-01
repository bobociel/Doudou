//
//  ChangePasswordViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/6/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTChangePasswordViewController.h"
#import "WTSettingViewController.h"
#import "UserService.h"
#import "LWAssistUtil.h"
#import "WTAlertView.h"
#import "WeddingTimeAppInfoManager.h"
#define leftGap 15.f
#define kButtonHeight 44.0
@interface WTChangePasswordViewController ()
@property (nonatomic,assign) BOOL isSet;
@property (nonatomic,copy) NSString *token;
@end

@implementation WTChangePasswordViewController
{
    UITextField *passwordBeforeInput;
    UITextField *passwordInput;
    UITextField *passwordAngainInput;
}

+ (instancetype)instanceVCWithToken:(NSString *)token
{
	WTChangePasswordViewController *VC = [WTChangePasswordViewController new];
	VC.token = token;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_isSet = [UserInfoManager instance].noPSW;
	self.title = _isSet ? @"设置密码" : @"修改密码";
    [self initView];
}

- (void)done {
    if (![passwordBeforeInput.text isNotEmptyCtg] && ![UserInfoManager instance].noPSW ) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"还没填写原密码哦" centerImage:nil];
        [alertView show];
        return;
    }
    
    if (passwordInput.text.length < 6) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"密码太短了哦" centerImage:nil];
        [alertView show];
        return;
    }

    if (![passwordInput.text isEqualToString:passwordAngainInput.text]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"两次密码不一致" centerImage:nil];
        [alertView show];
        return;
    }

    [self showLoadingView];
	[UserService postChangePasswordWithToken:_token
										 Key:[UserInfoManager instance].noPSW ? @"new" : @"update"
										 old:passwordBeforeInput.text
									  andnew:passwordInput.text
								   WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error)
		{
            NSString *errStr = [LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,请稍后再试"];
            if (error.code ==401 && ![UserInfoManager instance].noPSW) {
                errStr = @"原密码不正确";
            }
            WTAlertView *alertView=[[WTAlertView alloc]initWithText:errStr centerImage:nil];
            [alertView show];
        }
		else
		{
			NSString *content = _isSet ? @"设置密码成功" : @"修改密码成功" ;
            WTAlertView *alertView = [[WTAlertView alloc] initWithText:content centerImage:nil];
            [alertView show];
			[UserInfoManager instance].noPSW = NO;
			[UserInfoManager instance].tokenId_self = _token;
			[[UserInfoManager instance] saveToUserDefaults];
			[[UserInfoManager instance] saveOtherToUserDefaults];
			[[UserInfoManager instance] updateUserInfoFromServer];
			if(_isSet){
				[LoginManager makeMainViewControllerWithAnimation:YES];
			}else{
				[self.navigationController popViewControllerAnimated:YES];
			}
        }
    }];
}

- (void)initView {

	NSMutableArray *textArray = [UserInfoManager instance].noPSW  ? [@[@"输入密码",@"输入确认密码"] mutableCopy] : [@[@"输入原密码",@"输入新密码",@"输入确认密码"] mutableCopy] ;

    for (int i = 0; i < textArray.count; i++)
	{
        UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(leftGap, 60+i*50, screenWidth-leftGap, 0.5)];
        [LWAssistUtil imageViewSetAsLineView:lineView color:rgba(204, 204, 204, 0.5)];
        [self.view addSubview:lineView];
    }

    passwordBeforeInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap,15+2, screenWidth-2*leftGap, 50)];
    passwordBeforeInput.placeholder = @"输入原始密码";
    passwordBeforeInput.secureTextEntry = YES;
    [self.view addSubview:passwordBeforeInput];
    
	passwordBeforeInput.height = [UserInfoManager instance].noPSW  ? 0 : 50 ;

    passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap, passwordBeforeInput.bottom+2, screenWidth-2*leftGap, 50)];
	passwordInput.placeholder = [UserInfoManager instance].noPSW ? @"输入密码" : @"输入新密码";
    passwordInput.secureTextEntry = YES;
    [self.view addSubview:passwordInput];
    
    passwordAngainInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap, passwordInput.bottom+2, screenWidth-2*leftGap, 50)];
    passwordAngainInput.placeholder = @"输入确认密码";
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
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.view endEditing:YES];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
