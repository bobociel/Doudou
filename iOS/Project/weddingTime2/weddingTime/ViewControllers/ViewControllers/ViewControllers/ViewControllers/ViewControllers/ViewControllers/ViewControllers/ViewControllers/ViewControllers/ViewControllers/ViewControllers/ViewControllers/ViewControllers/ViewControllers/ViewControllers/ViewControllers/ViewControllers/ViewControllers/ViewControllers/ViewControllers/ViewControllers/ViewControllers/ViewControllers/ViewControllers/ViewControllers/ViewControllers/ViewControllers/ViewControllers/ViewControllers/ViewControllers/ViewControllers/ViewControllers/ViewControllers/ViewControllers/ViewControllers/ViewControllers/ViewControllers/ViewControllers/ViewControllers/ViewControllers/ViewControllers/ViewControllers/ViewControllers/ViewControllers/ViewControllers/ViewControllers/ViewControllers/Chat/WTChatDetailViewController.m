//
//  ChatDetailViewController.m
//  weddingTreasure
//
//  Created by 默默 on 15/6/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTChatDetailViewController.h"
#import "MessageCell.h"
#import "ChatInputView.h"
#import "PhotoBroswerVC.h"
#import "UIImageView+WebCache.h"
#import "ChatListCell.h"
#import "SendAskView.h"
#define showTalkTimeBefore  3*60 //间隔超过多少则显示时间(秒)
#define historyMessageCount 15
#define avatarPadding       -6
#define avatarPaddingBorder 10
#define avatarWidth         37
#define kInputBarHeight     50.0
#define kAskViewBGHeight    100.0
#define kAskViewHeight      80.0
#define kAskViewLeft        12.0
@implementation ObjCGPoint

@end

@interface WTChatDetailViewController ()
<
    UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,
    ChatInputViewDelegate,MessageCellDelegate,IMEventObserver,ChatMessageManagerDelegate
>
{
	ChatInputView *inputView;
	SendAskView *askView;

    BOOL isLoadingMore;
    BOOL haveMore;
	
    BOOL isSendToAsk;

	BOOL ifOur;
	UserInfo *partnerUserInfo;
	NSString *partnerId;
    NSMutableArray *imageUrlArray;
    NSMutableArray *avatarArray;
    NSMutableArray *avatarMembersArray;
	NSMutableArray *messages;
}
@end

@implementation WTChatDetailViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	messages = [[NSMutableArray alloc] initWithCapacity:100];
	imageUrlArray = [[NSMutableArray alloc]init];
	[self initView];
	[self initPartnerUserInfo];
	[self initInputView];
	[self setNav];
	
	[self startConversationWithPartner];
	[self getHistoryCoversation];
	[ChatMessageManager clearUnreadMsgCount:self.conversationId];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self setNavWithClearColor];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
	[WeddingTimeAppInfoManager instance].curid_conversation = self.conversationId;
	[[ConversationStore sharedInstance] addConversation:self.conversation];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[inputView tapBackGround];
	[WeddingTimeAppInfoManager instance].curid_conversation = nil;
}

- (void)dealloc
{
	[[ChatMessageManager instance] removeObserver:self forName:listUpdateObserver];
	[[ConversationStore sharedInstance] removeEventObserver:self forConversation:self.conversationId];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UserDidRebindSucceedNotify object:nil];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)setNav
{	
	self.avatarView = [[UIView alloc] init];
    self.navigationItem.titleView = self.avatarView;

    NSMutableArray *items=[[NSMutableArray alloc] initWithCapacity:2];
    
    if([partnerId isNotEmptyCtg]&&![partnerId isEqualToString:kServerID]&&!ifOur)
    {
        UIBarButtonItem* homeItem=[self setRightBtnWithImage:[UIImage imageNamed:@"talk_gosupplierhome"] action:@selector(goHome)];
        [items addObject:homeItem];
    }
    if (!ifOur) {
        UIBarButtonItem* callItem=[self setRightBtnWithImage:[UIImage imageNamed:@"call_custum"] action:@selector(call)];
        [items addObject:callItem];
    }
    self.navigationItem.rightBarButtonItems=items;
}

-(void)goHome
{
    if(![partnerId isNotEmptyCtg])
    {
        [WTProgressHUD ShowTextHUD:@"用户数据错误" showInView:KEY_WINDOW];
        return;
    }
    [LWAssistUtil goSupplierHome:partnerId rootNav:self];
}

- (UIBarButtonItem*)setRightBtnWithImage:(UIImage *)aImage action:(SEL)action
{
    UIButton * rightNavBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
    rightNavBtn.size =aImage.size;
    [rightNavBtn setImage:aImage forState:UIControlStateNormal ];
    [rightNavBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightNavBtnItem=[[UIBarButtonItem alloc] initWithCustomView:rightNavBtn];
    
    return rightNavBtnItem;
}

-(void)initPartnerUserInfo
{
    if (!self.keyConversation) { return; }
    
    ifOur=[[ChatMessageManager instance] ifOurConversation:self.keyConversation];
    if (ifOur) {//todo如果是我和另一半的会话，需要监听解除通知
        [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(back) name:UserDidRebindSucceedNotify object:nil];
        for (NSString *memberId in self.keyConversation.members) {
            NSString *userId=memberId;
            if ([userId isEqualToString:[UserInfoManager instance].userId_partner]) {
                UserInfo *user =  [[SQLiteAssister sharedInstance] pullUserInfo:memberId];
                if (user) {
                    partnerUserInfo=user;
                    partnerId=userId;
                }
                break;
            }
        }
    }
    else //非我和另一半会话
    {
		//和前任的会话
		WTConversationType type = [self.keyConversation.attributes[@"type"] intValue];
        if (type == WTConversationTypePartner)
        {
			for (NSString *memberId in self.keyConversation.members) {
                NSString *userId=memberId;
                if (![userId isEqualToString:[UserInfoManager instance].userId_self]) {
					UserInfo *user = [[SQLiteAssister sharedInstance] pullUserInfo:memberId];
					if (user)
					{
                        partnerUserInfo = user;
                        partnerId = userId;
                    }
                    break;
                }
            }
        }
        else
        {
            partnerUserInfo = [ChatListCell getSupplierWithConversation:self.keyConversation];
            if (partnerUserInfo) {
                partnerId = partnerUserInfo.ID;
            }
        }
    }
}

#pragma mark  init
-(void)initView
{
    [self showBlurBackgroundView];

	self.dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, screenWidth, screenHeight - kNavBarHeight - ChatInputViewHeigh)];
	self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.dataTableView.backgroundColor = [UIColor clearColor];
	self.dataTableView.delegate = self;
	self.dataTableView.dataSource = self;
	[self.view addSubview:self.dataTableView];

    isLoadingMore=NO;
    haveMore=NO;
    askView = [[SendAskView alloc] initWithFrame:CGRectMake(kAskViewLeft, screenHeight - kInputBarHeight - kAskViewBGHeight, screenWidth - 2 * kAskViewLeft, kAskViewHeight)];
    askView.hidden = YES;
    [self.view addSubview:askView];
    if (self.sendToAskData ) {
		NSString *name = self.sendToAskData[@"name"];
		NSString *avatar = self.sendToAskData[@"avatar"] ;
        askView.name.text = [LWUtil getString:name andDefaultStr:@"未知商家"];
		[askView.avatar sd_setImageWithURL:[NSURL URLWithString:[LWUtil getString:avatar andDefaultStr:@""]]
						  placeholderImage:[UIImage imageNamed :@"placelolder_detail"]
								 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
		{
            isSendToAsk = YES;
            askView.hidden = NO;
			[self.dataTableView reloadData];
        }];
        [askView.sendButton addTarget:self action:@selector(sendAsk:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)initInputView
{
    if (inputView) {
        [inputView removeFromSuperview];
        inputView=nil;
    }
    __weak typeof(self) weakSelf = self;
    inputView = [[ChatInputView alloc] initWithWeakViewController:weakSelf withHomeMenuOpenButtonExpandView:ifOur];
    [self.view addSubview:inputView];
}

#pragma mark 重写父类函数
- (void)loadMore {
    if (isLoadingMore||!haveMore) {
        return;
    }
    isLoadingMore=YES;
    Message *message = [messages firstObject];
    [self loadWithMessage:message];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        return;
    }
}

#pragma mark 开启聊天
//在收到开启聊天引擎成功后开始创建或者接收一个和同伴聊天的聊天室
- (void)startConversationWithPartner {
    if(![ConversationStore sharedInstance].imClient) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [inputView chatStatusSetWithStatus:ChatErrorStatusLoadConversation];
    if(self.conversation)
        [weakSelf doFinishStartConversationWithConversation:self.conversation];
    else
    {
        [ChatConversationManager getConversationWithConversationId:self.conversationId withBlock:^(AVIMConversation *resultConversation, NSError *error) {
            [weakSelf doFinishStartConversationWithPartner:error :resultConversation];
        }];
    }
}

#pragma mark - IMEventObserver
//新消息到达
- (void)newMessageArrived:(Message*)message conversation:(AVIMConversation*)conv {
    [self dealNewMsg:message conversation:conv];
    [ChatMessageManager clearUnreadMsgCount:self.conversationId];
}

-(void)dealNewMsg:(Message *)message conversation:(AVIMConversation *)conversation
{
    if (message.eventType != CommonMessage) {
    } else {
        ConversationStore *store = [ConversationStore sharedInstance];
        
        [store queryMoreMessages:self.conversation.conversationId from:nil timestamp:[[NSDate date] timeIntervalSince1970]*1000 limit:2 callback:^(NSArray *objects, NSError *error) {
            if (objects.count <= 1) {
                if(!ifOur)
                    [self sendFirstMsg];
            }
        }];
        
        __weak typeof(self) weakSelf = self;
        [messages addObject:message];
        [weakSelf.dataTableView reloadData];
        if (weakSelf.dataTableView.contentSize.height >= weakSelf.dataTableView.height) {
            [weakSelf.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)newMessageSend:(Message *)message conversation:(AVIMConversation *)conversation {
    [self dealNewMsg:message conversation:conversation];
    [ChatMessageManager clearUnreadMsgCount:self.conversationId];
    if (![partnerId isNotEmptyCtg]) {
        return;
    }
    if (![[WeddingTimeAppInfoManager instance].supplierOnlineStatus.allKeys containsObject:partnerId]&&!ifOur) {
        [ChatMessageManager checkOnlineForId:partnerId block:^(BOOL online) {
            [[WeddingTimeAppInfoManager instance].supplierOnlineStatus setObject:@(online) forKey:partnerId];
            if (!online) {
                [PostDataService postSendOnlineStatusMsg:self.conversationId unread:[[ConversationStore sharedInstance]conversationUnreadCount:self.conversationId] uid:[UserInfoManager instance].userId_self uname:[UserInfoManager instance].username_self suid:partnerId suname:partnerUserInfo.name WithBlock:^(NSDictionary *result, NSError *error) {
                    
                }];
            }
        }];
    }
}

//对方收到消息
- (void)messageDelivered:(Message*)message conversation:(AVIMConversation*)conversation {
    
}

#pragma mark -  UITableViewDelegate
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isSendToAsk)
    {
        if (self.dataTableView.contentSize.height > (screenHeight - kNavBarHeight - kInputBarHeight)) {
            [askView removeFromSuperview];
            UIView *view = [UIView new];
            [view addSubview:askView];
            askView.top = 0;
            askView.left = kAskViewLeft;
            
            return view;
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isSendToAsk)
    {
        if (self.dataTableView.contentSize.height > (screenHeight - kNavBarHeight - kInputBarHeight)) {
            return kAskViewBGHeight;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    MessageFrame *frame = [[MessageFrame alloc] init];
    frame.showTime=[self needShowTime:indexPath.row];

	Message *messgae = (Message*)messages[indexPath.row];
	//客服使用商家信息和用户聊天
	cell.orSupplierID = [messgae.imMessage.clientId isEqualToString:kServerID] ? partnerId : nil ;
    [frame setMessage:messgae];
    [cell setMessageFrame:frame];
    cell.alpha=0;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageFrame *frame = [[MessageFrame alloc] init];
    frame.showTime=[self needShowTime:indexPath.row];
    [frame setMessage:((Message*)messages[indexPath.row])];

    return frame.cellHeight;
}

- (BOOL)needShowTime:(NSInteger )row {
    if (row==0) {
        return YES;
    }else {
        Message *beforem = messages[row-1];
        Message *nowm = messages[row];
        if ((nowm.sentTimestamp-beforem.sentTimestamp)/1000>showTalkTimeBefore) {
            return YES;
        }
    }
    return NO;
}

#pragma mark inputdelegate
-(void)reGetConversation
{
    [self startConversationWithPartner];
}

-(void)tableviewAdjustWithkeyboardNotification:(float)Y animation:(NSTimeInterval)animationTime
{
	//原tableview高度
    float originTableViewH= screenHeight- kNavBarHeight - ChatInputViewHeigh;
    
    CGRect rect = self.dataTableView.frame;
    rect.size.height = Y - kNavBarHeight;
    
    CGPoint contentOffset= self.dataTableView.contentOffset;
    if (originTableViewH< self.dataTableView.contentSize.height) {//如果contentsize大于frame
        float deltay=self.dataTableView.frame.size.height-rect.size.height;//需要增加的偏移
        contentOffset.y+=deltay;//直接进行位移
    }
    else
    {
        float offy = self.dataTableView.contentSize.height-rect.size.height;
        offy = offy > 0 ? offy : 0;
        contentOffset=CGPointMake(0, offy);
    }
    [UIView animateWithDuration:animationTime animations:^{
        self.dataTableView.frame=rect;
        self.dataTableView.contentOffset=contentOffset;
    }];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y<=20) {
        [self loadMore];
    }
}

#pragma mark action
- (void)sendAsk:(UIButton *)sender {
    if(!self.sendToAskData) return;

	NSString *title =[NSString stringWithFormat:@"我要咨询%@",self.sendToAskData[@"name"] ];
	NSDictionary *chatInfoDict = @{@"id":self.sendToAskData[@"id"],@"type":self.sendToAskData[@"type"],@"title":title};

    isSendToAsk=NO;
    [UIView animateWithDuration:0.5 animations:^{
        askView.alpha = 0;
    } completion:^(BOOL finished) {
        askView.hidden = YES;
    }];
 
    [ChatConversationManager sendCustomMessageWithPushName:title
									andConversationTypeKey:ConversationTypeChat
									  andConversationValue:chatInfoDict
											   andCovTitle:title
											  conversation:self.conversation
													  push:YES
												   success:^{
    } failure:^(NSError *error) {
        isSendToAsk = YES;
    }];
}

#pragma mark MessageCellDelegate
-(void)clickShowListImageWithUrl:(NSString *)url imageView:(UIImageView *)imageview
{
    if (![imageUrlArray containsObject:url]) {
        [imageUrlArray addObject:url];
    }
    int index=(int)[imageUrlArray indexOfObject:url];
    [self networkImageShow:index sourceImageView:imageview];
}

#pragma mark 功能函数
//开始聊天
-(void)beginChat:(AVIMConversation *)resultConversation
{
    [inputView chatStatusSetWithStatus:ChatErrorStatusSucceed];
    self.conversation = resultConversation;
    
    ConversationStore *store = [ConversationStore sharedInstance];
    [store addEventObserver:self forConversation:self.conversation.conversationId];
    [store addConversation:resultConversation];
    self.keyConversation=[resultConversation keyedConversation];
    
    [self initPartnerUserInfo];
    [self initInputView];
    inputView.conversation=resultConversation;
    [self setNav];
    
    [self avatarViewChangeWithAddView:[self createViewWithMember:self.conversation.members] removeView:nil blackView:nil lightView:nil];
    
    [store saveConversations];
}

- (void)call
{
	if(![partnerId isNotEmptyCtg])
	{
		[WTProgressHUD ShowTextHUD:@"用户数据错误" showInView:KEY_WINDOW];
		return;
	}

	if (![partnerUserInfo.phone isNotEmptyCtg]||!partnerUserInfo) {
		partnerUserInfo = [[SQLiteAssister sharedInstance] pullUserInfo:partnerId];
	}
	if (!partnerUserInfo) {
		[WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
		return;
	}

	if (![partnerUserInfo.phone isNotEmptyCtg])
	{
		[WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
		return;
	}

	NSString *phoneNum = partnerUserInfo.phone;

    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNum];
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]])
	{
        [WTProgressHUD ShowTextHUD:@"号码无效" showInView:KEY_WINDOW];
    }
}


UIImageView *imagev;
-(void)networkImageShow:(NSUInteger)index sourceImageView:(UIImageView *)imageview{
    [PhotoBroswerVC show:self needFav:NO type:PhotoBroswerVCTypeZoom index:index photoModelBlock:^NSArray *{
        NSMutableArray *networkImages=imageUrlArray;
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:networkImages.count];
        for (NSUInteger i = 0; i< networkImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i+12;
            pbModel.title = @"";
            pbModel.desc = @"";
            pbModel.image_HD_U = networkImages[i];
            if (index==i) {
                pbModel.sourceImageView=imageview;
            }
            else
            {
                if (!imagev) {
                    imagev=[UIImageView new];
					imagev.frame = CGRectZero;
                }
                
                pbModel.sourceImageView=imagev;
            }
            //源frame
            [modelsM addObject:pbModel];
        }
        return modelsM;
    }];
    
    [inputView tapBackGround];
}

-(void)sendFirstMsg
{
//    [self sendTellSupplier];
    [self sendTellPartener];
}

-(void)sendTellPartener
{
    if(!partnerUserInfo){
        [WTProgressHUD ShowTextHUD:@"用户数据错误" showInView:KEY_WINDOW];
        return ;
    }
    NSString *name = partnerUserInfo.name;
    NSString *avatar;
    NSString *serverId;
    if (self.sendToAskData) {
		name = self.sendToAskData[@"name"];
		avatar = self.sendToAskData[@"avatar"] ;
        serverId = partnerId;
    }

    name = [LWUtil getString:name andDefaultStr:@""];
    avatar = [LWUtil getString:avatar andDefaultStr:@""];
    serverId = [LWUtil getString:serverId andDefaultStr:@""];
    
    NSString *title = [NSString stringWithFormat:@"发起与%@的会话",name];
    [[ChatMessageManager instance] sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
        if (ourCov) {
            [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeChatWithSupplier andConversationValue:@{@"conversationId":self.conversation.conversationId,@"title":title ,@"name":name,@"avatar":avatar,@"id":serverId} andCovTitle:title conversation:ourCov push:YES success:^{
            } failure:nil];
        }
    }];
}

-(NSArray*)createViewWithMember:(NSArray*)members
{
    if (!avatarMembersArray) {
        avatarMembersArray=[[NSMutableArray alloc]initWithCapacity:3];
    }
    NSMutableArray *views=[[NSMutableArray alloc]initWithCapacity:3];
    for (NSString *member in members)
	{
		WTConversationType type = [self.keyConversation.attributes[@"type"] integerValue];
		if( ( type == WTConversationTypeSupplier )
		   && [member isEqualToString:kServerID])
		{

		}
		else
		{
			UIView *view=[[UIView alloc]init];
			view.width=avatarWidth;
			view.height=avatarWidth;
			view.tag=[member intValue];//设置这个用来判断对应view
			view.layer.cornerRadius=view.width/2;
			view.layer.masksToBounds=YES;

			UIImageView *avatar=[[UIImageView alloc] init];
			avatar.width=avatarWidth;
			avatar.height=avatarWidth;
			avatar.tag=0; //设置这个用来判断黑白
			view.layer.borderColor=[UIColor whiteColor].CGColor;
			view.layer.borderWidth=2;
			[WeddingTimeAppInfoManager setAvatar:avatar userId:member];
			[view addSubview:avatar];
			[views addObject:view];
			[avatarMembersArray addObject:member];
		}
    }
    return views;
}

-(void)avatarViewChangeWithAddView:(NSArray*)addViews removeView:(NSArray*)removeViews blackView:(NSArray*)blackViews lightView:(NSArray*)lightViews
{
    if (!avatarArray) {
        avatarArray=[[NSMutableArray alloc] initWithCapacity:3];
    }
    
    int num = (int)(avatarArray.count+addViews.count-removeViews.count);//view总数
    
    float avatarViewWidth=0;//view最终宽度
    if (num>0) {
        avatarViewWidth = avatarPaddingBorder*2+num*avatarWidth+(num-1)*avatarPadding;
    }
    
    void(^showBlock)()=^(){
        if (addViews&&addViews.count>0) {
            [avatarArray addObjectsFromArray:addViews];
            
        }
        __block NSMutableDictionary  *pointdic=[NSMutableDictionary new];
        for (int i=0; i<avatarArray.count; i++) {
            ObjCGPoint* point=[ObjCGPoint new];
            point.py=-avatarWidth/2;
            point.px=avatarPaddingBorder+(avatarWidth+avatarPadding)*i;
            UIView *view=avatarArray[i];
            [pointdic setObject:point forKey:[NSNumber numberWithInteger:view.tag]];
        }

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.avatarView.width=avatarViewWidth;
            for (UIView *view in avatarArray) {
                ObjCGPoint* point=pointdic[@(view.tag)];
                if (point) {
                    view.origin=CGPointMake(point.px, point.py) ;
                }
            }
        } completion:^(BOOL finished) {
            if (addViews&&addViews.count>0) {
                for (UIView *view in addViews) {
                    [self.avatarView insertSubview:view atIndex:0];
                    ObjCGPoint* point=pointdic[@(view.tag)];
                    if (point) {
                        view.origin=CGPointMake(point.px, point.py) ;
                        view.alpha=0;
                    }
                }
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    for (UIView *view in addViews) {
                        view.alpha = 1;
                    }
                }completion:nil];
            }
        }];
    };
    
    void(^removeBlock)()=^(){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (UIView *view in removeViews) {
                view.alpha=0;
            }
            //todo隐藏
        }completion:^(BOOL finished) {
			 for (UIView *view in removeViews) {
				 [view removeFromSuperview];
			 }
			 [avatarArray removeObjectsInArray:removeViews];
			 for (UIView *removeView in removeViews) {
				 [avatarMembersArray removeObject:[NSNumber numberWithInteger:removeView.tag]];
			 }
			 showBlock();
		 }];
	};
    
    if (removeViews&&removeViews.count>0) {
        removeBlock();
    }
    else
    {
        showBlock();
    }
    
}

#pragma mark 加载聊天内容
//在创建或者接收聊天室成功后从一个聊天中获取历史对话
- (void)getHistoryCoversation {
    [self loadWithMessage:nil];
}

//根据当前message加载历史记录
-(void)loadWithMessage:(Message*)message
{
    ConversationStore *store = [ConversationStore sharedInstance];
    NSString *msgId;
    int64_t time= [[NSDate date] timeIntervalSince1970]*1000;
    if (message) {
        msgId=message.imMessage.messageId;
        time=message.imMessage.sendTimestamp;
    }
    __weak typeof(self) weakSelf = self;
    [store queryMoreMessages:self.keyConversation.conversationId from:msgId timestamp:time limit:historyMessageCount callback:^(NSArray *objects, NSError *error) {
        if (!error)
		{
			if(!objects) {return ;};
			for (int i=0; i<objects.count; i++)
			{
				//倒序插入
				if(![messages containsObject:objects[i]])
				{
					[messages insertObject:objects[i] atIndex:0];
					Message *message=objects[i];
					if ([message.imMessage isKindOfClass:[AVIMTypedMessage class]]) {
						if (((AVIMTypedMessage*)message.imMessage).mediaType==kAVIMMessageMediaTypeImage&&((AVIMImageMessage *)message.imMessage).attributes) {
							[imageUrlArray insertObject:((AVIMImageMessage*)message.imMessage).attributes[@"imgUrl"] atIndex:0];
						}else if (((AVIMTypedMessage*)message.imMessage).mediaType==kAVIMMessageMediaTypeImage){
							[imageUrlArray insertObject:((AVIMImageMessage*)message.imMessage).file.url atIndex:0];
						}
					}
				}
			}
			[weakSelf.dataTableView reloadData];
			if (messages.count > 1) {
				if (isLoadingMore) {
					[weakSelf.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:objects.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
					[weakSelf.dataTableView setContentOffset:CGPointMake(weakSelf.dataTableView.contentOffset.x, weakSelf.dataTableView.contentOffset.y-1) animated:YES];
				}
				else
				{
					[weakSelf.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				}
			}
            isLoadingMore = NO;
			haveMore = objects.count >= historyMessageCount;
        }
        else
        {
            [WTProgressHUD ShowTextHUD:error.domain showInView:KEY_WINDOW];
        }
    }];
}

#pragma mark block回调处理
- (void)doFinishStartConversationWithPartner:(NSError *)error :(AVIMConversation *)resultConversation {
    if (!error) {
        __weak typeof(self) weakSelf = self;
        [weakSelf doFinishStartConversationWithConversation:resultConversation];
    }else
	{
        [inputView chatStatusSetWithStatus:ChatErrorStatusLoadConversationFaild];
        WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"可能由于网络问题暂时无法与对方建立连接" centerImage:nil];
        [alertView setButtonTitles:@[@"好的"]];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            [alertView close];
        }];
        [alertView show];
    }
}

- (void)doFinishStartConversationWithConversation:(AVIMConversation *)resultConversation {
    if (![resultConversation.members containsObject:[UserInfoManager instance].userId_self]) {
        [resultConversation joinWithCallback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [WTProgressHUD ShowTextHUD:error.domain showInView:KEY_WINDOW];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self beginChat:resultConversation];
            }
        }];
    }
    else
    {
        [self beginChat:resultConversation];
    }
}

#pragma mark ChatMessageManagerDelegate
-(void)getListStateChanged:(WTChatMessageGetListState)state
{
    switch (state) {
        case WTChatMessageGetListStateNone:
            break;
        case WTChatMessageGetListStateClosed:
            break;
        case WTChatMessageGetListStateError:
            [inputView chatStatusSetWithStatus:ChatErrorStatusOpenChatFaild];
            break;
        case WTChatMessageGetListStatePaused:
            [inputView chatStatusSetWithStatus:ChatErrorStatusCollecting];
            break;
        case WTChatMessageGetListStateReconnecting:
            [inputView chatStatusSetWithStatus:ChatErrorStatusCollecting];
            break;
        case WTChatMessageGetListStateOpening:
            [inputView chatStatusSetWithStatus:ChatErrorStatusCollecting];
            break;
        case WTChatMessageGetListStatePullConversations:
            break;
        case WTChatMessageGetListStatePullConversationFailed:
            break;
        case WTChatMessageGetListStateUpdateConversations:
            break;
        case WTChatMessageGetListStateUpdateUsers:
            break;
        case WTChatMessageGetListStateOpen:
            [self startConversationWithPartner];
            break;
        case WTChatMessageGetListStateGetListDone:
            break;
        default:
            break;
    }
}

+(void)pushToChatDetailWithConversationId:(NSString*)conversationId
{
    WTChatDetailViewController *next=[[WTChatDetailViewController alloc] init];
    next.conversationId=conversationId;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav pushViewController:next animated:YES];
}

+(void)pushToChatDetailWithKeyConversation:(AVIMKeyedConversation*)keyConversation
{
    WTChatDetailViewController *next=[[WTChatDetailViewController alloc] init];
    next.keyConversation=keyConversation;
    next.conversationId=keyConversation.conversationId;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav pushViewController:next animated:YES];
}

+(void)pushToChatDetailWithConversation:(AVIMConversation*)conversaiton
{
    WTChatDetailViewController *next=[[WTChatDetailViewController alloc] init];
    next.conversation=conversaiton;
    next.keyConversation=[conversaiton keyedConversation];
    next.conversationId=conversaiton.conversationId;
    UINavigationController *nav =(UINavigationController *)KEY_WINDOW.rootViewController;
    [nav pushViewController:next animated:YES];
}
@end


//    if(![partnerId isNotEmptyCtg])
//    {
//        [WTProgressHUD ShowTextHUD:@"用户数据错误" showInView:KEY_WINDOW];
//        return;
//    }
//
//    if (![partnerUserInfo.phone isNotEmptyCtg]||!partnerUserInfo) {
//        partnerUserInfo = [[SQLiteAssister sharedInstance] pullUserInfo:partnerId];
//    }
//    if (!partnerUserInfo) {
//        [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
//        return;
//    }
//
//    if (![partnerUserInfo.phone isNotEmptyCtg])
//    {
//        [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
//        return;
//    }

//	NSString *phoneNum = partnerUserInfo.phone;


//通知商家
//-(void)sendTellSupplier
//{
//    if(![partnerId isNotEmptyCtg])
//    {
//        [WTProgressHUD ShowTextHUD:@"用户数据错误" showInView:KEY_WINDOW];
//        return;
//    }
//
//	NSString *supplierId = self.hotelData[@"hotel_id"] ?  hotelHunlishiguangId : partnerId;
//    [PostDataService postSend_smsTellSupplier:supplierId withBlock:^(NSDictionary *result, NSError *error){
//        [self doloadFinishSend_sms:result And:error];
//    }];//发送短信
//}


//- (void)doloadFinishSend_sms:(NSDictionary *)result And:(NSError *)error {
//	[self hideLoadingView];
//	if (!error) {
//	}else {
//	}
//}
