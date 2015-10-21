//
//  UserFollowListViewController.h
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
#import "UserFollowListCell.h"

//@protocol UserFollowListViewControllerDelegate <NSObject>
//
//- (void)followCountChanged:(BOOL)isChanged;
//
//@end

@protocol ClearNewFollowsRedPointDelegate <NSObject>

- (void) clearNewFollowsRedPoint;

@end

@interface UserFollowListViewController : BaseViewController

@property (nonatomic, assign) UserFollowListType userFollowListType;
@property (nonatomic, copy) NSString *userID;

//@property (nonatomic, assign) id <UserFollowListViewControllerDelegate> delegate;
@property (nonatomic,weak) id<ClearNewFollowsRedPointDelegate> delegate;

@end
