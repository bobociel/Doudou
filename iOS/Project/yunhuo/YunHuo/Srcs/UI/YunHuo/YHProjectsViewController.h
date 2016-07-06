//
//  YHProjectsViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"
#import "SKSTableViewCell.h"

@class YHProject;

@interface YHProjectCell : SKSTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selectedMark;
@property (weak, nonatomic) IBOutlet UIImageView *projectLogo;
@property (weak, nonatomic) IBOutlet UILabel *projectTitle;
@property (nonatomic) YHProject	*project;

@end

@interface YHProjectsViewController : UIViewController
@property (weak, nonatomic) IBOutlet SKSTableView	*tableView;
@property (nonatomic,weak) IBOutlet UIButton		*clockBtn;
@property (nonatomic,weak) IBOutlet UIButton		*combineBtn;
@property (nonatomic,weak) IBOutlet UIView			*combineBoard;
@property (nonatomic,weak) IBOutlet UIView			*actionBoard;

@property (nonatomic) BOOL							isInCombine;
@property (nonatomic) NSMutableArray				*projects;

- (IBAction)showProjectCreate:(id)sender;
- (IBAction)onCombine:(id)sender;
- (IBAction)onClock:(id)sender;
- (IBAction)onCancelCombine:(id)sender;
- (IBAction)onDoCombine:(id)sender;

@end
