//
//  ChatConversationManager.h
//  lovewith
//
//  Created by imqiuhang on 15/4/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "AVOSCloudIM.h"
#import "LWUtil.h"
#import "ConversationStore.h"
//聊天类型(为了识别特殊的聊天类型 如发送表情  画画 kiss 喜欢之类的)
#define ConversationVerson                  1.0
#define ConversationMinAllowVersonKey       @"ConversationMinAllowVersonKey"
#define ConversationTypeKey                 @"ConversationKey"                    //字典的key
#define ConversationValueKey                @"ConversationValueKey"

#define ConversationIsForGameKey            @"ConversationIsForGameKey"

#define ConversationTypeChatWithSupplier    @"ConversationTypeChatWithSupplier"
#define ConversationTypeInviteKiss          @"ConversationTypeInviteKiss"
#define ConversationTypeInviteDraw          @"ConversationTypeInviteDraw"
#define ConversationTypeInvitePlan          @"ConversationTypeInvitePlan"
#define ConversationTypeLike                @"ConversationTypeLike"
#define ConversationTypeSendFaceImage       @"ConversationTypeSendFaceImage"

//弃用
#define ConversationTypeLocalInvitePartner  @"ConversationTypeLocalInvitePartner"

//收到这两条消息在聊天界面是不处理的 是传输游戏中的数据的
#define ConversationTypeKiss                @"ConversationTypeKiss"
#define KissDidGetPatarnerKissInfoNotify @"KissDidGetPatarnerKissInfoNotify"

#define ConversationTypeDraw                @"ConversationTypeDraw"
#define DrawDidGetPatarnerDrawInfoInfoNotify @"DrawDidGetPatarnerDrawInfoInfoNotify"

#define ConversationTypeInviteShareLocation @"ConversationTypeInviteShareLocation"
#define ConversationTypeShareLocation       @"ConversationTypeShareLocation"

#define ConversationTypeCreateDemand      @"ConversationTypeCreateDemand"
#define ConversationTypeCreateOrder       @"ConversationTypeCreateOrder"
static const int errCode_ClientNotOpen           = 98989000;
static const int errCode_findConversationsFalid  = 98989001;
static const int errCode_createConversationFaild = 98989002;

@interface ChatConversationManager : NSObject<AVIMClientDelegate>

+ (void)getConversationWithConversationId:(NSString *)conversationId withBlock:(void (^)(AVIMConversation *, NSError *))block;

+ (void)getConversationWithClientIds:(NSArray *)clientIds type:(int)type withBlock:(void (^)(AVIMConversation *, NSError *,BOOL))block;

+ (void)getConversationWithUserClientId:(NSString *)clientId withBlock:(void (^)(NSArray *array, NSError *))block;

//发送了一条普通文本
+ (void)sendMessage:(NSString *)message conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure;

//发送了一条语音
+ (void)sendVoice:(NSString *)filePath andLenth:(float)lenth  conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure;

//发送图片
+ (void)sendImage:(NSString *)imagePath text:(NSString *)text attributes:(NSDictionary *)attributes conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure;
//
/**
 *  @author imqiuhang, 15-05-28 10:05:23
 *
 *  @brief  发送诸如表情，喜欢，邀请指纹kiss等一系列的自定义消息
 *
 *  @param pushName 通知推送的内容
 *  @param Key      @see macrodefine.h   用于识别的key 在macrodefine.h中事先定义好的
 *  @param value    @see macrodefine.h   一些值  比如喜欢的id 表情的图片等 是字典还是文本什么的自己决定
 *  @param title    用于显示气泡内的文本 如果是表情之类的 那就不需要写
 */
+ (void)sendCustomMessageWithPushName:(NSString *)pushName andConversationTypeKey:(NSString *)Key andConversationValue:(id)value andCovTitle:(NSString *)title conversation:(AVIMConversation*)conversation push:(BOOL)push success:(void(^)())success failure:(void(^)( NSError *error))failure;


//+ (void)sendAVIMessage:(AVIMMessage *)message conversation:(AVIMConversation*)conversation  success:(void(^)(NSArray*partners))success failure:(void(^)( NSError *error))failure;

//发送一个本地的消息 消息只会显示在自己的聊天界面不会发送给对方
//+ (void)sendLocalCustomMessageWithConversationTypeKey:(NSString *)Key  andCovTitle:(NSString *)title;
//
//+ (void)sendFirstMessage;

+(void)getUserDataWithMember:(NSArray*)members finish:(void(^)())finishBlock;

@end
