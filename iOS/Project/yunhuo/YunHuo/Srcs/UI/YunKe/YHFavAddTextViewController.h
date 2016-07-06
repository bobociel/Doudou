//
//  YHFavAddTextViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/16.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHFavAddTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;
@end
