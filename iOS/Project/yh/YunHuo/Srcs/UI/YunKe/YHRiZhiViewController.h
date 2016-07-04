//
//  YHRiZhiViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHRiZhiCell : UITableViewCell

@end

@interface YHRiZhiViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *rzNewView;
@property (weak, nonatomic) IBOutlet UIView *rzAddInputBoard;
@property (weak, nonatomic) IBOutlet UIView *rzAddInputKBExtView;
@property (weak, nonatomic) IBOutlet UITextView *rzInputView;
@property (nonatomic) BOOL isAdddNew;

- (IBAction) onAdd;
- (IBAction)onAt:(id)sender;
- (IBAction)onEmo:(id)sender;
- (IBAction)onImage:(id)sender;
@end
