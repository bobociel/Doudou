//
//  ViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/8.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHLoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

- (IBAction)onNext:(id)sender;
- (IBAction)hideKB:(id)sender;
- (IBAction)onBack:(id)sender;
@end

