//
//  ChatMessageManager.m
//  weddingTime
//
//  Created by 默默 on 15/9/27.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ChatMessageManager.h"
#import "ChatListCell.h"
#import "WTChatListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTMainViewController.h"
#import "ConversationStore.h"
#import "UserInfoManager.h"

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

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate) name:UserInfoUpdate object:nil];
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)beginManage
{
    [ConversationStore sharedInstance].conversationDelegate=self;

    if (!messageDic) {
        messageDic=[[NSMutableDictionary alloc]init];
    }
    if (!observerMapping) {
        observerMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    if (!self.keyedConversations) {
        self.keyedConversations=[[NSMutableArray alloc]init];
    }

    [self changeState:WTChatMessageGetListStateClosed];
    personalId =[UserInfoManager instance].userId_self;
    partnarId =[UserInfoManager instance].userId_partner;
    
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
            isFirstGetMsg = [[userDidHaveGetDic objectForKey:personalId] boolValue];
        }
    }
    [[ConversationStore sharedInstance] setPersonId:personalId];
    [[ConversationStore sharedInstance] reviveKeyedConversationsFromLocal];//获取一下KeyedConversations缓存
    
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
    if (![personalId isNotEmptyCtg]) { return; }

//	loaclClient = [[AVIMClient alloc] initWithClientId:personalId tag:personalId];
	loaclClient = [[AVIMClient alloc] initWithClientId:personalId];
	loaclClient.delegate = self;

	AVIMClientOpenOption *openOption = [[AVIMClientOpenOption alloc] init];
	openOption.force = YES;

	[self changeState:WTChatMessageGetListStateOpening];
	[loaclClient openWithOption:nil callback:^(BOOL succeeded, NSError *error) {
		if (error)
		{
			if(loaclClient.status==AVIMClientStatusClosed||loaclClient.status==AVIMClientStatusNone)
				[self changeState:WTChatMessageGetListStateError];
		}
		else
		{
			[ConversationStore sharedInstance].imClient = loaclClient;
			[self openWaitOpenConversation];
			[self changeState:WTChatMessageGetListStateOpen];
			[self updateConversations];
		}
	}];
}

-(void)filterKeyedConversations//过滤我和另一半
{
    NSMutableArray *ourLast = [NSMutableArray array];
    self.keyedConversations = [NSMutableArray arrayWithArray:[[ConversationStore sharedInstance] recentKeyedConversations]];
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
            [[ConversationStore sharedInstance] deleteConversation:con];
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
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation removeObject:[UserInfoManager instance].userId_self forKey:@"channels"];
        [currentInstallation saveInBackground];
        loaclClient.delegate=nil;
        personalId = nil;
        [ConversationStore sharedInstance].imClient = nil;
        waitOpenConversationId=nil;
        [[ConversationStore sharedInstance] setPersonId:@""];
        [self changeState:WTChatMessageGetListStateClosed];
        [[NSNotificationCenter defaultCenter] postNotificationName:unreadNumUpdateNotification object:nil userInfo:nil];
		if(callback) { callback(succeeded,error); }
    };

    if (loaclClient)
	{
        [loaclClient closeWithCallback:^(BOOL succeeded, NSError *error) {
			if(finish) { finish(succeeded,error) ; }
        }];
    }
    else
    {
		if(finish) { finish(YES,nil); }
    }
}

#pragma mark UserInfoManagerObserver
-(void)userInfoUpdate
{
    //登陆
    if (![personalId isNotEmptyCtg])
	{
        if ([[UserInfoManager instance].tokenId_self isNotEmptyCtg])
		{
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
            [[ConversationStore sharedInstance] reviveKeyedConversationsFromLocal];//获取一下KeyedConversations缓存
            
            [self filterKeyedConversations];
            [ChatMessageManager postUnreadNumUpdate];
            [self getKeyedConversationMessage:^{}];
        }
    }
}

#pragma mark AVIMClientDelegate
- (void)imClientPaused:(AVIMClient *)imClient error:(NSError *)error
{
    [self changeState:WTChatMessageGetListStatePaused];
}

- (void)imClientResuming:(AVIMClient *)imClient
{
	[self changeState:WTChatMessageGetListStateReconnecting];
//	[self openClient];
}

- (void)imClientResumed:(AVIMClient *)imClient
{
	if(imClient.status == AVIMClientStatusOpened){
		[self openWaitOpenConversation];
		[self changeState:WTChatMessageGetListStateOpen];
		[self updateConversations];
	}
}

- (void)client:(AVIMClient *)client didOfflineWithError:(NSError *)error
{
	if(error.code == 4111)
	{
		[LoginManager logoutWithFinishBlock:^{
			WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"账号已登录" centerImage:nil];
			[alertView setButtonTitles:@[@"关闭"]];
			[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
				[alertView close];

			}];
			[alertView show];
		}];
	}
}

- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    [self deelNewMsg:conversation message:message];
}

- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    [self deelNewTypeMsg:conversation TypedMessage:message];
}

- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message
{

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
    double num = [[ConversationStore sharedInstance] conversationUnreadCountAll];

	[[NSNotificationCenter defaultCenter]postNotificationName:unreadNumUpdateNotification object:nil userInfo:@{key_unread:@(num) }];
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
    if ([self ifLastBindOurConversation:[conversation keyedConversation]]) { return; }

	//添加本地计划通知
	if([message isKindOfClass:[AVIMTypedMessage class]])
	{
		NSString * conversationTypeKey = [LWUtil getString:[(AVIMTypedMessage *)message attributes][ConversationTypeKey] andDefaultStr:@""];
		if ([conversationTypeKey isEqualToString:ConversationTypeInvitePlan])
		{
			WTMatter *matter = [WTMatter modelWithJSON:[(AVIMTypedMessage *)message attributes][@"data"]];
			[[WTLocalNoticeManager manager] addNoticeWithObject:matter];
		}
		else if ([conversationTypeKey isEqualToString:ConversationTypeDeletePlan])
		{
			WTMatter *matter = [WTMatter modelWithJSON:[(AVIMTypedMessage *)message attributes][@"data"]];
			[[WTLocalNoticeManager manager] removeNoticeWithClassType:[WTMatter class] andID:matter.matter_id];
		}
	}

	__block AVIMMessage *sendMessage = message;
    void(^block)()=^(AVIMConversation *cov){
        [messageDic setObject:@[[[ConversationStore sharedInstance] turnToMessage:message conversation:cov]] forKey:cov.conversationId];
        
        [[ConversationStore sharedInstance] newMessageArrived:message conversation:cov];
        [self filterKeyedConversations];
        
        UserInfo *userSender;
        NSString *avatar=@"";
        NSString *name = @"";
        if (self.keyedConversationOur&&[self.keyedConversationOur.conversationId isEqualToString:conversation.conversationId]) {
            [self postOurUpdateObserver];
			userSender= [[SQLiteAssister sharedInstance] pullUserInfo:[UserInfoManager instance].userId_partner];
        }
        else
        {
            [self postListUpdate:[cov keyedConversation]];
            userSender= [ChatListCell getSupplierWithConversation:conversation.keyedConversation];
        }

		avatar = [LWUtil getString:userSender.avatar andDefaultStr:@""];
		name = [LWUtil getString:userSender.name andDefaultStr:@""];

        BOOL show = NO;
        if( (![KeyWindowCurrentViewController isKindOfClass:[WTChatListViewController class]]
			 &&![KeyWindowCurrentViewController isKindOfClass:[WTChatDetailViewController class]])
		   || ([KeyWindowCurrentViewController isKindOfClass:[WTMainViewController class]]
			   && ((WTMainViewController*)KeyWindowCurrentViewController).selectedIndex!=3) )
        {
			show = YES;
        }

        if (show && ![[message valueForKey:@"offline"] boolValue])
		{
            NotificationTopViewChatMeaasgeObject*objectN=[[NotificationTopViewChatMeaasgeObject alloc]init];
            objectN.conversation=conversation;
            objectN.senderInfo=userSender;
			NSString *subTitle = [ChatListCell getContentWithWithKeyedConversation:conversation.keyedConversation andMessage:message];
			[[NotificationControlCenter instance] pushTopViewOnKeyWindow:avatar
																   title:name
																subTitle:subTitle
																	type:WTNotificationTopViewTypeMessage
																 message:sendMessage
																  object:objectN];
        }
        [[ConversationStore sharedInstance] saveConversations];
        [ChatMessageManager postUnreadNumUpdate];
    };

	[ChatConversationManager getConversationWithConversationId:conversation.conversationId withBlock:^(AVIMConversation *realconversation, NSError *error) {
		if(!error)
		{
			NSMutableArray *members = [NSMutableArray array];
			for (NSString *member in realconversation.members) {
				NSDictionary *channel = @{realconversation.conversationId:member};
				[members addObject:channel];
			}
			ConversationStore *store = [ConversationStore sharedInstance];
			[store queryMoreMessages:conversation.conversationId from:nil timestamp:[[NSDate date] timeIntervalSince1970]*1000 limit:2 callback:^(NSArray *objects, NSError *error) {
				if (objects.count <= 1)
				{
					[ChatConversationManager getUserDataWithMember:members finish:^{
						if(block) { block(realconversation); }
					}];
				}else
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						if(block) { block(realconversation); }
					});
				}
			}];
		}
		else
		{
			[[ConversationStore sharedInstance] newMessageArrived:message conversation:conversation];
		}
	}];
}

- (void)updateConversations
{
	if ([self isFirstGetMsg])
	{
		if(WTChatMessageGetListStateOpen==state||WTChatMessageGetListStatePullConversationFailed==state)
		{
			MBProgressHUD *HUD = [WTProgressHUD showLoadingHUDWithTitle:@"更新数据中" showInView:KEY_WINDOW];
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
							[HUD hide:YES];
						}];
					}];
				}];
			} failure:^{
				[self changeState:WTChatMessageGetListStatePullConversationFailed];
				[HUD hide:YES];
			}];
		}
	}
	else
	{
		if(WTChatMessageGetListStateOpen==state||WTChatMessageGetListStateGetListDone==state)
		{
			[self changeState:WTChatMessageGetListStateUpdateConversations];
			[[ConversationStore sharedInstance] getAVIMConversationsWithBlock:^{
				[self changeState:WTChatMessageGetListStateUpdateUsers];
				[self getConversationUserInfo:^{
					[self changeState:WTChatMessageGetListStateGetListDone];
				}];
			}];
		}
	}
}

-(void)getConversationsFromServer:(void(^)())success failure:(void(^)())failure
{
    [ChatConversationManager getConversationWithUserClientId:personalId  withBlock:^(NSArray *array, NSError *error) {
        if (error) { failure(); }
        else
		{
            if (array){
                for(NSInteger i = array.count - 1 ; i >= 0; i--){
					AVIMConversation *conversation = array[i];
                    if (![self ifLastBindOurConversation:[conversation keyedConversation]]) {
                        [[ConversationStore sharedInstance] addConversation:conversation];
                    }
                }
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
			//从服务器拉取历史纪录
            [conversation queryMessagesFromServerWithLimit:maxHistoryMessageCount callback:^(NSArray *objects, NSError *error) {
                finishNum ++;
                if (!error && objects && objects.count > 0)
				{
					for (AVIMMessage *message in objects)
					{
						if ([message isKindOfClass:[AVIMTypedMessage class]]) {
							AVIMTypedMessage *tmessage=(AVIMTypedMessage*)message;
							if ([self notSaveHistoary:tmessage]) {
								continue;
							}
						}
						[[ConversationStore sharedInstance] getMessageFromServer:message conversation:conversation];
					}
				}

				if (finishNum == conversations.count) { finishBlock(); }
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
            [[ConversationStore sharedInstance] queryMoreMessages:KeyedConversation.conversationId from:nil timestamp:[[NSDate date] timeIntervalSince1970]*1000 limit:1 callback:^(NSArray *objects, NSError *error) {
                finishNum++;
                if (!error && objects && objects.count > 0) {
					[messageDic setValue:objects forKey:KeyedConversation.conversationId];
                }
                
                if (finishNum>=KeyedConversations.count) { finishBlock(); }
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
	if(!name) {return ;}
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
	if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
		failure();
		return;
	}
	AVIMConversation *ourConv = [loaclClient conversationWithKeyedConversation:_keyedConversationOur];
	if(ourConv) { successBlock(); return ; }

    NSArray *ids=@[[UserInfoManager instance].userId_partner,[UserInfoManager instance].userId_self];
    [ChatConversationManager getConversationWithClientIds:ids type:WTConversationTypePartner withBlock:^(AVIMConversation *result, NSError *error) {
        if (error) {
            failure();
        }
        else
        {
			[[ConversationStore sharedInstance] addConversation:result];
            self.keyedConversationOur = [result keyedConversation];
            self.conversationOur = result;
            [result queryMessagesFromServerWithLimit:maxHistoryMessageCount callback:^(NSArray *objects, NSError *error) {//从服务器拉取历史纪录
                if (error) {
                    //不用处理error失败了就失败了无所谓的
                }
                else
                {
                    if (objects&&objects.count>0) {
                        for (AVIMMessage *message in objects)
						{
							NSDictionary *attr = [(AVIMTypedMessage *)message attributes];
							if(attr && [attr[ConversationIsForGameKey] boolValue])
							{

							}
							else
							{
								[[ConversationStore sharedInstance]getMessageFromServer:message conversation:result];
							}
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
		return nil;
    }
    return _conversationOur;
}

-(void)sendToOurConversationBeforeFinish:(void(^)(AVIMConversation *ourCov))finish
{
    [self makeOurConversation:^{
        if (self.keyedConversationOur)
		{
            __block  AVIMConversation *conversation = [loaclClient conversationWithKeyedConversation:self.keyedConversationOur];
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
                        conversation = result;
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
    [[ConversationStore sharedInstance] clearUnreadMsgCount:conversationId];
    [ChatMessageManager postUnreadNumUpdate];
    [[NSNotificationCenter defaultCenter]postNotificationName:WTNotficationCellCheckUnreadNum object:nil];
}

-(BOOL)notSaveHistoary:(AVIMTypedMessage*)message
{
    if (message.attributes) {

        if ([message.attributes[ConversationTypeKey] isEqualToString:ConversationTypeKiss]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KissDidGetPatarnerKissInfoNotify
             object:message.attributes[@"data"]];
            return YES;
        }
        
        if ([message.attributes[ConversationTypeKey] isEqualToString:ConversationTypeDraw]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DrawDidGetPatarnerDrawInfoInfoNotify
             object:message.attributes[@"data"]];
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

@end
