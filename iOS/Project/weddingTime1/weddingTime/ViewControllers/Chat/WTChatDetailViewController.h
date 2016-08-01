//
//  ChatDetailViewController.h
//  weddingTreasure
//
//  Created by 默默 on 15/6/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

typedef NS_ENUM(NSInteger,WTConversationType){
	WTConversationTypePartner, //搭档
	WTConversationTypeSupplier,//服务商
	WTConversationTypeHotel,   //酒店服务商
	WTConversationTypeCustomer //客服
};

#import "BaseViewController.h"

@interface ObjCGPoint :NSObject

@property (nonatomic) float px;
@property (nonatomic) float py;

@end
@class AVIMConversation;
@class AVIMKeyedConversation;

@class UserInfo;
@interface WTChatDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView *xibTableView;
@property (weak, nonatomic) IBOutlet UIButton *sendAskBtn;
@property (weak, nonatomic) IBOutlet UIImageView *topLine;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;

@property(nonatomic,strong)AVIMConversation *conversation;//最好传入
@property(nonatomic,strong)AVIMKeyedConversation *keyConversation;
@property(nonatomic,strong)NSString *conversationId;

@property(nonatomic,strong)NSDictionary *hotelData;
@property (nonatomic,assign) WTConversationType convType;

@property (strong, nonatomic) IBOutlet UIView *sendAskView;
@property (weak, nonatomic) IBOutlet UIImageView *hotelAvatar;
@property (weak, nonatomic) IBOutlet UILabel *hotelName;
- (IBAction)sendAsk:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *avatarView;


+(void)pushToChatDetailWithConversationId:(NSString*)conversationId;

+(void)pushToChatDetailWithKeyConversation:(AVIMKeyedConversation*)keyConversation;

+(void)pushToChatDetailWithConversation:(AVIMConversation*)conversaiton;
@end
