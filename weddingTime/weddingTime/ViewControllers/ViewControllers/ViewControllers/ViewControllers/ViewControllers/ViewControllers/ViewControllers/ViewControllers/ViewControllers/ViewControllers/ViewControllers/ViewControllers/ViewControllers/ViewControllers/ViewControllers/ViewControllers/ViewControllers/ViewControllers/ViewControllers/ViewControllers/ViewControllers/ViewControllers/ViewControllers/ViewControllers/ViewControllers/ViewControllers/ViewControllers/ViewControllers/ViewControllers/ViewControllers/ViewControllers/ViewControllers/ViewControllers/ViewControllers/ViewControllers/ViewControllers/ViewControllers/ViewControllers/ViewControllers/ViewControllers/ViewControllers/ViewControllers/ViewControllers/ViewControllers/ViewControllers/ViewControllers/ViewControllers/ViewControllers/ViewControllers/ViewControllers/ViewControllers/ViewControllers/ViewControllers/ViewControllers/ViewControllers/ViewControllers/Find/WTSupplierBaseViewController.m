//
//  SupplierBaseViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSupplierBaseViewController.h"
#import "WTLocalDataManager.h"
@interface WTSupplierBaseViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WTSupplierBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)conversationSelectType:(WTConversationType)type
				   supplier_id:(NSString *)supplier_id
				 sendToAskData:(id)sendToAskData
						  name:(NSString *)serverName
						 phone:(NSString *)phone
						avatar:(NSString *)avatar
{
    NSDictionary *dic = @{@"id" : [LWUtil getString:supplier_id andDefaultStr:@""],
                          @"name" : [LWUtil getString:serverName andDefaultStr:@""],
                          @"group_id" : @"3",
                          @"avatar" : [LWUtil getString:avatar andDefaultStr:@""],
                          @"phone" : [LWUtil getString:phone andDefaultStr:@""]};

	[[SQLiteAssister sharedInstance] pushItem:[UserInfo modelWithDictionary:dic]];
    NSString *serverId = [LWUtil getString:supplier_id andDefaultStr:@""];
    if ([serverId isNotEmptyCtg] && [[UserInfoManager instance].userId_self isNotEmptyCtg])
	{
		NSMutableArray *ids = [NSMutableArray array];
		[ids addObject:[UserInfoManager instance].userId_self];
		if(type == WTConversationTypeSupplier || type == WTConversationTypePost )
		{
			[ids addObject:serverId];
			if(![ids containsObject:kServerID]) { [ids addObject:kServerID]; }
		}
		else if (type == WTConversationTypeHotelOrCustomer)
		{
			NSDictionary *serverDic = @{@"id":kServerID,@"name":kServerName,@"group_id":@"3",@"avatar":kServerAvatar,@"phone":kServerPhone};
			[[SQLiteAssister sharedInstance] pushItem:[UserInfo modelWithDictionary:serverDic]];
			if(![ids containsObject:kServerID]) { [ids addObject:kServerID]; }
		}

        if ([[UserInfoManager instance].userId_partner isNotEmptyCtg])
		{
            [ids addObject:[UserInfoManager instance].userId_partner];
        }

        [self showLoadingViewTitle:@"创建会话中"];
        [ChatConversationManager getConversationWithClientIds:ids type:type withBlock:^(AVIMConversation *conversation, NSError *error){
            [self hideLoadingView];
            if (error) {
				[WTProgressHUD ShowTextHUD:IFDEBUG ? error.localizedDescription:@"服务器出错" showInView:KEY_WINDOW];
            }
            else
            {
				WTChatDetailViewController *next = [[WTChatDetailViewController alloc] init];
                if (sendToAskData && [sendToAskData isKindOfClass:[NSDictionary class]]){
					NSMutableDictionary *sendData = [NSMutableDictionary dictionary];
					[sendData setObject:type == WTConversationTypePost ? sendToAskData[@"post_id"] : serverId forKey:@"id"];
					[sendData setObject:type == WTConversationTypeHotelOrCustomer ? @"h" : (type == WTConversationTypeSupplier) ? @"s" : @"p" forKey:@"type"];
					[sendData setObject:serverName forKey:@"name"];
					[sendData setObject:type == WTConversationTypePost ? sendToAskData[@"post_avatar"] : avatar forKey:@"avatar"];
                    next.sendToAskData = sendData;
                }
				else if([sendToAskData isKindOfClass:[NSString class]]){
					[ChatConversationManager sendMessage:sendToAskData conversation:conversation push:YES success:^{ } failure:^(NSError *error) { }];
				}
                next.conversation = conversation;
                next.keyConversation = [conversation keyedConversation];
                next.conversationId = conversation.conversationId;
                [self.navigationController pushViewController:next animated:YES];
            }
        }];
    }
    else
    {
        [WTProgressHUD ShowTextHUD:@"服务器出错，请重新获取商家信息" showInView:KEY_WINDOW];
    }
}

- (UIView *)getFootView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60 * Height_ato)];
    view.backgroundColor = WHITE;
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
