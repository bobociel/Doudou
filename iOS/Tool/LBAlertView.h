//
//  LBAlertView.h
//  Popping
//
//  Created by wangxiaobo on 16/6/8.
//  Copyright © 2016年 André Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBAlertView : UIView
@property (copy) void (^onButtonTouchUpInside)(LBAlertView  *alertView, NSInteger buttonIndex) ;
+ (instancetype)viewWithTitle:(NSString *)title centerImage:(UIImage *)image cancelButton:(NSString *)cancle otherButtons:(NSArray *)buttons;
- (void)show;
@end
