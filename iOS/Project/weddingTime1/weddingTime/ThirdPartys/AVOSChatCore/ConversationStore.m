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

@interface ConversationStore() {
    NSMutableOrderedSet *_conversations;
    NSMutableDictionary *_conversationUnreadMsgMapping;
    NSMutableDictionary *_observerMapping;
    
    NSMutableOrderedSet *_keyedConversations;
    
    NSString *personalId;
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
    static ConversationStore *store = nil;
    if (nil == store) {
        store = [[ConversationStore alloc] init];
    }
    return store;
}

-(void)setPersonId:(NSString*)personId
{
    personalId=personId;
    if ([personalId isNotEmptyCtg]) {
        [[SQLiteMessagePersister sharedInstance] openSql:personalId];
    }
    else
    {
        [[SQLiteMessagePersister sharedInstance] close];
    }
}

-(void)reviveKeyedConversationsFromLocal
{
    [_keyedConversations removeAllObjects];
    [_conversationUnreadMsgMapping removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *originArchiverPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_conversation.dat", personalId]];
    NSData *encodedData = [[NSData alloc] initWithContentsOfFile:originArchiverPath];
    if (!encodedData) {
        return;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:encodedData];
    NSMutableArray *keyedConversations = [unarchiver decodeObjectForKey:kDecodeKey_Conversations];
    [_keyedConversations addObjectsFromArray:keyedConversations];
    
    _conversationUnreadMsgMapping = [unarchiver decodeObjectForKey:kDecodeKey_Conversation_UnreadMapping];
    [unarchiver finishDecoding];
}

-(void)getAVIMConversationsWithBlock:(void(^)())block{
    [_conversations removeAllObjects];
    
    NSMutableArray *tmpConversationIds=[[NSMutableArray alloc]init];
    for (AVIMKeyedConversation *KeyedConversation in _keyedConversations) {
        [tmpConversationIds addObject:KeyedConversation.conversationId];
    }
    
    AVIMConversationQuery *query = [self.imClient conversationQuery];
    [query whereKey:kAVIMKeyConversationId containedIn:tmpConversationIds];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        if (error || objects.count < 1) {
            
        } else {
            AVIMConversation *tmp = nil;
            for (int i = 0; i < objects.count; i++) {
                tmp = [objects objectAtIndex:i];
                
                if (![_conversations containsObject:tmp]) {
                    [_conversations addObject:tmp];
                }
                int index=[self returnIndexInKeyArray:[tmp keyedConversation]];
                if (index>=0&&index<_keyedConversations.count) {
                    [_keyedConversations replaceObjectAtIndex:index withObject:[tmp keyedConversation]];
                }
            }
            [self saveConversations];
        }
        block();
        return;
    }];
}

-(BOOL)dump2Local:(AVUser*)user {
    NSString *userId=user.username;
    
    if (!userId || userId.length <= 0) {
        return NO;
    }
    // [[SQLiteMessagePersister sharedInstance] close];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_conversation.new.dat", userId]];
    NSString *originArchiverPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_conversation.dat", userId]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager removeItemAtPath:filePath error:NULL];
    
    NSMutableArray *keyedConversations = [[NSMutableArray alloc] initWithCapacity:_keyedConversations.count];
    for (int i = 0; i < [_keyedConversations count]; i++) {
        [keyedConversations addObject:_keyedConversations[i]];
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:keyedConversations forKey:kDecodeKey_Conversations];
    [archiver encodeObject:_conversationUnreadMsgMapping forKey:kDecodeKey_Conversation_UnreadMapping];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
    
    [fileManager removeItemAtPath:originArchiverPath error:NULL];
    result = [fileManager moveItemAtPath:filePath toPath:originArchiverPath error:NULL];
    if (!result) {
        MSLog(@"failed to move conversation tmp file");
    }
    return result;
}

-(int)returnIndexInKeyArray:(AVIMKeyedConversation *)keycon
{
    for (int i=0;i<_keyedConversations.count;i++) {
        AVIMKeyedConversation *KeyedConversation=_keyedConversations[i];
        if ([keycon.conversationId isEqualToString:KeyedConversation.conversationId]) {
            return i;
        }
    }
    return -1;
}

-(int)returnIndexInConArray:(AVIMConversation *)con
{
    for (int i=0;i<_conversations.count;i++) {
        AVIMConversation *Conversation=_conversations[i];
        if ([con.conversationId isEqualToString:Conversation.conversationId]) {
            return i;
        }
    }
    return -1;
}

- (void)addConversation:(AVIMConversation*)conversation {
    if (!conversation) {
        return;
    }
    
    int index=[self returnIndexInKeyArray:[conversation keyedConversation]];
    if (index>=0) {
        [_keyedConversations replaceObjectAtIndex:index withObject:[conversation keyedConversation]];
    }
    else
    {
        [_keyedConversations addObject:[conversation keyedConversation]];
    }
    
    index=[self returnIndexInConArray:conversation];
    if (index>=0) {
        [_conversations replaceObjectAtIndex:index withObject:conversation];
    }
    else
    {
        [_conversations addObject:conversation];
    }
}

-(void)clearUnreadMsgCount:(NSString*)conversationId
{
    [_conversationUnreadMsgMapping setObject:[NSNumber numberWithInt:0] forKey:conversationId];
    //TODO通知更新未读总数，更新未读数量
    [self saveConversations];
}

- (void)deleteConversation:(AVIMKeyedConversation *)conversation {
    AVIMKeyedConversation *removeKeyedConversation;
    for ( AVIMKeyedConversation *KeyedConversation in _keyedConversations) {
        if ([conversation.conversationId isEqualToString:KeyedConversation.conversationId]) {
            removeKeyedConversation=KeyedConversation;
        }
    }
    if(removeKeyedConversation)
        [_keyedConversations removeObject:removeKeyedConversation];
    
    [_conversations removeObject:conversation];
    [_conversationUnreadMsgMapping setObject:[NSNumber numberWithInt:0] forKey:conversation.conversationId];
}

- (void)changeConversationToHead:(AVIMConversation*)conversation {
    if (!conversation) {
        return;
    }
    
    AVIMKeyedConversation *removeKeyedConversation;
    for ( AVIMKeyedConversation *KeyedConversation in _keyedConversations) {
        if ([conversation.conversationId isEqualToString:KeyedConversation.conversationId]) {
            removeKeyedConversation=KeyedConversation;
        }
    }
    if(removeKeyedConversation)
        [_keyedConversations removeObject:removeKeyedConversation];
    [_keyedConversations insertObject:[conversation keyedConversation] atIndex:0];
    
    [_conversations removeObject:conversation];
    [_conversations insertObject:conversation atIndex:0];
}

- (NSArray*)recentKeyedConversations {
    int count = (int)[_keyedConversations count];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) {
        AVIMKeyedConversation *conversation=  [_keyedConversations objectAtIndex:i];
        [result addObject:conversation];
    }
    return result;
}

- (NSArray*)recentConversations{
    int count = (int)[_conversations count];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) {
        AVIMConversation *conversation=  [_conversations objectAtIndex:i];
        [result addObject:conversation];
    }
    return result;
}

- (void)queryMoreMessages:(NSString*)conversationid from:(NSString*)msgId timestamp:(int64_t)ts limit:(int)limit callback:(ArrayResultBlock)callback {
    
    [[SQLiteMessagePersister sharedInstance] pullMessagesForConversationid:conversationid preceded:msgId timestamp:ts limit:limit callback:^(NSArray *objects, NSError *error) {
        callback(objects,error);
    }];
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
    if (ChangeTohead) {//不是拉历史纪录
        [self changeConversationToHead:conv];
        NSNumber *unreadCount = [_conversationUnreadMsgMapping objectForKey:conv.conversationId];
        if (unreadCount) {
            unreadCount = [NSNumber numberWithInt:(unreadCount.intValue + 1)];
        } else {
            unreadCount = [NSNumber numberWithInt:1];
        }
        
        [_conversationUnreadMsgMapping setObject:unreadCount forKey:conv.conversationId];
    }
    
    SQLiteMessagePersister *persister = [SQLiteMessagePersister sharedInstance];
    [persister pushMessage:message];
    
    if (ChangeTohead)
    {
        NSMutableArray *observerChain = [_observerMapping objectForKey:[conv conversationId]];
        if (observerChain) {
            for (int i = 0; i < [observerChain count]; i++) {
                NSValue *value = [observerChain objectAtIndex:i];
                id<IMEventObserver> observer = [value nonretainedObjectValue];
                if (message.imMessage.ioType==AVIMMessageIOTypeOut) {
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

- (int)conversationUnreadCount:(NSString*)conversationId {
    NSNumber *count = [_conversationUnreadMsgMapping objectForKey:conversationId];
    if (count) {
        return count.intValue;
    }
    return 0;
}

- (void)addEventObserver:( id<IMEventObserver>)observer forConversation:(NSString*)conversationId {
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

- (int)conversationUnreadCountAll
{
    int allnum=0;
    for (AVIMKeyedConversation *conversation in _keyedConversations) {
        allnum+= [self conversationUnreadCount:conversation.conversationId];
    }
    return allnum;
}

-(BOOL)saveConversations
{
    AVUser *user=[AVUser user];
    user.username=personalId;
    return [[ConversationStore sharedInstance] dump2Local:user];
}


@end


