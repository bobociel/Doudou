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
#import "WTLocalDataManager.h"
#import "ChatMessageManager.h"
@implementation ChatConversationManager
+ (void)getConversationWithConversationId:(NSString *)conversationId withBlock:(void (^)(AVIMConversation *, NSError *))block
{
    ConversationStore *store = [ConversationStore sharedInstance];
    if(!store.imClient) {
        NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_ClientNotOpen userInfo:@{@"msg":@"AVIMClient没有创建"}];
        block(nil,err);
    }else {
        AVIMClient *imClient = [[ConversationStore sharedInstance] imClient];
        AVIMConversationQuery *query = [imClient conversationQuery];
        query.limit = 10;
        query.skip = 0;
        [query getConversationById:conversationId callback:^(AVIMConversation *conversation, NSError *error) {
            if (error) {
                NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_findConversationsFalid userInfo:@{@"msg":@"寻找会话失败"}];
                block(nil,err);
            }
            else {
                block(conversation,nil);
            }
            
        }];
    }
}

+ (void)getConversationWithClientIds:(NSArray *)clientIds type:(int)type withBlock:(void (^)(AVIMConversation *, NSError *,BOOL))block{
    ConversationStore *store = [ConversationStore sharedInstance];
    if(!store.imClient) {
        NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_ClientNotOpen userInfo:@{@"msg":@"AVIMClient没有创建"}];
        block(nil,err,NO);
    }else {
        AVIMClient *imClient = [[ConversationStore sharedInstance] imClient];
        
        void(^creatBlock)()=^{
            NSComparator cmptr = ^(id obj1, id obj2){
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            };
            //排序前
            NSMutableString *outputBefore = [[NSMutableString alloc] init];
            for (int i=0; i<clientIds.count; i++) {
                NSString *str=clientIds[i];
                if (i==0) {
                    outputBefore=[NSMutableString stringWithString:str];
                }
                else
                {
                    [outputBefore appendFormat:@"_%@",str];
                }
            }
            NSLog(@"排序前:%@",outputBefore);
            //第一种排序
            NSArray *array = [clientIds sortedArrayUsingComparator:cmptr];
            NSMutableString *outputAfter = [[NSMutableString alloc] init];
            for (int i=0; i<array.count; i++) {
                NSString *str=array[i];
                if (i==0) {
                    outputAfter=[NSMutableString stringWithString:str];
                }
                else
                {
                    [outputAfter appendFormat:@"_%@",str];
                }
            }
            NSLog(@"排序后:%@",outputAfter);
            
            [imClient createConversationWithName:outputAfter
                                       clientIds:clientIds
                                      attributes:@{@"type":[NSNumber numberWithInt:type]}
                                         options:AVIMConversationOptionNone
                                        callback:^(AVIMConversation *conversation, NSError *error) {
                                            if (error) {
                                                NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_createConversationFaild userInfo:@{@"msg":@"创建会话失败"}];
                                                block(nil,err,NO);
                                            } else {
                                                block(conversation,nil,YES);
                                            }
                                        }];
        };
        
        AVIMConversationQuery *query = [imClient conversationQuery];
        query.limit = 10;
        query.skip = 0;
        [query whereKey:kAVIMKeyMember containsAllObjectsInArray:clientIds];
        [query whereKey:AVIMAttr(@"type") equalTo:[NSNumber numberWithInt:type]];
        
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (error) {
                NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_findConversationsFalid userInfo:@{@"msg":@"寻找会话失败"}];
                block(nil,err,NO);
            } else if (!objects || [objects count] < 1) {
                creatBlock();
            } else{
                AVIMConversation *resultConversation ;
                for (AVIMConversation *con in objects) {
                    if (con.members.count == clientIds.count) {
                        BOOL done=YES;
                        for (id str in con.members) {
                            if (![clientIds containsObject:str]) {
                                done=NO;
                                break;
                            }
                        }
                        if (done) {
                            resultConversation=con;
                            break;
                        }
                    }
                }
                if (resultConversation) {
                    block(resultConversation, nil, NO);
                }
                else
                {
                    creatBlock();
                }
                return ;
            }
        }];
    }
}

+ (void)getConversationWithUserClientId:(NSString *)clientId withBlock:(void (^)(NSArray *array, NSError *))block {
    ConversationStore *store = [ConversationStore sharedInstance];
    if(!store.imClient) {
        NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_ClientNotOpen userInfo:@{@"msg":@"AVIMClient没有创建"}];
        block(nil,err);
    }else {
        AVIMClient *imClient = [[ConversationStore sharedInstance] imClient];
        AVIMConversationQuery *query = [imClient conversationQuery];
        query.limit = 10;
        query.skip = 0;
        [query whereKey:kAVIMKeyMember containsString:clientId];
        //  [query whereKey:AVIMAttr(@"type") equalTo:[NSNumber numberWithInt:kConversationType_Group]];
        
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (error) {
                NSError *err = [NSError errorWithDomain: ERRORDOMAIN code:errCode_findConversationsFalid userInfo:@{@"msg":@"寻找会话失败"}];
                block(nil,err);
            } else if (!objects || [objects count] < 1) {
                block([NSArray new],nil);
            } else {
                block(objects,nil);
            }
        }];
    }
}


//输入框发送了一条文本
+ (void)sendMessage:(NSString *)message conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure{
    if ([message length] > 0) {
        AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:message attributes:nil];
        [ChatConversationManager sendAVIMessage:avMessage conversation:conversation success:^(NSArray *partners){
            if (push) {
                [PushNotifyCore pushMessageToPartnerWithContent:message partners:partners conversation:conversation];
            }
            success();
        }  failure:^(NSError *error) {
            failure(error);
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
        if ([pushName isNotEmptyCtg]&&push) {
            [PushNotifyCore pushMessageToPartnerWithContent:pushName partners:partners conversation:conversation];
        }
        success();
    }  failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)sendAVIMessage:(AVIMMessage *)message conversation:(AVIMConversation*)conversation  success:(void(^)(NSArray*partners))success failure:(void(^)( NSError *error))failure{
    if (conversation) {
        [conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [WTProgressHUD ShowTextHUD:@"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
            } else {
                [[ConversationStore sharedInstance] newMessageSent:message conversation:conversation];
                NSMutableArray *partners;
                partners=[NSMutableArray new];
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
        [WTProgressHUD ShowTextHUD:@"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
    }
}

//
//+ (void)sendLocalCustomMessageWithConversationTypeKey:(NSString *)Key andCovTitle:(NSString *)title {
//    AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:title?title:@"" attributes:@{ConversationTypeKey:Key}];
//    Message *newMessage = [[Message alloc] init];
//    newMessage.imMessage = avMessage;
//    newMessage.eventType = CommonMessage;
//    newMessage.clients = nil;
//    avMessage.deliveredTimestamp =[[NSDate date]timeIntervalSince1970]*1000;
//    avMessage.sendTimestamp = [[NSDate date]timeIntervalSince1970]*1000;
//    [[NSNotificationCenter defaultCenter] postNotificationName:NewLocalMessageSendNotify object:newMessage];
//}
//
//+ (void)sendAVIMessage:(AVIMMessage *)message conversation:(AVIMConversation*)conversation  block:(void(^)(NSArray*partners))success{
//    if (conversation) {
//        [conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
//            if (error) {
//               // [AlertView ShowTextHUD:@"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
//            } else {
//                [[ConversationStore sharedInstance] newMessageSent:message conversation:conversation];
//                NSMutableArray *partners;
//                partners=[NSMutableArray new];
//                for (NSString *member in conversation.members) {
//                    if (![member isEqualToString:[UserInfoManager instance].userId_self]) {
//                        [partners addObject:member];
//                    }
//                }
//
//                success(partners);
//            }
//        }];
//    }
//    else
//    {
//         [AlertView ShowTextHUD:@"可能由于服务器原因,暂时无法发送" showInView:KEY_WINDOW];
//    }
//}
//
//+ (void)sendFirstMessage {
//
//    if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
//        if (![UserInfoManager instance].isFirstChat) {
//            return;
//        }
//        [ChatConversationManager sendLocalCustomMessageWithConversationTypeKey:@"" andCovTitle:@"您可以和另一半开始聊天咯"];
//        [ChatConversationManager sendLocalCustomMessageWithConversationTypeKey:ConversationTypeInviteKiss andCovTitle:@"您还可以发起指纹Kiss"];
//        [ChatConversationManager sendLocalCustomMessageWithConversationTypeKey:ConversationTypeInviteDraw andCovTitle:@"或者一起画"];
//    }else {
//        [ChatConversationManager sendLocalCustomMessageWithConversationTypeKey:ConversationTypeLocalInvitePartner andCovTitle:@"尚未绑定您的另一半"];
//    }
//    [UserInfoManager instance].isFirstChat=NO;
//    [[UserInfoManager instance] saveToPlist];
//}

+(void)getUserDataWithMember:(NSArray*)members finish:(void(^)())finishBlock
{
    if (members.count==0) {
        finishBlock();
        return;
    }
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
