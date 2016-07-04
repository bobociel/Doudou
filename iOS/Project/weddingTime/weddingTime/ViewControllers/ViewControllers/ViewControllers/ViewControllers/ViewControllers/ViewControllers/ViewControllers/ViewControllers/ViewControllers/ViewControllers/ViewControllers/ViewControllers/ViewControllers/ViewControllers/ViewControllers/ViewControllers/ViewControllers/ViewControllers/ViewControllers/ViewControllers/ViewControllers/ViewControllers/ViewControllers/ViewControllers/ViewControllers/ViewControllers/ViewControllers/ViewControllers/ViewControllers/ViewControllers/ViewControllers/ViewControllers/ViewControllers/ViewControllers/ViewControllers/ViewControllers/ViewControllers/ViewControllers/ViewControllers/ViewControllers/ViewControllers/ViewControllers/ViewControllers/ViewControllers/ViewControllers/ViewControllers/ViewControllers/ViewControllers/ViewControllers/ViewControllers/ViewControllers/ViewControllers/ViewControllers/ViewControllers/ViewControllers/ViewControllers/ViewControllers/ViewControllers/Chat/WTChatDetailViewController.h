//
//  ChatDetailViewController.h
//  weddingTreasure
//
//  Created by 默默 on 15/6/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "BaseViewController.h"
@class AVIMConversation;
@class AVIMKeyedConversation;
@class UserInfo;

@interface ObjCGPoint :NSObject
@property (nonatomic) float px;
@property (nonatomic) float py;
@end

@interface WTChatDetailViewController : BaseViewController
@property (strong, nonatomic) UIView      *avatarView;
//最好传入
@property (nonatomic,strong) AVIMConversation      *conversation;
@property (nonatomic,strong) AVIMKeyedConversation *keyConversation;
@property (nonatomic,strong) NSString              *conversationId;
@property(nonatomic,strong) NSDictionary           *sendToAskData;

+(void)pushToChatDetailWithConversationId:(NSString*)conversationId;

+(void)pushToChatDetailWithKeyConversation:(AVIMKeyedConversation*)keyConversation;

+(void)pushToChatDetailWithConversation:(AVIMConversation*)conversaiton;
@end
