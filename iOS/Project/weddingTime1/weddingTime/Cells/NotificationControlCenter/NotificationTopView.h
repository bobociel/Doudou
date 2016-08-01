//
//  NotificationTopView.h
//  weddingTime
//
//  Created by 默默 on 15/9/22.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "RootView.h"
typedef NS_ENUM(NSInteger, WTNotificationTopViewType)
{
    WTNotificationTopViewTypeMessage=0,
    WTNotificationTopViewTypeOrder,
    WTNotificationTopViewTypeDemaindReserverSuccess,
};

@class AVIMConversation;
@class UserInfo;

@interface NotificationTopViewChatMeaasgeObject:NSObject
@property (strong, nonatomic)  AVIMConversation *conversation;
@property (strong, nonatomic)  UserInfo *senderInfo;
@end

@interface NotificationTopView : RootView

-(instancetype)initWithType:(WTNotificationTopViewType)type message:(AVIMMessage *)message object:(id)object;

@property (weak, nonatomic) IBOutlet UILabel *waitingChooseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
- (IBAction)touch:(id)sender;

@end
