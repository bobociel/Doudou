//
//  ChatListCell.m
//  weddingTime
//
//  Created by 默默 on 15/9/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ChatListCell.h"
#import "Message.h"
#import "UserInfoManager.h"
#import "UIImageView+WebCache.h"
#import "ChatConversationManager.h"
#import "WTChatDetailViewController.h"
#import "KYCuteView.h"
#import "ChatMessageManager.h"
@implementation UITableView(ChatListCell)

- (ChatListCell *)ChatListCellWithCellIdentifier:(NSString*)cellIdentifier{

    ChatListCell * cell = (ChatListCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (ChatListCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
    }
	cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    return cell;
}
@end
@interface ChatListCell ()<KYCuteViewDelegate>
@end

@implementation ChatListCell
{
    UserInfo *userDicSupplier;
    KYCuteView *unreadNumView;
}

-(void)awakeFromNib
{
    self.avatar.layer.cornerRadius=self.avatar.width/2;
    [LWAssistUtil imageViewSetAsLineView:self.lineImage color:rgba(255, 255, 255, 0.9)];
    self.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatar.layer.borderWidth = 3;
    self.avatar.layer.masksToBounds=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkUnreadNum) name:WTNotficationCellCheckUnreadNum object:nil];
}

- (void)setOneOneInfo:(id)info partner:(NSString*)partner
{
    UserInfo *userdic = [[SQLiteAssister sharedInstance] pullUserInfo:partner];
    userDicSupplier=userdic;
    NSString *avatar=userDicSupplier.avatar;
    NSString *name=userDicSupplier.name;
    if (!userDicSupplier&&[partner isEqualToString:[UserInfoManager instance].userId_partner]) {
        avatar=[UserInfoManager instance].avatar_partner;
        name=[UserInfoManager instance].username_partner;
    }
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[WeddingTimeAppInfoManager avatarPlcehold] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    self.mainTitle.text=name;
	message = info ? ((Message*)info).imMessage : nil;
    [self setSubTitleTextWithConversation:[ChatMessageManager instance].keyedConversationOur];
}

- (void)setGroupInfo:(id)info members:(NSArray*)members andConversation:(AVIMKeyedConversation *)conv
{
	message= info ? ((Message*)info).imMessage : nil;
	userDicSupplier=[ChatListCell getSupplierWithConversation:conv];

	NSString *nickNmae=@"商家";
	nickNmae = [LWUtil getString:userDicSupplier.name andDefaultStr:@"商家"];
	nickNmae = [userDicSupplier.ID isEqualToString:kServerID] ? kServerName : nickNmae ;

	NSString *avatarUrl = [LWUtil getString:userDicSupplier.avatar andDefaultStr:@""];
	[self.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
				   placeholderImage:[WeddingTimeAppInfoManager avatarPlcehold]
						  completed:nil];

	self.avatar.layer.cornerRadius=self.avatar.bounds.size.width/2;
	self.avatar.layer.masksToBounds=YES;

	self.mainTitle.text=nickNmae;

	[self setSubTitleTextWithConversation:conv];
	[self checkUnreadNum];
}

+ (UserInfo*)getSupplierWithConversation:(AVIMKeyedConversation *)conv
{
	WTConversationType type = [conv.attributes[@"type"] integerValue];
    NSString *myId = [UserInfoManager instance].userId_self;
	NSString *partnerId = [UserInfoManager instance].userId_partner;
	if(type == WTConversationTypeHotelOrCustomer)
	{
		return [[SQLiteAssister sharedInstance] pullUserInfo:kServerID];
	}
	else if( type == WTConversationTypeSupplier || type == WTConversationTypePost)
	{
		for (NSString *userId in conv.members) {
			if(![userId isEqualToString:myId] && ![userId isEqualToString:partnerId] && ![userId isEqualToString:kServerID])
			{
				return [[SQLiteAssister sharedInstance] pullUserInfo:userId];
			}
		}
	}

    return [[SQLiteAssister sharedInstance] pullUserInfo:@""];
}

+ (UserInfo*)getSendUserWithConversation:(AVIMKeyedConversation *)conv andMessage:(AVIMMessage *)message
{
	WTConversationType type = [conv.attributes[@"type"] integerValue];
	UserInfo *user = [[SQLiteAssister sharedInstance] pullUserInfo:message.clientId];
	if( [user.ID isEqualToString:kServerID]
	   && (type == WTConversationTypeSupplier || type == WTConversationTypePost ) )
	{
		user = [ChatListCell getSupplierWithConversation:conv];
	}

	return user ;
}

+ (NSString*)getContentWithWithKeyedConversation:(AVIMKeyedConversation *)keyedConv andMessage:(AVIMMessage*)message
{
    if (!message) { return @"开始聊天吧"; }

	UserInfo *userDicSend = [self getSendUserWithConversation:keyedConv andMessage:message];
	NSString *result = userDicSend ? [NSString stringWithFormat:@"%@:",userDicSend.name]: @"";

    NSString*typeContent;
    if ([message isKindOfClass:[AVIMTypedMessage class]])
	{
        AVIMTypedMessage *typedMessage=(AVIMTypedMessage*)message;
		typeContent = typedMessage.content;
        switch (typedMessage.mediaType)
		{
            case kAVIMMessageMediaTypeNone:
                typeContent=@"未能识别的类型";
                break;
            case kAVIMMessageMediaTypeText:
                if (!typedMessage.attributes)
				{
                    typeContent=typedMessage.text;
                }
				else
				{
                    if ([((AVIMTypedMessage*)message).attributes[ConversationTypeKey] isEqualToString:ConversationTypeSendFaceImage]) {
                        typeContent=@"[表情]";
                    }else {
                        typeContent=[LWUtil getString:typedMessage.text andDefaultStr:@""];
                    }
                }
                break;
            case kAVIMMessageMediaTypeImage:
                typeContent=@"[图片]";
                break;
            case kAVIMMessageMediaTypeAudio:
                typeContent=@"[语音]";
                break;
            case kAVIMMessageMediaTypeVideo:
                typeContent=@"[小视频]";
                break;
            case kAVIMMessageMediaTypeLocation:
                typeContent=@"[位置]";
                break;

            default: break;
        }
    }
    else
    {
        typeContent = message.content;
    }
    result=[NSString stringWithFormat:@"%@%@",result,typeContent];

    return result;
}

-(void)setSubTitleTextWithConversation:(AVIMKeyedConversation *)conv
{
    self.subTitle.text=[ChatListCell getContentWithWithKeyedConversation:conv andMessage:message];
    [self checkUnreadNum];
}

-(void)checkUnreadNum
{
    int num=[[ConversationStore sharedInstance]conversationUnreadCount:message.conversationId];
    //  int num=555;
    if (num!=0) {
        if (!unreadNumView) {
            unreadNumView=[[KYCuteView alloc] initWithPoint:CGPointMake(38, 61) superView:self.contentView];
            unreadNumView.viscosity  = 20;
            unreadNumView.delegate=self;
            unreadNumView.bubbleWidth=22;
            unreadNumView.bubbleColor=[WeddingTimeAppInfoManager instance].baseColor;
        }
        unreadNumView.frontView.hidden=NO;
        NSString *numString;
        if (num>99) {
            numString=@"99+";
        }
        else
        {
            numString=[NSString stringWithFormat:@"%d",num];
        }
        [unreadNumView setUp];
        unreadNumView.bubbleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
        unreadNumView.bubbleLabel.text=numString;
        [unreadNumView.bubbleLabel sizeToFit];
        unreadNumView.bubbleLabel.height=22;
        unreadNumView.bubbleLabel.width+=8;
        unreadNumView.bubbleLabel.backgroundColor=[WeddingTimeAppInfoManager instance].baseColor;
        unreadNumView.bubbleLabel.layer.cornerRadius=11;
        unreadNumView.bubbleLabel.layer.masksToBounds=YES;
        if (unreadNumView.bubbleLabel.width<unreadNumView.bubbleLabel.height) {
            unreadNumView.bubbleLabel.width=unreadNumView.bubbleLabel.height;
        }
        unreadNumView.bubbleLabel.center=CGPointMake(11, 11);
    }
    else
    {
        if (unreadNumView) {
            unreadNumView.frontView.hidden=YES;
        }
    }
}

-(void)clear
{
    [ChatMessageManager clearUnreadMsgCount:message.conversationId];
}

+ (CGFloat)getHeight {
    return 98;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

@end
