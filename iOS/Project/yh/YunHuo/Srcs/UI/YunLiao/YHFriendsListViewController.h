//
//  YHFriendsListViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/22.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHFriendCell : UITableViewCell

@end

@interface YHFriendsListViewController : UITableViewController

- (IBAction)onBack:(id)sender;

+ (YHFriendsListViewController*) showFriendsList;
@end
