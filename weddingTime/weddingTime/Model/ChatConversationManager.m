//
//  ChatConversationManager.m
//  lovewith
//
//  Created by imqiuhang on 15/4/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ChatConversationManager.h"
#import "GetService.h"
#import "PushNotifyCore.h"
#import "UserInfoManager.h"
#import "WTProgressHUD.h"
#import "ChatMessageManager.h"
#import "NSObject+YYModel.h"
@implementation ChatConversationManager
+ (void)getConversationWithConversationId:(NSString *)conversationId withBlock:(void (^)(AVIMConversation *, NSError *))block
{
    ConversationStore *store = [ConversationStore sharedInstance];

	AVIMConversationQuery *query = [store.imClient conversationQuery];
	query.cachePolicy = kAVIMCachePolicyIgnoreCache ;
	query.limit = 10;
	query.skip = 0;
	[query getConversationById:conversationId callback:^(AVIMConversation *conversation, NSError *error) {
		if (error) {
			block(nil,error);
		}else {
			block(conversation,nil);
		}
	}];
}

+ (void)getConversationWithClientIds:(NSArray *)clientIds type:(int)type withBlock:(void (^)(AVIMConversation *, NSError *))block{

	if(!clientIds) { return; }
    ConversationStore *store = [ConversationStore sharedInstance];
	__block WTConversationType convType = type == WTConversationTypePost ? WTConversationTypeSupplier : type;
	__block NSArray *sortedClientIds = [clientIds sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
		return [(NSString *)obj1 doubleValue] - [(NSString *)obj2 doubleValue];
	}];
	__block NSString *name = [sortedClientIds componentsJoinedByString:@"_"];

	AVIMConversationQuery *query = [store.imClient conversationQuery];
	query.cachePolicy = kAVIMCachePolicyIgnoreCache;
	[query whereKey:kAVIMKeyMember containsAllObjectsInArray:clientIds];
	[query whereKey:kAVIMKeyMember sizeEqualTo:clientIds.count];
	query.limit = 10;
	query.skip = 0;
	[query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
		if(objects && objects.count > 1){
			AVIMConversation *resultConversation = (AVIMConversation *)objects[0];
			if(block) { block(resultConversation, nil); }
		}else {
			[store.imClient createConversationWithName:name
											 clientIds:sortedClientIds
									        attributes:@{@"type":@(convType),@"enable":@"true"}
											   options:AVIMConversationOptionUnique
											  callback:^(AVIMConversation *conversation, NSError *error)
			 {
				 if(conversation) {  if(block) { block(conversation,nil); } }
				 else { if(block) { block(nil,error); } }
			 }];
		}
	}];
}

+ (void)getConversationWithUserClientId:(NSString *)clientId withBlock:(void (^)(NSArray *array, NSError *))block {

	ConversationStore *store = [ConversationStore sharedInstance];

	AVIMConversationQuery *query = [store.imClient conversationQuery];
	query.cachePolicy = kAVIMCachePolicyIgnoreCache ;
	[query whereKey:kAVIMKeyMember containsString:clientId];
	query.limit = 10;
	query.skip = 0;
	[query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
		if (error) {
			block(nil,error);
		} else if (!objects || [objects count] < 1) {
			block([NSArray new],nil);
		} else {
			block(objects,nil);
		}
	}];
}


//输入框发送了一条文本
+ (void)sendMessage:(NSString *)message conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure{
    if ([message length] > 0) {
        AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:message attributes:nil];
        [ChatConversationManager sendAVIMessage:avMessage conversation:conversation success:^(NSArray *partners){
            if (push) {
                [PushNotifyCore pushMessageToPartnerWithContent:message partners:partners conversation:conversation];
            }
			if(success) { success(); }
        }  failure:^(NSError *error) {
			if(failure) { failure(error); }
        }];
    }
}

//输入框发送了一条语音
+ (void)sendVoice:(NSString *)filePath andLenth:(float)lenth conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure{
    if (filePath&&lenth>0.1) {
        AVIMAudioMessage *avMessage = [AVIMAudioMessage messageWithText:nil attachedFilePath:filePath attributes:nil];
        [ChatConversationManager sendAVIMessage:avMessage conversation:conversation success:^(NSArray *partners){
            if (push) {
                [PushNotifyCore pushMessageToPartnerWithContent:pushSendVoiceToParterContent partners:partners conversation:conversation];
            }
            success();
        }  failure:^(NSError *error) {
            failure(error);
        }];
    }
}

//输入框发送图片
+ (void)sendImage:(NSString *)imagePath text:(NSString *)text attributes:(NSDictionary *)attributes conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure{
    AVIMImageMessage *avMessage = [AVIMImageMessage messageWithText:text attachedFilePath:imagePath attributes:attributes];
    [ChatConversationManager sendAVIMessage:avMessage conversation:conversation success:^(NSArray *partners){
        if (push) {
            [PushNotifyCore pushMessageToPartnerWithContent:pushSendImageToParterContent partners:partners conversation:conversation];
        }
        success();
    }  failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)sendCustomMessageWithPushName:(NSString *)pushName andConversationTypeKey:(NSString *)Key andConversationValue:(id)value andCovTitle:(NSString *)title conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure{

		AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:title?title:@"" attributes:@{ConversationTypeKey:Key,ConversationValueKey:value}];
		[ChatConversationManager sendAVIMessage:avMessage conversation:conversation success:^(NSArray *partners) {
			if ([pushName isNotEmptyCtg] && push) {
				[PushNotifyCore pushMessageToPartnerWithContent:pushName partners:partners conversation:conversation];
			}
			success();
		}  failure:^(NSError *error) {
			failure(error);
		}];
}

+ (void)sendAVIMessage:(AVIMMessage *)message conversation:(AVIMConversation*)conversation success:(void(^)(NSArray*partners))success failure:(void(^)( NSError *error))failure{
    if (conversation) {
        [conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
            if (error) {
				[WTProgressHUD ShowTextHUD: IFDEBUG ? error.localizedDescription : @"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
            } else {
                [[ConversationStore sharedInstance] newMessageSent:message conversation:conversation];
                NSMutableArray *partners = [NSMutableArray new];
                for (NSString *member in conversation.members) {
                    if (![member isEqualToString:[UserInfoManager instance].userId_self]) {
                        [partners addObject:member];
                    }
                }
                success(partners);
            }
        }];
    }
    else
    {
		[WTProgressHUD ShowTextHUD:IFDEBUG ? @"未连接聊天服务器" : @"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
    }
}

+(void)getUserDataWithMember:(NSArray*)members finish:(void(^)())finishBlock
{
	if (members.count==0){ finishBlock(); return ; }

	NSString*json=[LWUtil toJSONString:members] ;
	[GetService getChatListMsg:json  withBlock:^(NSDictionary *dic, NSError *error) {
		if (!error) {
			NSArray*chatMsgList= dic[@"items"];
			for (NSDictionary *dic in chatMsgList)
			{
				[[SQLiteAssister sharedInstance] pushItem:[UserInfo modelWithDictionary:dic]];
			}
		}
		finishBlock();
	}];
}

@end
