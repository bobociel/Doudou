//
//  AlertView.h
//  lovewith
//
//  Created by imqiuhang on 15/4/1.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "MBProgressHUD.h"

@interface WTProgressHUD : NSObject

//显示系统自带的警告窗口 请用AlertViewWithBlockOrSEL.h
+ (void)showSystemAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;

//显示一个只有文字的普通HUD,隐藏时间default is 2.0s
+ (void)ShowTextHUD:(NSString *) title showInView:(UIView *) view;

//自定义消失时间
+ (void)ShowTextHUD:(NSString *) title showInView:(UIView *) view afterDelay:(int) delay;

//一个简单的loading 如果不想要字设置为nil即可
//sample  MBProgressHUD *hud =[Alert showLoadingHUBWithTitle:@"正在下载..."];
//..好了以后 [hud hide:YES];
+ (MBProgressHUD *)showLoadingHUDWithTitle:(NSString *)title showInView:(UIView *)view;

+ (MBProgressHUD *)showTopBarLodingHUDWithTitle:(NSString *)title showInView:(UIView *)view;
@end
