//
//  YHSignUpViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/8.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *captchaField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

- (IBAction)onNext:(id)sender;
- (IBAction)hideKB:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onSkip:(id)sender;
@end
