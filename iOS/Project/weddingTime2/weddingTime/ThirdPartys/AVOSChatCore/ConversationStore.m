//
//  ConversationStore.m
//  FreeChat
//
//  Created by Feng Junwen on 2/5/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ConversationStore.h"
#import "SQLiteMessagePersister.h"
#define kDecodeKey_Conversations                  @"conversations"
#define kDecodeKey_Conversation_UnreadMapping     @"conversation_msg_mapping"

@interface ConversationStore()
{
	NSString *personalId;

	NSMutableOrderedSet *_keyedConversations;
    NSMutableOrderedSet *_conversations;

    NSMutableDictionary *_conversationUnreadMsgMapping;
    NSMutableDictionary *_observerMapping;
}

@end

@implementation ConversationStore

@synthesize networkAvailable;

- (id)init {
    self = [super init];
    if (self) {
        _conversations = [[NSMutableOrderedSet alloc] initWithCapacity:100];
        _keyedConversations = [[NSMutableOrderedSet alloc] initWithCapacity:100];
        _conversationUnreadMsgMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
        _observerMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return self;
}

+ (instancetype)sharedInstance {
	static ConversationStore *store;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        store = [[ConversationStore alloc] init];
    });

	return store;
}

-(void)setPersonId:(NSString*)personId
{
    personalId = personId;

	[personalId isNotEmptyCtg] ? [[SQLiteMessagePersister sharedInstance] openSql:personalId] : [[SQLiteMessagePersister sharedInstance] close] ;
}

- (NSString *)originArchiverPath:(NSString *)fileId
{
	NSString *fileName = [NSString stringWithFormat:@"/%@_conversation.dat",fileId];
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:fileName];
}

- (NSString *)tempArchiverPath:(NSString *)fileId
{
	NSString *fileName = [NSString stringWithFormat:@"/%@_conversation.new.dat",fileId];
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:fileName];
}


#pragma mark - Init Local Data
-(void)reviveKeyedConversationsFromLocal
{
    [_keyedConversations removeAllObjects];
    [_conversationUnreadMsgMapping removeAllObjects];

	NSData *encodedData = [[NSData alloc] initWithContentsOfFile:[self originArchiverPath:personalId]];
    if (encodedData)
	{
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:encodedData];
		[_keyedConversations addObjectsFromArray:[unarchiver decodeObjectForKey:kDecodeKey_Conversations]];
		_conversationUnreadMsgMapping = [unarchiver decodeObjectForKey:kDecodeKey_Conversation_UnreadMapping];
		[unarchiver finishDecoding];
    }
}

- (NSArray*)recentKeyedConversations
{
	NSInteger count = [_keyedConversations count];
	if(count == 0){ [self reviveKeyedConversationsFromLocal]; }

	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
	for (int i = 0; i < count; i++) {
		AVIMKeyedConversation *conversation=  [_keyedConversations objectAtIndex:i];
		[result addObject:conversation];
	}
	return result;
}

- (NSArray*)recentConversations
{
	NSInteger count = [_conversations count];
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
	for (int i = 0; i < count; i++) {
		AVIMConversation *conversation=  [_conversations objectAtIndex:i];
		[result addObject:conversation];
	}
	return result;
}

#pragma mark - Deal With Conversation
- (void)getAVIMConversationsWithBlock:(void(^)())block{
	[_conversations removeAllObjects];

	NSMutableArray *tmpConversationIds = [NSMutableArray array];
	for (AVIMKeyedConversation *KeyedConversation in [self recentKeyedConversations]) {
		[tmpConversationIds addObject:KeyedConversation.conversationId];
	}

	AVIMConversationQuery *query = [self.imClient conversationQuery];
	query.cachePolicy = kAVIMCachePolicyIgnoreCache ;
	[query whereKey:kAVIMKeyConversationId containedIn:tmpConversationIds];
	[query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
		if (!error || objects.count > 0) {
			for (NSInteger i = objects.count - 1; i >= 0; i--)
			{
				AVIMConversation *tmpConv = (AVIMConversation *)objects[i];
				[self addConversation:tmpConv];
			}
		}

		if(block) { block(); }
	}];
}

- (void)addConversation:(AVIMConversation*)conversation {
	if (!conversation) { return; }

	NSInteger keyedConvIndex = [self returnIndexInKeyArray:[conversation keyedConversation]];
	if(keyedConvIndex >= 0){ [_keyedConversations removeObjectAtIndex:keyedConvIndex]; }
	[_keyedConversations insertObject:conversation.keyedConversation atIndex:0];

	NSInteger convIndex = [self returnIndexInConArray:conversation.keyedConversation];
	if(convIndex >= 0){ [_conversations removeObjectAtIndex:convIndex]; }
	[_conversations insertObject:conversation atIndex:0];

	[self saveConversations];
}

- (void)deleteConversation:(AVIMKeyedConversation *)keyedConversation
{
	NSInteger keyedConvIndex = [self returnIndexInKeyArray:keyedConversation];
	keyedConvIndex >= 0 ? [_keyedConversations removeObjectAtIndex:keyedConvIndex] : nil ;

	NSInteger convIndex = [self returnIndexInConArray:keyedConversation];
	convIndex >= 0 ? [_conversations removeObjectAtIndex:convIndex] : nil;

	[_conversationUnreadMsgMapping setObject:@(0) forKey:keyedConversation.conversationId];

	[[ConversationStore sharedInstance] saveConversations];
}

-(NSInteger)returnIndexInKeyArray:(AVIMKeyedConversation *)keycon
{
	for (int i=0;i<_keyedConversations.count;i++) {
		AVIMKeyedConversation *KeyedConversation=_keyedConversations[i];
		if ([keycon.conversationId isEqualToString:KeyedConversation.conversationId]) {
			return i;
		}
	}
	return -1;
}

-(NSInteger)returnIndexInConArray:(AVIMKeyedConversation *)keyedConv
{
	for (int i=0;i<_conversations.count;i++) {
		AVIMConversation *Conversation=_conversations[i];
		if ([keyedConv.conversationId isEqualToString:Conversation.conversationId]) {
			return i;
		}
	}
	return -1;
}

#pragma mark - Deal With Message
- (void)queryMoreMessages:(NSString *)conversationId from:(NSString*)msgId timestamp:(int64_t)ts limit:(int)limit callback:(ArrayResultBlock)callback {
	if(conversationId){
		[[SQLiteMessagePersister sharedInstance] pullMessagesForConversationid:conversationId preceded:msgId timestamp:ts limit:limit callback:^(NSArray *objects, NSError *error) {
			if(callback) { callback(objects,error); }
		}];
	}
	else
	{
		if(callback) { callback(nil,nil); }
	}
}

// 对话中新的事件发生
- (void)newConversationEvent:(IMMessageType)event conversation:(AVIMConversation*)conv from:(NSString*)clientId to:(NSArray*)clientIds {
    Message *newMessage = [[Message alloc] init];
    newMessage.eventType = event;
    newMessage.imMessage = nil;
    newMessage.convId = [conv conversationId];
    newMessage.clients = clientIds;
    newMessage.byClient = clientId;
    newMessage.sentTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    switch (event) {
        case EventInvited:
            break;
        case EventKicked:
            break;
        case EventMemberAdd:
            break;
        case EventMemberRemove:
            break;
        default:
            return;
    }
    [self fireNewMessage:newMessage conversation:conv withChangeTohead:YES];
}

- (void)fireNewMessage:(Message*)message conversation:(AVIMConversation*)conv withChangeTohead:(BOOL)ChangeTohead{
	NSMutableArray *userClients = [[NSMutableArray alloc] initWithObjects:message.byClient, nil];
	if (message.clients) {
		[userClients addObjectsFromArray:message.clients];
	}

	//不是拉历史纪录
	if (ChangeTohead)
	{
		//添加或更新对话 计算未读条数.
		[self addConversation:conv];
		NSNumber *unreadCount = [NSNumber numberWithDouble:([self conversationUnreadCount:conv.conversationId] + 1)];
		[_conversationUnreadMsgMapping setObject:unreadCount forKey:conv.conversationId];
		[self saveConversations];
	}

	[[SQLiteMessagePersister sharedInstance] pushMessage:message];

	if (ChangeTohead)
	{
		NSMutableArray *observerChain = [_observerMapping objectForKey:[conv conversationId]];
		if (observerChain)
		{
			for (int i = 0; i < [observerChain count]; i++){
				id<IMEventObserver> observer = [[observerChain objectAtIndex:i] nonretainedObjectValue];
				if (message.imMessage.ioType == AVIMMessageIOTypeOut) {
					[observer newMessageSend:message conversation:conv];
				}
				else
				{
					[observer newMessageArrived:message conversation:conv];
				}
			}
		}
	}
}

- (void)newMessageSent:(AVIMMessage *)message conversation:(AVIMConversation *)conv {
    [self fireNewMessage:[self turnToMessage:message conversation:conv] conversation:conv withChangeTohead:YES];
    if (self.conversationDelegate) {
        [self.conversationDelegate sendMsgUpdate:message conversation:conv];
    }
}

-(void)getMessageFromServer:(AVIMMessage*)message conversation:(AVIMConversation*)conv
{
    [self fireNewMessage:[self turnToMessage:message conversation:conv] conversation:conv withChangeTohead:NO];
}

- (void)newMessageArrived:(AVIMMessage*)message conversation:(AVIMConversation*)conv {
    
    [self fireNewMessage:[self turnToMessage:message conversation:conv] conversation:conv withChangeTohead:YES];
}

-(Message*)turnToMessage:(AVIMMessage*)message conversation:(AVIMConversation*)conv
{
    Message *newMessage = [[Message alloc] init];
    newMessage.imMessage = message;
    newMessage.eventType = CommonMessage;
    newMessage.convId =[conv conversationId];
    newMessage.clients = nil;
    newMessage.byClient = [message clientId];
    newMessage.sentTimestamp = message.sendTimestamp;
    return newMessage;
}

- (void)messageDelivered:(AVIMMessage*)message conversation:(AVIMConversation*)conv {
    // 无需特别处理
}

#pragma mark - Observer
- (void)addEventObserver:( id<IMEventObserver>)observer forConversation:(NSString*)conversationId {
	if(!conversationId) {return ;}
	NSValue *value = [NSValue valueWithNonretainedObject:observer];
	NSMutableArray *observerChain = [_observerMapping objectForKey:conversationId];
	if (observerChain == nil) {
		observerChain = [[NSMutableArray alloc] initWithObjects:value, nil];
	} else {
		if(![observerChain containsObject:value])
			[observerChain addObject:value];
	}
	[_observerMapping setObject:observerChain forKey:conversationId];
}

- (void)removeEventObserver:(id<IMEventObserver>)observer forConversation:(NSString*)conversationId {
	NSValue *value = [NSValue valueWithNonretainedObject:observer];
	NSMutableArray *observerChain = [_observerMapping objectForKey:conversationId];
	if (observerChain != nil) {
		if ([observerChain containsObject:value]) {
			[observerChain removeObject:value];
			[_observerMapping setObject:observerChain forKey:conversationId];
		}
	}
}

- (void)removeAllEventObserver {
	[_conversations removeAllObjects];
	[_conversationUnreadMsgMapping removeAllObjects];
	[_observerMapping removeAllObjects];
}


#pragma mark - Deal Msg Count
- (double)conversationUnreadCountAll
{
	double allnum=0;
	for (AVIMKeyedConversation *conversation in _keyedConversations) {
		allnum+= [self conversationUnreadCount:conversation.conversationId];
	}
	return allnum;
}

- (double)conversationUnreadCount:(NSString*)conversationId {
	NSNumber *count = [_conversationUnreadMsgMapping objectForKey:conversationId];
	if (count) {
		return count.doubleValue;
	}
	return 0;
}

-(void)clearUnreadMsgCount:(NSString*)conversationId
{
	//TODO通知更新未读总数，更新未读数量
	[_conversationUnreadMsgMapping setObject:[NSNumber numberWithInt:0] forKey:conversationId];
	[self saveConversations];
}

#pragma mark - Remove Local All Data
- (void)removeAllConversationFromLocal
{
	[_keyedConversations removeAllObjects];
	[_conversations removeAllObjects];
	[_conversationUnreadMsgMapping removeAllObjects];

	[[ChatMessageManager instance].keyedConversations removeAllObjects];
	[ChatMessageManager instance].keyedConversationOur = nil;
	[ChatMessageManager instance].conversationOur = nil;
	[self saveConversations];

	[[SQLiteAssister sharedInstance] deleteAllItem:[UserInfo new]];
}

#pragma mark - Save Conversation And Message
- (BOOL)saveConversations
{
	if (!personalId || personalId.length == 0) { return NO; }

	[[NSFileManager defaultManager] removeItemAtPath:[self tempArchiverPath:personalId] error:nil];

	NSMutableArray *keyedConversations = [[NSMutableArray alloc] initWithCapacity:_keyedConversations.count];
	for (int i = 0; i < [_keyedConversations count]; i++) {
		[keyedConversations addObject:_keyedConversations[i]];
	}

	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:keyedConversations forKey:kDecodeKey_Conversations];
	[archiver encodeObject:_conversationUnreadMsgMapping forKey:kDecodeKey_Conversation_UnreadMapping];
	[archiver finishEncoding];
	[data writeToFile:[self tempArchiverPath:personalId] atomically:YES];

	[[NSFileManager defaultManager] removeItemAtPath:[self originArchiverPath:personalId] error:nil];

	BOOL result = [[NSFileManager defaultManager] moveItemAtPath:[self tempArchiverPath:personalId]
														  toPath:[self originArchiverPath:personalId]
														   error:nil];
	if (!result) {
		MSLog(@"failed to move conversation tmp file");
	}
	return result;
}

@end

