//
//  TopUserHeaderView.h
//  nihao
//
//  Created by HelloWorld on 6/16/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopUser;

@interface TopUserHeaderView : UICollectionReusableView

//- (instancetype)initWithFrame:(CGRect)frame usersInfoArray:(NSArray *)users;
- (void)configureHeaderViewWithUsersInfo:(NSArray *)users;

@property (nonatomic, copy) void(^followUserForRowAtIndexPath)(NSInteger userIndex, BOOL isFollow);

@property (nonatomic,strong) UINavigationController *navigationController;

@end
