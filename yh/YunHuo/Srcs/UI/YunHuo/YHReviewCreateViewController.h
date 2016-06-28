//
//  YHReviewCreateViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/29.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHReviewCreateViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
- (IBAction)onCancel:(id)sender;
- (IBAction)onCreate:(id)sender;
- (IBAction)onTopic:(id)sender;
- (IBAction)onAt:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)onAddPhoto:(id)sender;



@end
