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
#import "WTLocalDataManager.h"
#import "UIImageView+WebCache.h"
#import "ChatConversationManager.h"
#import "WTChatDetailViewController.h"
#import "KYCuteView.h"
#import "ChatMessageManager.h"
@implementation UITableView(ChatListCell)

- (ChatListCell *)ChatListCellWithCellIdentifier:(NSString*)cellIdentifier{
    
    //  static NSString *CellIdentifier = @"ChatListCell";
    //BindCell
    ChatListCell * cell = (ChatListCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (ChatListCell *)[self dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    cell.selectedBackgroundView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    self.avatar.layer.cornerRadius=self.avatar.width/2;
    self.lineHeight.constant=0.5;
    [LWAssistUtil imageViewSetAsLineView:self.lineImage color:rgba(255, 255, 255, 0.9)];
    self.avatar.layer.borderColor=[UIColor whiteColor].CGColor;
    self.avatar.layer.borderWidth=2;
    self.avatar.layer.masksToBounds=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkUnreadNum) name:WTNotficationCellCheckUnreadNum object:nil];
}

- (void)setOneOneInfo:(id)info partner:(NSString*)partner{
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
    
    if(info)
    {
        message=((Message*)info).imMessage;
    }
    else
    {
        message=nil;
    }
    [self setSubTitleText];
}

+(UserInfo*)getSupplierWithMembers:(NSArray*)members
{
    UserInfo * result;
    NSString *myId=[UserInfoManager instance].userId_self;
    for (NSString *user in members) {//获取商家的dic
        if (![user isEqualToString:myId]&&![user isEqualToString:[UserInfoManager instance].userId_partner]) {
            UserInfo *userdic = [[SQLiteAssister sharedInstance] pullUserInfo:user];
            if (userdic&&[userdic.group_id longLongValue]==3) {
                result=userdic;
                break;
            }
        }
    }
    return result;
}

- (void)setGroupInfo:(id)info members:(NSArray*)members{
    if(info)
    {
        message=((Message*)info).imMessage;
    }
    else
    {
        message=nil;
    }
    userDicSupplier=[ChatListCell getSupplierWithMembers:members];
    
    NSString *nickNmae=@"商家";
    nickNmae=[LWUtil getString:userDicSupplier.name andDefaultStr:@"商家"];
    if([userDicSupplier.ID isEqualToString:hotelHunlishiguangId])
    {
        nickNmae=hotelHunlishiguangName;
    }
    
    NSString *avatarUrl=[LWUtil getString:userDicSupplier.avatar andDefaultStr:@""];
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[WeddingTimeAppInfoManager avatarPlcehold] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    self.avatar.layer.cornerRadius=self.avatar.bounds.size.width/2;
    self.avatar.layer.masksToBounds=YES;
    
    self.mainTitle.text=nickNmae;
    
    [self setSubTitleText];
    [self checkUnreadNum];
}

+(NSString*)getContentWithMessage:(AVIMMessage*)message
{
    if (!message) {
        return @"开始聊天吧";
    }
    NSString *result;
    NSString *myId=[UserInfoManager instance].userId_self;
    NSString *partnerId=[UserInfoManager instance].userId_partner;
    
    result=@"";
    
    NSString *sendUserId=message.clientId;
    UserInfo *userDicSend;
    if (sendUserId) {
        userDicSend = [[SQLiteAssister sharedInstance] pullUserInfo:sendUserId];
    }
    
    if (![myId isEqualToString:sendUserId]) {
        if ([sendUserId isEqualToString:hotelHunlishiguangId]) {
            result=[NSString stringWithFormat:@"%@:",hotelHunlishiguangName];
        }
        else
        {
            if (userDicSend) {
                result=[NSString stringWithFormat:@"%@:",userDicSend.name];
            }
            else if([userDicSend.ID isEqualToString:partnerId])
            {
                result=[NSString stringWithFormat:@"%@:",[UserInfoManager instance].username_partner];
            }
            else
            {
                result=@"";
            }
        }
    }
    NSString*typeContent;
    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
        AVIMTypedMessage *typedMessage=(AVIMTypedMessage*)message;
        switch (typedMessage.mediaType) {
            case kAVIMMessageMediaTypeNone:
                typeContent=@"未能识别的类型";
                break;
            case kAVIMMessageMediaTypeText:
                typeContent=typedMessage.content;
                if (!typedMessage.attributes) {
                    typeContent=typedMessage.text;
                }else {
                    //发送表情的时候 直接在附件里面发的是f1 f2这样的标志 而不是发一张图片 这样发送更快 所以接收的时候需要在这里单独处理
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
                
            default:
                break;
        }
    }
    else
    {
        typeContent=message.content;
    }
    result=[NSString stringWithFormat:@"%@%@",result,typeContent];
    return result;
}

-(void)setSubTitleText
{
    self.subTitle.text=[ChatListCell getContentWithMessage:message];
    [self checkUnreadNum];
}

-(void)checkUnreadNum
{
    int num=[[ConversationStore sharedInstance]conversationUnreadCount:message.conversationId];
    //  int num=555;
    if (num!=0) {
        if (!unreadNumView) {
            unreadNumView=[[KYCuteView alloc]initWithPoint:CGPointMake(38, 61) superView:self.contentView];
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
