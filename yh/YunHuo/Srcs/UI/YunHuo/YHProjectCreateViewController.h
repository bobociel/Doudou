//
//  YHProjectCreateViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHProjectCreateViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoBtn;
@property (weak, nonatomic) IBOutlet UIButton *dueDateBtn;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descView;
@property (weak, nonatomic) IBOutlet UIView	*timePickView;

- (IBAction)onBack:(id)sender;
- (IBAction)onCreate:(id)sender;
- (IBAction)onLogo:(id)sender;

- (IBAction)showTimePicker:(id)sender;
- (IBAction)hideTimePicker:(id)sender;
@end
