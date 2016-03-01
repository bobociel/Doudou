//
//  ChatManager.m
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "ChatManager.h"
@implementation ChatManager

+ (instancetype)manager
{
	static ChatManager *manager ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[ChatManager alloc] init];
	});
	return manager;
}

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		[AVIMClient defaultClient].delegate = self;
	}
	return self;
}

#pragma mark - Open And Close
- (void)openClientID:(NSString *)clientID callback:(AVIMBooleanResultBlock)callback;
{
	_selfID = clientID;
	[[DatabaseManager manager] loadDataBasePersonalID:_selfID];
	[self openClientID:_selfID callback:^(BOOL succeeded, NSError *error) {
		[self updateConnectStatus];
		if(callback){ callback(succeeded,error); }
	}];
}

- (void)closeWithCallback:(AVIMBooleanResultBlock)callback
{
	[[AVIMClient defaultClient] closeWithCallback:^(BOOL succeeded, NSError *error) {
		[self updateConnectStatus];
		if(callback) { callback(succeeded,error) ; }
	}];
}

- (void)updateConnectStatus
{
	self.connect = [AVIMClient defaultClient].status == AVIMClientStatusOpened;
}

#pragma mark - Conversation
- (void)findRecentConversationWithCallback:(AVIMRecentConversationBlock)callback
{
	[self findAllConversationsWithCallback:^(NSArray *convs, NSError *error) {

	}];
}

- (void)findAllConversationsWithCallback:(AVIMArrayResultBlock)callback
{
	static BOOL fromServer = NO;
	NSArray *conversations = [[DatabaseManager manager] selectAllConversations];
	if(fromServer && self.connect)
	{
//		AVIMConversationQuery *query = [[AVIMClient defaultClient] conversationQuery];
//		[query whereKey:@"m" containsString:_selfID];
//		query.limit = 1000;
//		[query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
//			dispatch_async(dispatch_get_main_queue(), ^{
//				fromServer = YES;
//				[[DatabaseManager manager] replaceItems:objects];
//				callback([[DatabaseManager manager] selectAllConversations],nil);
//			});
//		}];
	}
	else
	{
		callback(conversations,nil);
	}
}


- (void)fetchConversatioionWithMemberId:(NSString *)ID callback:(AVIMConversationResultBlock)callbcak
{
	[self createConversationWithMembserIds:@[ID,_selfID] type:AVIMConversationTypeSigle unique:YES callback:callbcak];
}

- (void)fetchConversatioionWithMemberIds:(NSArray *)IDs callback:(AVIMConversationResultBlock)callbcak
{
	[self createConversationWithMembserIds:IDs type:AVIMConversationTypeGroup unique:YES callback:callbcak];
}

- (void)createConversationWithMembserIds:(NSArray *)IDs callback:(AVIMConversationResultBlock)callback
{
	[self createConversationWithMembserIds:IDs type:AVIMConversationTypeGroup unique:NO callback:callback];
}

- (void)createConversationWithMembserIds:(NSArray *)IDs type:(AVIMConversationType)type unique:(BOOL)unique callback:(AVIMConversationResultBlock)callback
{
	NSMutableSet *membserIDsSet = [NSMutableSet setWithArray:IDs];
	![membserIDsSet.allObjects containsObject:_selfID] ? [membserIDsSet addObject:_selfID] : nil ;
	NSString *name = [membserIDsSet.allObjects componentsJoinedByString:@"_"];
	[[AVIMClient defaultClient] createConversationWithName:name
												 clientIds:membserIDsSet.allObjects
												attributes:@{@"type":@(type)}
												   options:unique
												  callback:^(AVIMConversation *conversation, NSError *error)
	 {
		 if(callback) { callback(conversation,error); }
	 }];
}

#pragma mark - Message


#pragma mark - AVIMClientDelegate
- (void)imClientPaused:(AVIMClient *)imClient
{
	[self updateConnectStatus];
}

- (void)imClientResuming:(AVIMClient *)imClient
{
	[self updateConnectStatus];
}

- (void)imClientResumed:(AVIMClient *)imClient
{
	[self updateConnectStatus];
}

#pragma mark - AVIMTypedMessageDelegate
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message
{

}

- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message
{
	DSLog(@"");
}

#pragma mark - AVIMConversationDelegate

- (void)conversation:(AVIMConversation *)conversation invitedByClientId:(NSString *)clientId
{

}

- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId
{
	
}


@end
