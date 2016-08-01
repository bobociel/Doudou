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

- (void)conversationSelectType:(NSInteger)type supplier_id:(NSNumber *)supplier_id hotelDic:(NSDictionary *)hotelDic name:(NSString *)serverName phone:(NSString *)phone avatar:(NSString *)avatar
{
    NSDictionary *dic = @{
                          @"id" : [LWUtil getString:supplier_id andDefaultStr:@""],
                          @"name" : [LWUtil getString:serverName andDefaultStr:@""],
                          @"group_id" : @"3",
                          @"avatar" : [LWUtil getString:avatar andDefaultStr:@""],
                          @"phone" : [LWUtil getString:phone andDefaultStr:@""]
                          };
	[[SQLiteAssister sharedInstance] pushItem:[UserInfo modelWithDictionary:dic]];
    NSString *serverId=[LWUtil getString:supplier_id andDefaultStr:@""];
    if ([serverId isNotEmptyCtg]&&[[UserInfoManager instance].userId_self isNotEmptyCtg]) {
        if (hotelDic) {
            serverId=hotelHunlishiguangId;
        }
        NSMutableArray *ids=[[NSMutableArray alloc] initWithArray:@[[UserInfoManager instance].userId_self,serverId]];
        
        if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
            [ids addObject:[UserInfoManager instance].userId_partner];
        }
        [self showLoadingViewTitle:@"创建会话中"];
        [ChatConversationManager getConversationWithClientIds:ids type:kConversationType_Group withBlock:^(AVIMConversation *conversation, NSError *error,BOOL iscreated) {
            [self hideLoadingView];
            if (error) {
                [WTProgressHUD ShowTextHUD:@"服务器出错" showInView:KEY_WINDOW];
            }
            else
            {
                WTChatDetailViewController *next=[[WTChatDetailViewController alloc]initWithNibName:@"WTChatDetailViewController" bundle:nil];
                if (hotelDic) {
                    NSMutableDictionary *hotelData=[[NSMutableDictionary alloc]initWithDictionary:hotelDic];
                    [hotelData setObject:supplier_id forKey:@"id"];
                    next.hotelData=hotelData;
                }
                next.conversation=conversation;
                next.keyConversation=[conversation keyedConversation];
                next.conversationId=conversation.conversationId;
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
    // Dispose of any resources that can be recreated.
}

@end
