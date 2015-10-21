//
//  LikeNotificationTableViewCell.h
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LikeNotification;

@protocol UserLogoTappedDelegate <NSObject>

- (void) userLogoTapped : (NSIndexPath *)indexPath;

@end

@interface LikeNotificationTableViewCell : UITableViewCell

- (void) configureLikeNotification : (LikeNotification *) notification indexPath : (NSIndexPath *) indexPath;

@property (nonatomic,weak) id<UserLogoTappedDelegate> delegate;

@end
