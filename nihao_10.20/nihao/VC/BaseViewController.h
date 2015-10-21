//
//  BaseViewController.h
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface BaseViewController : UIViewController

- (void)setNavHiden:(BOOL)hiden;
- (void)addNavLeftBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action;
- (void)addNavRightBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action;
- (void)addNavBackBtn;
- (void)addNavBackBtn:(NSString *)title;
- (void)addNavCloseBtn;
- (void)back:(id)sender;
- (UIButton *)createNavBtnByTitle:(NSString *)label icon:(NSString *)icon action:(SEL)action;

// 不显示返回按钮的Title
- (void)dontShowBackButtonTitle;

- (void)showHUDWithText:(NSString *)text delay:(NSTimeInterval)delay;

- (void)showHUDDone;

- (void)showHUDDoneWithText:(NSString *)text;

- (void)showHUDErrorWithText : (NSString *)text;

- (void)showHUDNetError;

- (void)showHUDServerError;

- (void)showWithLabelText:(NSString *)showText executing:(SEL)method;

- (void)showHUDWithText:(NSString *)text;

- (void)processServerErrorWithCode:(NSInteger)code andErrorMsg:(NSString *)msg;

/**
 *  隐藏当前显示的提示框
 */
- (void) hideHud;

@property (nonatomic, copy) void (^hudWasHidden)(void);

// 根据传入的root VC和导航栏颜色初始化一个导航控制器
- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController navBarTintColor:(UIColor *)tintColor;

@end
