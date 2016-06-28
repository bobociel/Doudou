//
//  NotificationTopView.m
//  weddingTime
//
//  Created by 默默 on 15/9/22.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NotificationTopView.h"
#import "WTChatDetailViewController.h"
#import "WTDrawViewController.h"
#import "WTKissViewController.h"
#import "WeddingPlanDetailViewController.h"
@implementation NotificationTopView
{
    WTNotificationTopViewType notificationTopViewType;
	AVIMMessage *message;
    id notificationTopViewObject;
}
-(instancetype)initWithType:(WTNotificationTopViewType)type message:(AVIMMessage *)aMessage object:(id)object
{
    self=[[NSBundle mainBundle] loadNibNamed:@"NotificationTopView" owner:nil options:nil][0];
    if (self) {
        notificationTopViewType=type;
        notificationTopViewObject=object;
		message = aMessage;
        self.avatarImage.layer.cornerRadius= self.avatarImage.width/2;
        self.waitingChooseLabel.layer.cornerRadius= self.waitingChooseLabel.width/2;
        self.avatarImage.layer.masksToBounds=YES;
        self.waitingChooseLabel.layer.masksToBounds=YES;
        self.userInteractionEnabled=YES;
    }
    return self;
}


-(void)touchIn
{
	UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;

    switch (notificationTopViewType) {
        case WTNotificationTopViewTypeMessage:
        {
			if([message isKindOfClass:[AVIMTypedMessage class]])
			{
				AVIMTypedMessage *msg = (AVIMTypedMessage *)message;
				if([msg.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInviteKiss] && ![nav.topViewController isKindOfClass:[WTKissViewController class]])
				{
					WTKissViewController *kissVc = [[WTKissViewController alloc] init];
					kissVc.isFromJoin=YES;
					[nav pushViewController:kissVc animated:YES];
				}
				else if ([msg.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInviteDraw] && ![nav.topViewController isKindOfClass:[WTDrawViewController class]])
				{
					WTDrawViewController *drawVC = [[WTDrawViewController alloc] initWithNibName:@"WTDrawViewController" bundle:nil];
					drawVC.isFromJoin=YES;
					[nav pushViewController:drawVC animated:YES];
				}
				else if([msg.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInvitePlan])
				{
					WeddingPlanDetailViewController *demandVC = [[WeddingPlanDetailViewController alloc] init];
					demandVC.planId = msg.attributes[ConversationValueKey][@"id"];
					[nav pushViewController:demandVC animated:YES];
				}
				else
				{
					NotificationTopViewChatMeaasgeObject*objectN=notificationTopViewObject;
					[WTChatDetailViewController pushToChatDetailWithConversation:objectN.conversation];
				}
			}
			else
			{
				NotificationTopViewChatMeaasgeObject*objectN=notificationTopViewObject;
				[WTChatDetailViewController pushToChatDetailWithConversation:objectN.conversation];
			}
        } break;
        case WTNotificationTopViewTypeOrder:
        {
            [NotificationTopPush pushToOrderDetailWtihOrder_id:notificationTopViewObject];
        } break;
        case WTNotificationTopViewTypeDemaindReserverSuccess:
        {
            [NotificationTopPush pushToDemaindDetailWithRewardId:notificationTopViewObject];
        } break;
		case WTNotificationTopViewTypeSupplier:
		{
			[NotificationTopPush pushToSupplierWithSupplierID:notificationTopViewObject];
		} break;
		case WTNotificationTopViewTypeHotel:
		{
			[NotificationTopPush pushToHotelWtihHotelId:notificationTopViewObject];
		} break;
		case WTNotificationTopViewTypeTagInspiration:
		{
			[NotificationTopPush pushToInspirationWtihTag:notificationTopViewObject];
		} break;
		case WTNotificationTopViewTypeColorInspiration:
		{
			[NotificationTopPush pushToInspirationWtihColor:notificationTopViewObject];
		} break;
		case WTNotificationTopViewTypePost:
		{
			[NotificationTopPush pushToWorkDetailWtihwork_id:notificationTopViewObject];
		}
		case WTNotificationTopViewTypePlan:
		{
			[NotificationTopPush pushToPlanDetailWtihMatterID:notificationTopViewObject];
		} break ;
		case WTNotificationTopViewTypeTicket:
		{
			[NotificationTopPush pushToTicketDetail:notificationTopViewObject];
		} break ;
        default: break;
    }
}

- (IBAction)touch:(id)sender {
    [self touchIn];
}
@end

@implementation NotificationTopViewChatMeaasgeObject

@end
