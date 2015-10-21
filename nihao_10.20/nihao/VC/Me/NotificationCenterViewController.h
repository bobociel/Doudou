//
//  NotificationCenterViewController.h
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

//清除我的页面上通知的小红点
@protocol ClearNotificationRedPointDelegate <NSObject>

- (void) clearNotificationRedPoint;

@end

@interface NotificationCenterViewController : BaseViewController

@property (nonatomic,assign) NSUInteger unreadLikeNum;

@property (nonatomic,assign) NSUInteger unreadCommentNum;

@property (nonatomic,assign) NSUInteger unreadAnswerNum;

@property (nonatomic,weak) id<ClearNotificationRedPointDelegate> delegate;

@end
