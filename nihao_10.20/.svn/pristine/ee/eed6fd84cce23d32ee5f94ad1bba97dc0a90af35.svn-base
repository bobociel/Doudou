//
//  DynamicCell.h
//  nihao
//
//  Created by 刘志 on 15/6/15.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicCollectionView.h"
#import "MMGridView.h"
#import "CopyLabel.h"
@class UserPost;

#define DYNAMIC_CELL_WIDTH (SCREEN_WIDTH - ((CURRENT_IOS_VERSION >= 7.0 && CURRENT_IOS_VERSION < 8.0) ? 90 : 104) - 3) / 3

@interface DynamicCell : UITableViewCell

@property (nonatomic,strong) UINavigationController *navigationController;

//cell的高度
@property (nonatomic, assign) CGFloat itemWidth;

@property (weak, nonatomic) IBOutlet MMGridView *gridView;
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *publishTimeWidthConstraint;
@property (weak, nonatomic) IBOutlet CopyLabel *content;
- (IBAction)addFocus:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *focusState;
- (IBAction)addGood:(id)sender;
- (IBAction)addComment:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *goodNum;
@property (weak, nonatomic) IBOutlet UILabel *commentNum;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *postLocation;
@property (weak, nonatomic) IBOutlet UILabel *viewNumLabel;
@property (weak, nonatomic) IBOutlet UIView *viewNumView;

- (void)configureCellForMyPosts:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)configureCellForMyFollowPosts:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)configureCellForDiscover:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void) configureCellForPostDetail : (UserPost *) post forRowAtIndexPath:(NSIndexPath *)indexPath;

// 点击删除按钮Block
@property (nonatomic,copy) void(^deletePost)(UserPost *post, NSIndexPath *indexPath);

//关注成功
@property (nonatomic, copy) void(^addFoucs)(UserPost *post);

//取消关注
@property (nonatomic, copy) void(^cancelFocus)(UserPost *post);

//点击头像，查看个人信息
@property (nonatomic, copy) void(^viewUserInfo)(UserPost *post);

@property (nonatomic, copy) void(^viewDynamicInfo)(UserPost *post);

@end
