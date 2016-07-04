//
//  ChatListCell.h
//  weddingTime
//
//  Created by 默默 on 15/9/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
static NSString*const WTNotficationCellCheckUnreadNum=@"WTNotficationCellCheckUnreadNum";
static NSString*const cellidentifier_bind=@"BindCell";
static NSString*const cellidentifier_listcell=@"ChatListCell";
@class UserInfo;
@interface ChatListCell : UITableViewCell
{
    NSString *contentText;
    AVIMMessage*message;
}
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;

- (void)setOneOneInfo:(id)info partner:(NSString*)partner;
- (void)setGroupInfo:(id)info members:(NSArray*)members andConversation:(AVIMKeyedConversation *)conv;
+ (CGFloat)getHeight;
+ (UserInfo*)getSupplierWithConversation:(AVIMKeyedConversation *)conv;
+ (NSString*)getContentWithWithKeyedConversation:(AVIMKeyedConversation *)keyedConv andMessage:(AVIMMessage*)message;
@end

@interface UITableView(ChatListCell)

- (ChatListCell *) ChatListCellWithCellIdentifier:(NSString*)cellIdentifier;

@end