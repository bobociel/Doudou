//
//  YHFavViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHFavCell : UITableViewCell
@property (nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *selectMark;
@property (nonatomic) BOOL isSelectableMode;
@end

@interface YHFavViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *addToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *editToolbar;
@property (weak, nonatomic) IBOutlet UIView *searchBoard;

@property (nonatomic) BOOL isInEdit;
@property (nonatomic) BOOL isShowAddMenu;

- (IBAction)onFavAddImage;
- (IBAction)onEdit:(id)sender;
- (IBAction)onAdd:(id)sender;
- (IBAction)startSearch:(id)sender;
- (IBAction)finishSearch:(id)sender;
- (IBAction)onShare:(id)sender;
@end
