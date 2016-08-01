//
//  PushNotifyCore.m
//  lovewith
//
//  Created by imqiuhang on 15/5/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "PushNotifyCore.h"
#import "AVPush.h"
#import "AVInstallation.h"
#import "UserInfoManager.h"
#import "AVOSCloudIM.h"

#define defaultContent @"您收到一条消息"
@implementation PushNotifyCore

+ (void)pushMessageToPartnerWithContent:(NSString *)content partners:(NSArray *)partners conversation:(AVIMConversation*)conversation
{
    if ([content isNotEmptyCtg]) {
        for (NSString *partner in partners) {
            [self pushMessageToPartnerWithContent:content andJumpRemote:pushRemoteIdContentNormalMessage  partner:partner conversation:conversation];
        }
    }
}

+ (void)pushMessageInviterPartnerDraw {
    [self pushMessageToPartnerWithContent:pushInviterPartnerDraw andJumpRemote:PushRemoteIdDrawWithPartner partner:[UserInfoManager instance].userId_partner conversation:nil];
}

+ (void)pushMessageInviterPartnerKiss {
    [self pushMessageToPartnerWithContent:pushInviterPartnerKiss andJumpRemote:PushRemoteIdKissWithPartner partner:[UserInfoManager instance].userId_partner conversation:nil];
}

+ (void)pushMessageToPartnerWithContent:(NSString *)content andJumpRemote:(NSString *)jumpInfo partner:(NSString*)partner conversation:(AVIMConversation*)conversation{
    if (conversation) {
        //TODO判断是否我们的对话
        if(![[ChatMessageManager instance]ifOurConversation:[conversation keyedConversation]])
        {
            if([partner isEqualToString:[UserInfoManager instance].userId_partner])
            {
                NSDictionary *dic;
                for (NSString *member in conversation.members) {
                    if (![member isEqualToString:[UserInfoManager instance].userId_self]&&![member isEqualToString:[UserInfoManager instance].userId_partner]) {
                        //todo取出用户信息 dic=[UserInfoManager instance].userListDictionary[member];
                        break;
                    }
                }
                NSString *name=@"服务商";
                if (dic) {
                    name=dic[@"name"];
                }
                
                content=[NSString stringWithFormat:@"与%@的会话\n%@:%@",name,[UserInfoManager instance].username_self,content];
			}
		}
		else
		{
			content = [NSString stringWithFormat:@"%@:%@",[UserInfoManager instance].username_self,content];
		}
	}

    NSMutableDictionary *mudata = [[NSMutableDictionary alloc] initWithCapacity:10];
    mudata[@"sound"] = @"default";
    mudata[@"alert"] = [content isNotEmptyCtg]?content:defaultContent;
    mudata[@"badge"] = @"Increment";
    if (jumpInfo) {
        mudata[PushRemoteIdJumpKey] = jumpInfo;
    }
    if(conversation)
        mudata[PushRemoteIdConversationId] = conversation.conversationId;
    
    AVQuery *pushQuery = [AVInstallation query];
    [pushQuery whereKey:@"channels" equalTo:partner];
    AVPush *push = [[AVPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:[mudata copy]];
    [push sendPushInBackground];
}
@end
