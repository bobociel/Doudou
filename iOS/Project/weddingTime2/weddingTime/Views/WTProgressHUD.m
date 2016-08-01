//
//  AlertView.m
//  lovewith
//
//  Created by imqiuhang on 15/4/1.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTProgressHUD.h"


@implementation WTProgressHUD

+ (void)showSystemAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:message delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil,nil];
    
    [alert show];
    
 
}

+ (void)ShowTextHUD:(NSString *)title showInView:(UIView *)view {
    [self ShowTextHUD:title showInView:view?view:KEY_WINDOW afterDelay:1.f];
}

+ (void)ShowTextHUD:(NSString *)title showInView:(UIView *)view afterDelay:(int)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view?view:KEY_WINDOW animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = title;
    hud.detailsLabelFont = [WeddingTimeAppInfoManager  fontWithSize:14];
    hud.margin = 25.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];

}

+ (MBProgressHUD *)showLoadingHUDWithTitle:(NSString *)title showInView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view?view:KEY_WINDOW animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabelText = title;
    hud.detailsLabelFont =[WeddingTimeAppInfoManager fontWithSize:14];
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    return hud;

}
+ (MBProgressHUD *)showTopBarLodingHUDWithTitle:(NSString *)title showInView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view?view:KEY_WINDOW animated:YES];
    hud.color=[UIColor clearColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabelText = title;
    hud.detailsLabelFont =[WeddingTimeAppInfoManager fontWithSize:14];
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}
@end
