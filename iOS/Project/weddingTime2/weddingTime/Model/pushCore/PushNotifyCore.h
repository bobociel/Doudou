//
//  PushNotifyCore.h
//  lovewith
//
//  Created by imqiuhang on 15/5/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>

#define pushSendImageToParterContent   @"[图片]"
#define pushSendVoiceToParterContent    @"[语音]"

#define pushInviterPartnerKiss          @"邀请您加入指纹kiss"
#define pushInviterPartnerDraw          @"邀请您加入一起画"

#define pushInviterPartnerShareLocation @"邀请您加入位置共享"
#define pushBindingPartner              @"成功绑定另一半"
#define pushReBindingPartner            @"您的另一半已经和您解除绑定"
#define pushDemaindToPartner            @"您的另一半创建了一个新的需求"
#define pushUpdateUserInfo            @"您的另一半修改了资料"

@class AVIMConversation;
@interface PushNotifyCore : NSObject

+ (void)pushMessageToPartnerWithContent:(NSString *)content partners:(NSArray *)partners conversation:(AVIMConversation*)conversation;

+ (void)pushMessageInviterPartnerKiss;

+ (void)pushMessageInviterPartnerDraw;

@end
