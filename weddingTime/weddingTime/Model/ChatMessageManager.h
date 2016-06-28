//
//  ChatMessageManager.h
//  weddingTime
//
//  Created by 默默 on 15/9/27.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatConversationManager.h"
typedef enum {
    WTChatMessageGetListStateNone   = 0,
    WTChatMessageGetListStateClosed ,
    WTChatMessageGetListStateError ,
    WTChatMessageGetListStatePaused ,
    WTChatMessageGetListStateReconnecting,
    WTChatMessageGetListStateOpening  ,
    WTChatMessageGetListStatePullConversations ,
    WTChatMessageGetListStatePullConversationFailed ,
    WTChatMessageGetListStateUpdateConversations ,
    WTChatMessageGetListStateUpdateUsers ,
    WTChatMessageGetListStateOpen,
    WTChatMessageGetListStateGetListDone,
}WTChatMessageGetListState;

@class AVIMConversation;
@class AVIMKeyedConversation;
@class Message;
@class AVIMMessage;
static  NSString *const unreadNumUpdateNotification=@"unreadNumUpdateNotification";
static  NSString *const key_unread=@"key_unread";

static  NSString *const listUpdateObserver=@"listUpdateObserver";
static  NSString *const ourUpdateObserver=@"ourUpdateObserver";
@protocol ChatMessageManagerDelegate <NSObject>
@optional
//连接状态更新提示
- (void)getListStateChanged:(WTChatMessageGetListState)state;
//列表需要更新
- (void)listShouldUpdate:(AVIMKeyedConversation*)conversation;
//我和另一半消息到达或者更新
- (void)ourConversationMessageArrive;
@end

@interface ChatMessageManager : NSObject
{
     NSMutableDictionary *observerMapping;
}
//不包括我和另一半的会话的其他会话
@property (nonatomic,strong) NSMutableArray *keyedConversations;
//我和另一半的会话
@property (nonatomic,strong) AVIMKeyedConversation *keyedConversationOur;
@property (nonatomic,strong) AVIMConversation *conversationOur;
+ (ChatMessageManager *)instance;
+(void)clearUnreadMsgCount:(NSString*)conversationId;

//在进入聊天详情页面之前或者刚进入个人中心页面要主动调用此方法
-(void)makeOurConversation:(void(^)())successBlock failure:(void(^)())failure;
//是否第一次拉取所有聊天会话以及历史纪录
-(BOOL)isFirstGetMsg;
//某个会话是否包含本地纪录
-(BOOL)containLastMessageByConversationId:(NSString*)conversationId;
//某个会话的最后一条本地纪录，若不存在则返回Message类型的初始对象
-(Message*)getLastMessageByConversationId:(NSString*)conversationId;
//发送给我和另一半的会话,需要聊天通知
-(void)sendToOurConversationBeforeFinish:(void(^)(AVIMConversation *ourCov))finish;
//获取会话
-(AVIMConversation*)getConversationWithId:(NSString*)conversationId;
//是否我和另一半的会话
-(BOOL)ifOurConversation:(AVIMKeyedConversation*)conversation;

-(void)openClient;
//在appdelegate中开启这个即开始全面接管消息
-(void)beginManage;
-(void)updateConversations;

//设置等待打开的会话
-(void)setWaitOpenConversatinId:(NSString*)conversatinId;
//退出登录时一定调用这个,关闭聊天客户端
-(void)closeClientWithCallback:(void(^)(BOOL succeeded, NSError *error))callback;

//根据name添加观察者，name：1.listUpdateObserver(聊天列表页面) 2.ourUpdateObserver（我和另一半会话）；需实现对应委托
-(void)addObserver:(id<ChatMessageManagerDelegate>)observer forName:(NSString*)name;
//别忘了在iewcontroller的delleac中remove哦
-(void)removeObserver:(id<ChatMessageManagerDelegate>)observer forName:(NSString*)name;

//退出登录时不要调用
- (void)removeAllEventObserver;

@end
