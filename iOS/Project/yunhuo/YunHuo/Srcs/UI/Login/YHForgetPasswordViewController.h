//
//  YHForgetPasswordViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHForgetPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *sendCaptchaBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *captchaField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)hideKB:(id)sender;
- (IBAction)showPassword:(id)sender;
- (IBAction)modifyPassword:(id)sender;
@end
