//
//  ConversationStore.h
//  FreeChat
//
//  Created by Feng Junwen on 2/5/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AVOSCloudIM/AVOSCloudIM.h"
#import "Message.h"
#import "Constrains.h"
@protocol IMEventObserver <NSObject>

@optional
- (void)newMessageArrived:(Message*)message conversation:(AVIMConversation*)conversation;
- (void)messageDelivered:(Message*)message conversation:(AVIMConversation*)conversation;
- (void)newMessageSend:(Message *)message  conversation:(AVIMConversation*)conversation;
@end


@protocol ConversationOperationDelegate <NSObject>

@optional
//-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation;
//-(void)kickoffMembers:(NSArray*)client conversation:(AVIMConversation*)conversation;
//-(void)mute:(BOOL)on conversation:(AVIMConversation*)conversation;
//-(void)changeName:(NSString*)newName conversation:(AVIMConversation*)conversation;
//-(void)exitConversation:(AVIMConversation*)conversation;
//-(void)switch2NewConversation:(AVIMConversation*)conversation;

-(void)sendMsgUpdate:(AVIMMessage *)message conversation:(AVIMConversation *)conv;
@end

@interface ConversationStore : NSObject

@property (nonatomic, strong) AVIMClient *imClient;
@property (nonatomic) BOOL networkAvailable;
@property (nonatomic, strong) id<ConversationOperationDelegate> conversationDelegate;

+(instancetype)sharedInstance;
-(void)setPersonId:(NSString*)personId;
-(void)reviveKeyedConversationsFromLocal;
-(void)getAVIMConversationsWithBlock:(void(^)())block;

// 打开了某对话
-(BOOL)saveConversations;
- (void)deleteConversation:(AVIMKeyedConversation*)conversation;
- (void)addConversation:(AVIMConversation*)conversation;

// 获取最近对话列表
- (NSArray*)recentKeyedConversations;//做了缓存的KeyedConversation对象
- (NSArray*)recentConversations;

// 获取某个对话的更多消息
- (void)queryMoreMessages:(NSString*)conversationid from:(NSString*)msgId timestamp:(int64_t)ts limit:(int)limit callback:(ArrayResultBlock)callback;

// 新消息到达
- (void)newMessageSent:(AVIMMessage*)message conversation:(AVIMConversation*)conv;
-(void)getMessageFromServer:(AVIMMessage*)message conversation:(AVIMConversation*)conv;
- (void)newMessageArrived:(AVIMMessage*)message conversation:(AVIMConversation*)conv;
- (void)messageDelivered:(AVIMMessage*)message conversation:(AVIMConversation*)conv;

// 对话中新的事件发生
- (void)newConversationEvent:(IMMessageType)event conversation:(AVIMConversation*)conv from:(NSString*)clientId to:(NSArray*)clientIds;


-(Message*)turnToMessage:(AVIMMessage*)message conversation:(AVIMConversation*)conv;
- (void)addEventObserver:( id<IMEventObserver>)observer forConversation:(NSString*)conversationId;
- (void)removeEventObserver:(id<IMEventObserver>)observer forConversation:(NSString*)conversationId;
- (void)removeAllEventObserver;

// 获取对话中未读消息数量
-(void)clearUnreadMsgCount:(NSString*)conversationId;
- (int)conversationUnreadCount:(NSString*)conversationId;
- (int)conversationUnreadCountAll;//除去我和伴侣的会话的其他会话的所有未读
@end



