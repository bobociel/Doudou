//
//  BaseViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#define HUD_DELAY 1.5

@interface BaseViewController () <MBProgressHUDDelegate>

@end

@implementation BaseViewController {
    MBProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题栏不能覆盖下面viewcontroller的内容
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = RootBackgroundColor;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.hidesBottomBarWhenPushed = YES;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    self.hidesBottomBarWhenPushed = NO;
}

-(void)setNavHiden:(BOOL)hiden {
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:hiden animated:YES];
    }
}

- (UIButton *)createNavBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL) action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,60,40);
    if(title) {
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = FontNeveLightWithSize(16);
    }
    if(icon) {
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
        if(title) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        }
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/**
 *  添加nav左按钮
 *  @param title 按钮的标题
 *  @param icon 按钮的图片
 *  @param action 按钮的点击事件
 */
-(void) addNavLeftBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createNavBtnByTitle:title icon:icon action:action]];
}

-(void) addNavBackBtn:(NSString *)title {
    [self addNavLeftBtnByTitle:title icon:@"arrow_white" action:@selector(back:)];
}

-(void) addNavBackBtn {
    [self addNavBackBtn:@"back"];
}

/**
 *	添加nav右按钮
 *
 *	@param 	title 	文字
 *	@param 	icon 	图片
 *	@param 	action 	动作
 */
- (void)addNavRightBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createNavBtnByTitle:title icon:icon action:action]];
}

//navBar关闭按钮
- (void)addNavCloseBtn {
    [self addNavRightBtnByTitle:nil icon:@"nav_bar_close_btn_img.png" action:@selector(close:)];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

- (void)dontShowBackButtonTitle {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController navBarTintColor:(UIColor *)tintColor {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navController.navigationBar.barTintColor = tintColor;
    navController.navigationBar.tintColor = [UIColor whiteColor];
    [navController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
	navController.navigationBar.translucent = NO;
    
    return navController;
}

- (void)addBackBtn {
    UIImage *backImage = [UIImage imageNamed:@"nav_bar_back_btn_img.png"];
    // 设置导航栏按钮的点击执行方法等
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick)];
    backItem.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    NSArray *leftButtonItems = @[backItem];
    self.navigationItem.leftBarButtonItems = leftButtonItems;
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HUD
- (void)showHUDWithText:(NSString *)text delay:(NSTimeInterval)delay {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Configure for text only and offset down
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = text;
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:delay];
}

- (void)showHUDDone {
	[self showHUDDoneWithText:@"Completed"];
}

- (void)showHUDDoneWithText:(NSString *)text {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_right"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = text;
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDErrorWithText : (NSString *)text {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD show:YES];
    [HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDNetError {
	[self showHUDErrorWithText:BAD_NETWORK];
}

- (void)showHUDServerError {
	[self showHUDErrorWithText:@"Server Error"];
}

- (void)showWithLabelText:(NSString *)showText executing:(SEL)method {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = showText;
    [HUD showWhileExecuting:method onTarget:self withObject:nil animated:YES];
}

- (void)showHUDWithText:(NSString *)text {
    [self hideHud];
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = text;
	HUD.margin = 10.f;
	HUD.removeFromSuperViewOnHide = YES;
}

- (void)processServerErrorWithCode:(NSInteger)code andErrorMsg:(NSString *)msg {
	if (code == 500) {
		[self showHUDServerError];
	} else {
        [self showHUDErrorWithText:msg];
	}
}

- (void) hideHud {
    if (HUD && !HUD.isHidden) {
        [HUD hide:NO];
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (self.hudWasHidden) {
        self.hudWasHidden();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
