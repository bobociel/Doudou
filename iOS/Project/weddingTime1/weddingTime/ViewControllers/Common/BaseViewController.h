//
//  BaseViewController.h
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "LoginManager.h"
@interface BaseViewController : UIViewController
{
    id            data;
    MBProgressHUD *loadingHUD;
    LoginManager  *loginManager;
}

@property (nonatomic,strong)MBProgressHUD *loadingHUD;
//请求完成后的数据源
@property (nonatomic,retain)id data;

//如果需要用到tableView
@property (nonatomic,strong)UITableView *dataTableView;

//请求数据,请在子类里面处理 无需调用super
- (void)loadData;

//重新请求数据,请在子类里面处理 无需调用super
- (void)reloadData;

- (void)cleanData;

- (void)setDataTableViewAsDefault:(CGRect)frame;
//返回
- (void)back;

-(void)setNavWithClearColor;

/**
 如果需要隐藏，需要重写这个方法加入[self.navigationController setNavigationBarHidden:YES animated:YES];
 */
-(void)setNavWithHidden;

- (void)rightNavBtnEvent;

- (void)setRightBtnWithTitle:(NSString *)aTitle;

- (void)setRightBtnWithTitle:(NSString *)aTitle andColor:(UIColor *)color;

- (void)setRightBtnWithImage:(UIImage *)aImage ;

- (void)showLoadingViewTitle:(NSString*)title;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)hideLoadingViewAfterDelay:(CGFloat)time;

- (void)showLoadingView:(UIView *)aView;
- (void)showLoadingView:(UIView *)aView top:(CGFloat)top;

-(void)showBlurBackgroundView;
- (void)setBlurImageViewWithImage:(UIImage *)image state:(float)state;
//- (void)setRightBtnWithTitle:(NSString *)aTitle andColor:(UIColor *)color;

- (void)addTapButton;
//- (void)hideBackButton;
//- (void)showBackButton;
@end
