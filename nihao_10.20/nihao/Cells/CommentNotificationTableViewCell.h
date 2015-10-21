//
//  CommentNotificationTableViewCell.h
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentNotification;

@protocol UserLogoTappedDelegate <NSObject>

- (void) userLogoTapped : (NSIndexPath *)indexPath;

@end

@interface CommentNotificationTableViewCell : UITableViewCell

- (void) configureCell : (CommentNotification *) notification indexPath : (NSIndexPath *) indexPath;

@property (nonatomic,weak) id<UserLogoTappedDelegate> delegate;

@end
