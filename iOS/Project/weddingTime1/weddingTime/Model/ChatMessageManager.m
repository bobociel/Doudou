//
//  ChatMessageManager.m
//  weddingTime
//
//  Created by 默默 on 15/9/27.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ChatMessageManager.h"
#import "UserInfoManager.h"
#import "AVOSCloudIM.h"
#import "ConversationStore.h"
#import "ChatListCell.h"
#import "WTLocalDataManager.h"
#import "WTChatListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTMainViewController.h"

#define APICHATONLINEGET                  @"https://leancloud.cn/1.1/rtm/online"
#define maxHistoryMessageCount 300
static NSString *const key_userdidhavegetcons=@"key_userdidhavegetcons";

@interface ChatMessageManager()<UserInfoManagerObserver,AVIMClientDelegate,ConversationOperationDelegate,MBProgressHUDDelegate>
{
    AVIMClient *loaclClient;
    
    NSString *personalId;
    NSString *partnarId;
    
    NSMutableDictionary *messageDic;
    
    BOOL isFirstGetMsg;
    
    WTChatMessageGetListState state;
    
    NSString*waitOpenConversationId;
    MBProgressHUD *cmLoadingHUD;
    
    void(^hudWasHiddenBlock)();
}
@end

@implementation ChatMessageManager
-(void)setWaitOpenConversatinId:(NSString *)conversatinId
{
    waitOpenConversationId=conversatinId;
    cmLoadingHUD= [WTProgressHUD showLoadingHUDWithTitle:@"打开中..." showInView:KEY_WINDOW];
    cmLoadingHUD.delegate=self;
    [cmLoadingHUD show:YES];
    
    [self openWaitOpenConversation];
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    if(hudWasHiddenBlock)
    {
        hudWasHiddenBlock();
        hudWasHiddenBlock=nil;
    }
}

-(void)openWaitOpenConversation
{
    //    objc_setAssociatedObject(cmLoadingHUD, @"realconversation", cmLoadingHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //
    //    objc_setAssociatedObject(cmLoadingHUD, @"error", error,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([waitOpenConversationId isNotEmptyCtg]&&loaclClient.status==AVIMClientStatusOpened) {
        [ChatConversationManager getConversationWithConversationId:waitOpenConversationId withBlock:^(AVIMConversation *realconversation, NSError *error)
         {
             hudWasHiddenBlock=^{
                 waitOpenConversationId=nil;
                 if (error||!realconversation) {
                     return;
                 }
                 NSMutableArray *members=[NSMutableArray new];
                 for (NSString *member in realconversation.members) {
                     if (![member isEqualToString:[UserInfoManager instance].userId_self]) {
                         NSDictionary *channel=@{realconversation.conversationId:member};
                         [members addObject:channel];
                     }
                 }
                 [ChatConversationManager getUserDataWithMember:members finish:^{
                     [WTChatDetailViewController pushToChatDetailWithConversation:realconversation];
                 }];
             };
             [cmLoadingHUD hide:YES];
         }];
    }
}

-(void)setIsFirstGetMsg:(BOOL)_isFirstGetMsg
{
    if (![personalId isNotEmptyCtg]) {
        return;
    }
    isFirstGetMsg=_isFirstGetMsg;
    NSMutableDictionary *userDidHaveGetDic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:key_userdidhavegetcons]];
    if (!userDidHaveGetDic) {
        userDidHaveGetDic=[NSMutableDictionary dictionary];
    }
    [userDidHaveGetDic setObject:[NSNumber numberWithBool:isFirstGetMsg] forKey:personalId];
    [[NSUserDefaults standardUserDefaults]setObject:userDidHaveGetDic forKey:key_userdidhavegetcons];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isFirstGetMsg
{
    if (![personalId isNotEmptyCtg]) {
        return YES;
    }
    return isFirstGetMsg;
}

+ (ChatMessageManager *)instance
{
    static ChatMessageManager *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[ChatMessageManager alloc] init];
    });
    return _instance;
}

-(void)dealloc
{
    [[UserInfoManager instance]removeInfoUpdateObserver: self forName:infoUpdateObserver];
}

-(void)beginManage
{
    [ConversationStore sharedInstance].conversationDelegate=self;
    if (!loaclClient) {
        loaclClient = [[AVIMClient alloc] init];
        loaclClient.delegate=self;
    }
    if (!messageDic) {
        messageDic=[[NSMutableDictionary alloc]init];
    }
    if (!observerMapping) {
        observerMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    if (!self.keyedConversations) {
        self.keyedConversations=[[NSMutableArray alloc]init];
    }
    
    [[UserInfoManager instance]addInfoUpdateObserver:self forName:infoUpdateObserver];
    [self changeState:WTChatMessageGetListStateClosed];
    personalId=[UserInfoManager instance].userId_self;
    partnarId=[UserInfoManager instance].userId_partner;
    
    if (![personalId isNotEmptyCtg]) {
        return;
    }
    
    [self openClient];
    NSDictionary *userDidHaveGetDic=[[NSUserDefaults standardUserDefaults]objectForKey:key_userdidhavegetcons];
    if (userDidHaveGetDic.allKeys.count==0) {
        [self setIsFirstGetMsg:YES];
    }
    else
    {
        if (![userDidHaveGetDic.allKeys containsObject:personalId]) {
            [self setIsFirstGetMsg:YES];
        }
        else
        {
            isFirstGetMsg=[[userDidHaveGetDic objectForKey:personalId] boolValue];
        }
    }
    [[ConversationStore sharedInstance] setPersonId:personalId];
    [[ConversationStore sharedInstance]reviveKeyedConversationsFromLocal];//获取一下KeyedConversations缓存
    
    [self filterKeyedConversations];
    [ChatMessageManager postUnreadNumUpdate];
    [self getKeyedConversationMessage:^{}];
}

-(void)changeState:(WTChatMessageGetListState)_state
{
    WTChatMessageGetListState last=state;
    state=_state;
    if (last!=state) {
        NSMutableArray *observerChain = [observerMapping objectForKey:listUpdateObserver];
        if (observerChain) {
            for (int i = 0; i < [observerChain count]; i++) {
                NSValue *value=[observerChain objectAtIndex:i];
                __weak id<ChatMessageManagerDelegate> observer = [value nonretainedObjectValue];
                if ([observer respondsToSelector:@selector(getListStateChanged:)]) {
                    [observer getListStateChanged:_state];
                }
            }
        }
    }
}

-(void)openClient
{
    if (![personalId isNotEmptyCtg]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (loaclClient.status==AVIMClientStatusClosed||loaclClient.status==AVIMClientStatusNone) {
        [self changeState:WTChatMessageGetListStateOpening];
        [loaclClient openWithClientId:personalId
                             callback:^(BOOL succeeded, NSError *error) {
                                 [weakSelf doFinishOpenChat:error];
                             }];
    }
}

- (void)doFinishOpenChat:(NSError *)error {
    if (error) {
        //todo告诉界面呈现重连按钮
        if(loaclClient.status==AVIMClientStatusClosed||loaclClient.status==AVIMClientStatusNone)
            [self changeState:WTChatMessageGetListStateError];
    }
    else {
        [ConversationStore sharedInstance].imClient = loaclClient;
        [self openWaitOpenConversation];
        [self changeState:WTChatMessageGetListStateOpen];
    }
}

-(void)filterKeyedConversations//过滤我和另一半
{
    NSMutableArray *ourLast=[NSMutableArray array];
    self.keyedConversations=[NSMutableArray arrayWithArray:[[ConversationStore sharedInstance] recentKeyedConversations]];
    for (AVIMKeyedConversation *con in self.keyedConversations) {
        if ([self ifOurConversation:con]) {
            self.keyedConversationOur = con;
            [self postOurUpdateObserver];
        }
        else if ([self ifLastBindOurConversation:con])
        {
            [ourLast addObject:con];
        }
    }
    if(ourLast)
    {
        [self.keyedConversations removeObjectsInArray:ourLast];
        for (AVIMKeyedConversation *con in ourLast) {
            [[ConversationStore sharedInstance]deleteConversation:con];
        }
        [[ConversationStore sharedInstance] saveConversations];
    }
    if(self.keyedConversationOur)
    {
        [self.keyedConversations removeObject:self.keyedConversationOur];
    }
}

//通知我和另一半会话的观察者
-(void)postOurUpdateObserver
{
    NSMutableArray *observerChain = [observerMapping objectForKey:ourUpdateObserver];
    if (observerChain) {
        for (int i = 0; i < [observerChain count]; i++) {
            NSValue *value=[observerChain objectAtIndex:i];
            __weak id<ChatMessageManagerDelegate> observer = [value nonretainedObjectValue];
            if ([observer respondsToSelector:@selector(ourConversationMessageArrive)]) {
                [observer ourConversationMessageArrive];
            }
        }
    }
}

-(void)closeClientWithCallback:(void(^)(BOOL succeeded, NSError *error))callback
{
    void(^finish)(BOOL succeeded, NSError *error)=^(BOOL succeeded, NSError *error){
        callback(succeeded,error);
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation removeObject:[UserInfoManager instance].userId_self forKey:@"channels"];
        [currentInstallation saveInBackground];
        loaclClient.delegate=nil;
        personalId = nil;
        [ConversationStore sharedInstance].imClient = nil;
        waitOpenConversationId=nil;
        [[ConversationStore sharedInstance] setPersonId:@""];
        [self changeState:WTChatMessageGetListStateClosed];
        [[NSNotificationCenter defaultCenter]postNotificationName:unreadNumUpdateNotification object:nil userInfo:nil];
    };
    if (loaclClient) {
        //todo退出方式
        [loaclClient closeWithCallback:^(BOOL succeeded, NSError *error) {
            finish(succeeded,error);
        }];
    }
    else
    {
        finish(YES,nil);
    }
}

#pragma mark UserInfoManagerObserver
-(void)userInfoUpdate
{
    //登陆
    if (![personalId isNotEmptyCtg]){
        if ([[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
            personalId=[UserInfoManager instance].userId_self;
            partnarId=[UserInfoManager instance].userId_partner;
            [self openClient];
            NSDictionary *userDidHaveGetDic=[[NSUserDefaults standardUserDefaults]objectForKey:key_userdidhavegetcons];
            if (userDidHaveGetDic.allKeys.count==0) {
                [self setIsFirstGetMsg:YES];
            }
            else
            {
                if (![userDidHaveGetDic.allKeys containsObject:personalId]) {
                    [self setIsFirstGetMsg:YES];
                }
                else
                {
                    isFirstGetMsg=[[userDidHaveGetDic objectForKey:personalId] boolValue];
                }
            }
            [[ConversationStore sharedInstance] setPersonId:personalId];
            [[ConversationStore sharedInstance]reviveKeyedConversationsFromLocal];//获取一下KeyedConversations缓存
            
            [self filterKeyedConversations];
            [ChatMessageManager postUnreadNumUpdate];
            [self getKeyedConversationMessage:^{}];
        }
    }
    else//此处处理解除绑定和绑定
    {
        if (![partnarId isEqualToString:[UserInfoManager instance].userId_partner]) {
            if([partnarId isNotEmptyCtg]&&self.keyedConversationOur)
            {
                [[ConversationStore sharedInstance]deleteConversation:self.keyedConversationOur];
                [[ConversationStore sharedInstance] saveConversations];
            }
            
            partnarId=[UserInfoManager instance].userId_partner;
            self.keyedConversationOur=nil;
            self.conversationOur=nil;
            [self postOurUpdateObserver];
            [ChatMessageManager postUnreadNumUpdate];
        }
    }
}

#pragma mark AVIMClientDelegate

/*!
 当前聊天状态被暂停，常见于网络断开时触发，error 包含暂停的错误信息。
 注意：该回调会覆盖 imClientPaused: 方法。
 */
- (void)imClientPaused:(AVIMClient *)imClient error:(NSError *)error
{
    [self changeState:WTChatMessageGetListStatePaused];
}

/*!
 当前聊天状态开始恢复，常见于网络断开后开始重新连接。
 */
- (void)imClientResuming:(AVIMClient *)imClient
{
    [self changeState:WTChatMessageGetListStateReconnecting];
}

/*!
 当前聊天状态已经恢复，常见于网络断开后重新连接上。
 */
- (void)imClientResumed:(AVIMClient *)imClient
{
    [ConversationStore sharedInstance].imClient = imClient;
    [self openWaitOpenConversation];
    [self changeState:WTChatMessageGetListStateOpen];
}

- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    [self deelNewMsg:conversation message:message];
}

- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    [self deelNewTypeMsg:conversation TypedMessage:message];
}
/*!
 消息已投递给对方。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message{
}
/*!
 对话中有新成员加入的通知。
 @param conversation － 所属对话
 @param clientIds - 加入的新成员列表
 @param clientId - 邀请者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId{
}

/*!
 对话中有成员离开的通知。
 @param conversation － 所属对话
 @param clientIds - 离开的成员列表
 @param clientId - 操作者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation membersRemoved:(NSArray *)clientIds byClientId:(NSString *)clientId{
}
/*!
 被邀请加入对话的通知。
 @param conversation － 所属对话
 @param clientId - 邀请者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation invitedByClientId:(NSString *)clientId{
}
/*!
 从对话中被移除的通知。
 @param conversation － 所属对话
 @param clientId - 操作者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId{
}

-(void)deelNewTypeMsg:(AVIMConversation *)conversation TypedMessage:(AVIMTypedMessage *)message
{
    if ([self notSaveHistoary:message]) {
        return;
    }
    [self deelNewMsg:conversation message:message];
}

+(void)postUnreadNumUpdate
{
    int num=[[ConversationStore sharedInstance] conversationUnreadCountAll];
    NSString *nums;
    if (num!=0) {
        if (num>99) {
            nums=@"99+";
        }
        else
        {
            nums=[NSString stringWithFormat:@"%d",num];
        }
    }
    if ([nums isNotEmptyCtg]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:unreadNumUpdateNotification object:nil userInfo:@{key_unread:nums}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:unreadNumUpdateNotification object:nil userInfo:nil];
    }
}

-(void)postListUpdate:(AVIMKeyedConversation*)keydConversation
{
    NSMutableArray *observerChain = [observerMapping objectForKey:listUpdateObserver];
    if (observerChain) {
        for (int i = 0; i < [observerChain count]; i++) {
            NSValue *value=[observerChain objectAtIndex:i];
            __weak id<ChatMessageManagerDelegate> observer = [value nonretainedObjectValue];
            if ([observer respondsToSelector:@selector(listShouldUpdate:)]) {
                [observer listShouldUpdate:keydConversation];
            }
        }
    }
}

-(void)deelNewMsg:(AVIMConversation *)conversation message:(AVIMMessage *)message {
    if ([self ifLastBindOurConversation:[conversation keyedConversation]]) {
        return;
    }

	__block AVIMMessage *sendMessage = message;
    void(^block)()=^(AVIMConversation *cov){
        [messageDic setObject:@[[[ConversationStore sharedInstance] turnToMessage:message conversation:cov]] forKey:cov.conversationId];
        
        [[ConversationStore sharedInstance] newMessageArrived:message conversation:cov];
        [self filterKeyedConversations];
        
        UserInfo *userSender;
        NSString *avatar=@"";
        NSString *name=@"";
        if (self.keyedConversationOur&&[self.keyedConversationOur.conversationId isEqualToString:conversation.conversationId]) {
            [self postOurUpdateObserver];
			userSender= [[SQLiteAssister sharedInstance] pullUserInfo:[UserInfoManager instance].userId_partner];
            avatar=[UserInfoManager instance].avatar_partner;
            name=[UserInfoManager instance].username_partner;
        }
        else
        {
            [self postListUpdate:[cov keyedConversation]];
            userSender= [ChatListCell getSupplierWithMembers:conversation.members];
        }
        if (userSender) {
            avatar=userSender.avatar;
            name=userSender.name;
        }
        else
        {
            userSender=[UserInfo new];//如果竟然没有找到一个商家，只好为空了
        }
        BOOL show=0;
        if(![KeyWindowCurrentViewController isKindOfClass:[WTChatListViewController class]]&&![KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]])
        {
            if ([KeyWindowCurrentViewController isKindOfClass:[WTMainViewController class]]) {
                if (((WTMainViewController*)KeyWindowCurrentViewController).selectedIndex!=3) {
                    show=1;
                }
            }
            else
            {
                show=1;
            }
        }
        if (show&&![[message valueForKey:@"offline"] boolValue]) {
            NotificationTopViewChatMeaasgeObject*objectN=[[NotificationTopViewChatMeaasgeObject alloc]init];
            objectN.conversation=conversation;
            objectN.senderInfo=userSender;
			[[NotificationControlCenter instance]pushTopViewOnKeyWindow:avatar title:name subTitle:[ChatListCell getContentWithMessage:message] type:WTNotificationTopViewTypeMessage message:sendMessage object:objectN];
        }
        [[ConversationStore sharedInstance] saveConversations];
        [ChatMessageManager postUnreadNumUpdate];
    };
    
    if (!conversation.members||conversation.members.count<=0||!conversation.attributes) {
        [ChatConversationManager getConversationWithConversationId:conversation.conversationId withBlock:^(AVIMConversation *realconversation, NSError *error) {
            if(!error)
            {
                NSMutableArray *members=[NSMutableArray new];
                for (NSString *member in realconversation.members) {
                    if (![member isEqualToString:personalId]) {
                        NSDictionary *channel=@{realconversation.conversationId:member};
                        [members addObject:channel];
                    }
                }
                [ChatConversationManager getUserDataWithMember:members finish:^{
                    block(realconversation);
                }];
            }
            else
            {
                [[ConversationStore sharedInstance] newMessageArrived:message conversation:conversation];//就算获取失败会话和消息也要存起来
            }
        }];
    }
    else
        block(conversation);
}

- (void)updateConversations {
    NSMutableArray *listUpdateObserverChain = [observerMapping objectForKey:listUpdateObserver];
    NSMutableArray *ourUpdateObserverChain = [observerMapping objectForKey:ourUpdateObserver];
    if ((listUpdateObserverChain&&listUpdateObserverChain.count>0)||(ourUpdateObserverChain&&ourUpdateObserverChain.count>0)) {//满足有listDelegate，避免没必要的请求
        if ([self isFirstGetMsg])
        {
            if(WTChatMessageGetListStateOpen==state||WTChatMessageGetListStatePullConversationFailed==state)
            {
                [self changeState:WTChatMessageGetListStatePullConversations];
                [self getConversationsFromServer:^{//拉取历史会话
                    [self dealWithConversations:^{//拉取历史纪录
                        [self getKeyedConversationMessage:^{
                            [self changeState:WTChatMessageGetListStateUpdateUsers];
                            [self getConversationUserInfo:^{//更新用户信息
                                if ([[ConversationStore sharedInstance] saveConversations]) {
                                    [self setIsFirstGetMsg:NO];
                                }
                                [self filterKeyedConversations];
                                [self changeState:WTChatMessageGetListStateGetListDone];
                                
                            }];
                        }];
                    }];
                } failure:^{
                    [self changeState:WTChatMessageGetListStatePullConversationFailed];
                }];
                //第一次进来，更新
            }
        }
        else
        {
            if(WTChatMessageGetListStateOpen==state||WTChatMessageGetListStateGetListDone==state)
            {
                [self changeState:WTChatMessageGetListStateUpdateConversations];
                [[ConversationStore sharedInstance]getAVIMConversationsWithBlock:^{//更新AVIMConversations
                    //if网络情况不佳todo
                    //else
                    [self changeState:WTChatMessageGetListStateUpdateUsers];
                    [self getConversationUserInfo:^{//处理KeyedConversations缓存，显示
                        [self changeState:WTChatMessageGetListStateGetListDone];
                    }];//拉会话所需的详细信息并且刷新列表
                }];
            }
        }
    }
}

-(void)getConversationsFromServer:(void(^)())success failure:(void(^)())failure
{
    [ChatConversationManager getConversationWithUserClientId:personalId  withBlock:^(NSArray *array, NSError *error) {//获取最新的聊天列表
        if (error) {
            //todo提示获取失败，重新获取按钮
            failure();
        }
        else
        {
            if (array) {
                for(int i=0;i<(int)array.count;i++)
                {
                    AVIMConversation *conversation=array[i];
                    if (![self ifLastBindOurConversation:[conversation keyedConversation]]) {
                        [[ConversationStore sharedInstance] addConversation:conversation];
                    }
                }//加入列表中
            }
            success();
        }
    }];
}

-(void)dealWithConversations:(void(^)())finishBlock
{
    NSArray *conversations=[[ConversationStore sharedInstance] recentConversations];
    __block int finishNum=0;
    if (conversations.count==0) {
        finishBlock();
    }
    else
    {
        for (AVIMConversation *conversation in conversations) {
            [conversation queryMessagesFromServerWithLimit:maxHistoryMessageCount callback:^(NSArray *objects, NSError *error) {//从服务器拉取历史纪录
                finishNum++;
                if (error) {
                    //不用处理error失败了就失败了无所谓的
                }
                else
                {
                    if (objects&&objects.count>0) {
                        for (AVIMMessage *message in objects) {
                            if ([message isKindOfClass:[AVIMTypedMessage class]]) {
                                AVIMTypedMessage *tmessage=(AVIMTypedMessage*)message;
                                if ([self notSaveHistoary:tmessage]) {
                                    continue;
                                }
                            }
                            [[ConversationStore sharedInstance]getMessageFromServer:message conversation:conversation];
                        }
                    }
                }
                
                if (finishNum==conversations.count) {
                    finishBlock();
                }
            }];
        }
    }
}

-(void)getConversationUserInfo:(void(^)())finishBlock//获取、更新用户信息
{
    NSArray *KeyedConversations=[[ConversationStore sharedInstance] recentKeyedConversations];
    NSMutableArray *msgList=[[NSMutableArray alloc]init];
    for (AVIMKeyedConversation *KeyedConversation in KeyedConversations) {
        for (NSString *member in KeyedConversation.members) {
            if (![member isEqualToString:[UserInfoManager instance].userId_self]) {
                NSDictionary *channel=@{KeyedConversation.conversationId:member};
                [msgList addObject:channel];
            }
        }
    }
    [ChatConversationManager getUserDataWithMember:msgList finish:^{//当取完缓存后获取用户数据并刷新
        finishBlock();
    }];
}

-(void)getKeyedConversationMessage:(void(^)())finishBlock//获取本地缓存历史记录
{
    NSArray *KeyedConversations=[[ConversationStore sharedInstance] recentKeyedConversations];
    if (KeyedConversations.count==0) {
        finishBlock();
    }
    else
    {
        __block int finishNum=0;
        for (AVIMKeyedConversation *KeyedConversation in KeyedConversations) {
            [[ConversationStore sharedInstance] queryMoreMessages:KeyedConversation.conversationId from:nil timestamp:[[NSDate date] timeIntervalSince1970]*1000 limit:1 callback:^(NSArray *objects, NSError *error) {//从缓存获取历史纪录
                finishNum++;
                if (error) {
                    //不用处理error失败了就失败了无所谓的
                }
                else
                {
                    if (objects&&objects.count>0) {
                        [messageDic setValue:objects forKey:KeyedConversation.conversationId];
                    }
                }
                
                if (finishNum>=KeyedConversations.count) {
                    finishBlock();
                }
            }];
        }
    }
}

-(BOOL)containLastMessageByConversationId:(NSString*)conversationId
{
    NSArray *dataArr=messageDic[conversationId];
    if (!dataArr||dataArr.count==0)
        return NO;
    return YES;
}

-(Message*)getLastMessageByConversationId:(NSString*)conversationId
{
    NSArray *dataArr=messageDic[conversationId];
    Message *dataDic;
    if (!dataArr||dataArr.count==0) {
        dataDic= nil;
    }
    else
        dataDic =dataArr[0];
    return dataDic;
}

-(void)addObserver:(id<ChatMessageManagerDelegate>)observer forName:(NSString*)name
{
    NSValue *value = [NSValue valueWithNonretainedObject:observer];
    
    NSMutableArray *observerChain = [observerMapping objectForKey:name];
    if (observerChain == nil) {
        observerChain = [[NSMutableArray alloc] initWithObjects:value, nil];
    } else {
        if(![observerChain containsObject:value])
            [observerChain addObject:value];
    }
    [observerMapping setObject:observerChain forKey:name];
    if ([name isEqualToString:listUpdateObserver]) {
        [observer getListStateChanged:state];
    }
    else
    {
    }
}

- (void)removeObserver:(id<ChatMessageManagerDelegate>)observer forName:(NSString*)name {
    NSValue *value = [NSValue valueWithNonretainedObject:observer];
    NSMutableArray *observerChain = [observerMapping objectForKey:name];
    if (observerChain != nil) {
        if ([observerChain containsObject:value]) {
            [observerChain removeObject:value];
            [observerMapping setObject:observerChain forKey:name];
        }
    }
}

- (void)removeAllEventObserver {
    [observerMapping removeAllObjects];
}

-(void)makeOurConversation:(void(^)())successBlock failure:(void(^)())failure
{
    if(self.keyedConversationOur)
    {
        successBlock();
        return;
    }
    if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
        failure();
        return;
    }
    NSArray *ids=@[[UserInfoManager instance].userId_partner,[UserInfoManager instance].userId_self];
    [ChatConversationManager getConversationWithClientIds:ids type:kConversationType_OneOne withBlock:^(AVIMConversation *result, NSError *error, BOOL success) {
        if (error) {
            //todo提示获取失败，重新获取按钮
            failure();
        }
        else
        {
            if (result) {
                [[ConversationStore sharedInstance] addConversation:result];
            }
            self.keyedConversationOur=[result keyedConversation];
            self.conversationOur=result;
            [result queryMessagesFromServerWithLimit:maxHistoryMessageCount callback:^(NSArray *objects, NSError *error) {//从服务器拉取历史纪录
                if (error) {
                    //不用处理error失败了就失败了无所谓的
                }
                else
                {
                    if (objects&&objects.count>0) {
                        for (AVIMMessage *message in objects) {
                            [[ConversationStore sharedInstance]getMessageFromServer:message conversation:result];
                        }
                    }
                }
                successBlock();
            }];
        }
    }];
}

-(void)makeSupplierConversationByIds:(NSArray*)ids success:(void(^)())successBlock failure:(void(^)())failure
{
    [ChatConversationManager getConversationWithClientIds:ids type:kConversationType_Group withBlock:^(AVIMConversation *result, NSError *error, BOOL success) {
        if (error) {
            //todo提示获取失败，重新获取按钮
            failure();
        }
        else
        {
            if (result) {
                [[ConversationStore sharedInstance] addConversation:result];
            }
            
            [result queryMessagesFromServerWithLimit:maxHistoryMessageCount callback:^(NSArray *objects, NSError *error) {//从服务器拉取历史纪录
                if (error) {
                    //不用处理error失败了就失败了无所谓的
                }
                else
                {
                    if (objects&&objects.count>0) {
                        for (AVIMMessage *message in objects) {
                            [[ConversationStore sharedInstance]getMessageFromServer:message conversation:result];
                        }
                    }
                }
                successBlock();
            }];
        }
    }];
}

-(BOOL)ifOurConversation:(AVIMKeyedConversation*)conversation
{
    if (conversation.members.count==2&&[conversation.attributes[@"type"] intValue]==kConversationType_OneOne&&[conversation.members containsObject:[UserInfoManager instance].userId_self]&&[conversation.members containsObject:[UserInfoManager instance].userId_partner]) {
        return YES;
    }
    return NO;
}

-(BOOL)ifLastBindOurConversation:(AVIMKeyedConversation*)conversation
{
    if (conversation.members.count==2&&[conversation.attributes[@"type"] intValue]==kConversationType_OneOne&&[conversation.members containsObject:[UserInfoManager instance].userId_self]&&![conversation.members containsObject:[UserInfoManager instance].userId_partner]) {
        return YES;
    }
    return NO;
}

-(AVIMConversation*)conversationOur
{
    if (!_conversationOur) {
        if (self.keyedConversationOur) {
            _conversationOur=[self getConversationWithId:self.keyedConversationOur.conversationId];
        }
    }
    return _conversationOur;
}

-(void)sendToOurConversationBeforeFinish:(void(^)(AVIMConversation *ourCov))finish
{
    [self makeOurConversation:^{
        if (self.keyedConversationOur) {
            __block  AVIMConversation*conversation=self.conversationOur;
            if(conversation)
            {
                finish(conversation);
            }
            else
            {
                [ChatConversationManager getConversationWithConversationId:self.keyedConversationOur.conversationId withBlock:^(AVIMConversation *result, NSError *error) {
                    if (error) {
                        finish(nil);
                    }
                    else
                    {
                        conversation=result;
                        [[ConversationStore sharedInstance] addConversation:conversation];
                        finish(conversation);
                    }
                }];
            }
        }
    } failure:^{
        finish(nil);
    }];
}

-(AVIMConversation*)getConversationWithId:(NSString*)conversationId
{
    NSArray *recentConversations=[[ConversationStore sharedInstance] recentConversations];
    for (AVIMConversation *conver in recentConversations) {
        if ([conversationId isEqualToString:conver.conversationId]) {
            return conver;
        }
    }
    return nil;
}

+(void)clearUnreadMsgCount:(NSString*)conversationId
{
    [[ConversationStore sharedInstance]clearUnreadMsgCount:conversationId];
    [ChatMessageManager postUnreadNumUpdate];
    [[NSNotificationCenter defaultCenter]postNotificationName:WTNotficationCellCheckUnreadNum object:nil];
}

-(BOOL)notSaveHistoary:(AVIMTypedMessage*)message
{
    if (message.attributes) {
        
        if ([message.attributes[ConversationMinAllowVersonKey] floatValue]>ConversationVerson) {
            //发送的类型要求的最低版本超过了当前的聊天版本
            return YES;
        }
        
        // todo游戏
        if ([message.attributes[ConversationTypeKey]
             isEqualToString:ConversationTypeKiss]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:KissDidGetPatarnerKissInfoNotify
             object:message.attributes[@"data"]];
            return YES;
        }
        
        if ([message.attributes[ConversationTypeKey]
             isEqualToString:ConversationTypeDraw]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:DrawDidGetPatarnerDrawInfoInfoNotify
             object:message.attributes[@"data"]];
            return YES;
        }
        
        if ([message.attributes[ConversationTypeKey]
             isEqualToString:ConversationTypeShareLocation]) {
            return YES;
        }
        
        if ([message.attributes[ConversationIsForGameKey] boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)sendMsgUpdate:(AVIMMessage *)message conversation:(AVIMConversation *)conv
{
    [self filterKeyedConversations];
    [[ConversationStore sharedInstance] saveConversations];
    [messageDic setObject:@[[[ConversationStore sharedInstance] turnToMessage:message conversation:conv]] forKey:conv.conversationId];
    if (![self ifOurConversation:[conv keyedConversation]]) {
        [self postListUpdate:[conv keyedConversation]];
    }
    else
    {
        [self postOurUpdateObserver];
    }
}

+(void)checkOnlineForId:(NSString*)userId block:(void(^)(BOOL online))block
{
    [PostDataService postChatOnlineStatus:@[userId] WithBlock:^(NSDictionary *result, NSError *error) {
        if(!error)
        {
            NSArray *onlinArr=result[@"results"];
            if (onlinArr&&onlinArr.count>0) {
                if ([onlinArr containsObject:userId]) {
                    block(YES);
                }
                else
                {
                    block(NO);
                }
            }
            else
            {
                block(NO);
            }
        }
    }];
}
@end
