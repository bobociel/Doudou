//
//  ChatViewController.m
//  nihao
//
//  Created by HelloWorld on 7/8/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ChatViewController.h"
#import "SRRefreshView.h"
#import "DXMessageToolBar.h"
#import "MessageReadManager.h"
#import "ChatViewController+Category.h"
#import "MessageModelManager.h"
#import "NSDate+Category.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChatSendHelper.h"
#import "UIResponder+Router.h"
#import "UserInfoViewController.h"
#import "AppConfigure.h"
#import "ReportViewController.h"
#import "SettingMenu.h"

#import "ProfileViewController.h"

#define KPageCount 20
#define KHintAdjustY 50

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate,IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate> {
	UIMenuController *_menuController;
	UIMenuItem *_copyMenuItem;
	UIMenuItem *_deleteMenuItem;
	NSIndexPath *_longPressIndexPath;
	
	NSInteger _recordingCount;
	
	dispatch_queue_t _messageQueue;
	
	NSMutableArray *_messages;
	BOOL _isScrollToBottom;
    SettingMenu *_menu;
}

@property (nonatomic) BOOL isChatGroup;

@property (nonatomic) EMConversationType conversationType;

@property (strong, nonatomic) NSMutableArray *dataSource;// tableView数据源
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;// message阅读的管理者
@property (strong, nonatomic) EMConversation *conversation;// 会话管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isScrollToBottom;
//@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isKicked;

@end

@implementation ChatViewController {
	BOOL isBack;
}

#pragma mark - init

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup {
	EMConversationType type = isGroup ? eConversationTypeGroupChat : eConversationTypeChat;
	self = [self initWithChatter:chatter conversationType:type];
	if (self) {
	}
	
	return self;
}

- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
//		_isPlayingAudio = NO;
		_chatter = chatter;
		_conversationType = type;
		_messages = [NSMutableArray array];
		
		// 根据接收者的username获取当前会话的管理者
		_conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter
																	conversationType:type];
		[_conversation markAllMessagesAsRead:YES];
	}
	
	return self;
}

- (BOOL)isChatGroup {
	return _conversationType != eConversationTypeChat;
}

#pragma view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//	[self registerBecomeActive];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
		self.edgesForExtendedLayout =  UIRectEdgeNone;
	}
	
	// 以下三行代码必须写，注册为SDK的ChatManager的delegate
//	[EMCDDeviceManager sharedInstance].delegate = self;
	[[EaseMob sharedInstance].chatManager removeDelegate:self];
	// 注册为SDK的ChatManager的delegate
	[[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
	
	_messageQueue = dispatch_queue_create("nihao", NULL);
	_isScrollToBottom = YES;
	isBack = YES;
	
	[self setupBarButtonItem];
	[self.view addSubview:self.tableView];
	[self.tableView addSubview:self.slimeView];
	[self.view addSubview:self.chatToolBar];
	
	//将self注册为chatToolBar的moreView的代理
	if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
		[(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
	}
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
	[self.view addGestureRecognizer:tap];
	
	//通过会话管理者获取已收发消息
	long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
	[self loadMoreMessagesFrom:timestamp count:KPageCount append:NO];
    
    [self addSettingMenu];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
	if (_isScrollToBottom) {
		[self scrollViewToBottom:NO];
	}
	else{
		_isScrollToBottom = YES;
	}
	self.isInvisible = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
#warning 每次展示了界面，都将 isBack 置为 YES
	isBack = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// 设置当前conversation的所有message为已读
	[_conversation markAllMessagesAsRead:YES];
//	[[EMCDDeviceManager sharedInstance] disableProximitySensor];
	self.isInvisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
#warning 用户退出聊天界面需要将回话remove掉，如果是不退出但是需要打开一个新的VC，需要将isBack设置为NO
	if (isBack) {
		// 判断当前会话是否为空，若符合则删除该会话
		EMMessage *message = [_conversation latestMessage];
		if (message == nil) {
			[[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
		}
	}
    
    //通知messageviewcontroller刷新未读数量
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MESSAGE_BADGE_CHANGED object:nil];
}

- (void)dealloc {
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	_tableView = nil;
	
	_slimeView.delegate = nil;
	_slimeView = nil;
	
	_chatToolBar.delegate = nil;
	_chatToolBar = nil;
	
//	[[EMCDDeviceManager sharedInstance] stopPlaying];
//	[EMCDDeviceManager sharedInstance].delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
#warning 以下第一行代码必须写，将self从ChatManager的代理中移除
	[[EaseMob sharedInstance].chatManager removeDelegate:self];
//	[[EaseMob sharedInstance].callManager removeDelegate:self];
	if (_conversation.conversationType == eConversationTypeChatRoom && !_isKicked)
	{
		//退出聊天室，删除会话
		NSString *chatter = [_chatter copy];
		[[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter completion:^(EMChatroom *chatroom, EMError *error){
			[[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
		}];
	}
	
	if (_imagePicker) {
		[_imagePicker dismissViewControllerAnimated:NO completion:nil];
	}
}

- (void)setupBarButtonItem {
//	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//	[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//	[backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//	[self.navigationItem setLeftBarButtonItem:backItem];
	
//	if (_conversationType == eConversationTypeChat) {
//		UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_person"] style:UIBarButtonItemStylePlain target:self action:@selector(lookUserProfile)];
//		self.navigationItem.rightBarButtonItem = profileItem;
//	}
	
//	if (self.isChatGroup) {
//		UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//		[detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
//		[detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
//		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
//	} else {
//		UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//		[clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
//		[clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
//		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
//	}
}

/**
 *  添加举报入口
 */
- (void) addSettingMenu {
    UIButton *button = [self createNavBtnByTitle:nil icon:@"iconfont-person" action:@selector(menuClick)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -20;
    self.navigationItem.rightBarButtonItems = @[spacerButton,barButton];
}

-(UIButton *)createNavBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL) action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,60,40);
    if(title) {
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = FontNeveLightWithSize(16);
    }
    if(icon) {
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
        if(title) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        }
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void) menuClick {
//    if(!_menu) {
//        _menu = [[SettingMenu alloc] init];
//        [_menu setData:@[@"Report"]];
//        __weak typeof(self) weakSelf = self;
//        _menu.menuClickAtIndex = ^(NSInteger item) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf report];
//        };
//		_menu.menuDismissed = ^() {
//			__strong typeof(weakSelf) strongSelf = weakSelf;
//			if (strongSelf.view.gestureRecognizers.count == 0) {
//				UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:strongSelf action:@selector(keyBoardHidden)];
//				[strongSelf.view addGestureRecognizer:tap];
//			}
//		};
//        [self.view addSubview:_menu];
//    }
//    
//    if(_menu.hidden) {
//		if (self.view.gestureRecognizers.count > 0) {
////			NSLog(@"self.view.gestureRecognizers.count = %ld", self.view.gestureRecognizers.count);
//			UITapGestureRecognizer *tap = self.view.gestureRecognizers[0];
//			[self.view removeGestureRecognizer:tap];
//		}
//		[_menu showInView:self.view];
//    } else {
//        [_menu dismiss];
//    }
    
    if([_delelgate respondsToSelector:@selector(avatarWithChatter:)]){
    
       NSURL* ImageURL = [NSURL URLWithString:[_delelgate avatarWithChatter:_chatterUserName]];
        NSLog(@"=====头像=====%@",ImageURL);
        ProfileViewController *ProfileController = [[ProfileViewController alloc]init];
        ProfileController.profileName = self.title;
//        ProfileController.userName = _chatterUserName;
//        ProfileController.imageUrl=ImageURL;
//        ProfileController.getUserID = _chatterUserID;
        [self.navigationController pushViewController:ProfileController animated:YES];
    
    }
    
}
//
//- (void) report {
//    ReportViewController *reportController = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
//    reportController.userId = _chatterUserID;
//    [self.navigationController pushViewController:reportController animated:YES];
//}
//
//- (void)setIsInvisible:(BOOL)isInvisible {
//	_isInvisible =isInvisible;
//	if (!_isInvisible)
//	{
//		NSMutableArray *unreadMessages = [NSMutableArray array];
//		for (EMMessage *message in self.messages)
//		{
//			if ([self shouldAckMessage:message read:NO])
//			{
//				[unreadMessages addObject:message];
//			}
//		}
//		if ([unreadMessages count])
//		{
//			[self sendHasReadResponseForMessages:unreadMessages];
//		}
//		
//		[_conversation markAllMessagesAsRead:YES];
//	}
//}

#pragma mark - NSNotificationCenter

- (void)removeAllMessages:(id)sender {
	if (_dataSource.count == 0) {
		[self showHint:@"All messages cleared"];
		return;
	}
	
	if ([sender isKindOfClass:[NSNotification class]]) {
		NSString *groupId = (NSString *)[(NSNotification *)sender object];
		if (self.isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
			[_conversation removeAllMessages];
			[_messages removeAllObjects];
			_chatTagDate = nil;
			[_dataSource removeAllObjects];
			[_tableView reloadData];
			[self showHint:@"All messages cleared"];
		}
	} else{
		__weak typeof(self) weakSelf = self;
		
		[EMAlertView showAlertWithTitle:@"Prompt"
								message:@"please make sure to delete"
						completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
							if (buttonIndex == 1) {
								[weakSelf.conversation removeAllMessages];
								[weakSelf.messages removeAllObjects];
								weakSelf.chatTagDate = nil;
								[weakSelf.dataSource removeAllObjects];
								[weakSelf.tableView reloadData];
							}
						} cancelButtonTitle:@"Cancel"
					  otherButtonTitles:@"OK", nil];
	}
}

- (void)exitGroup {
	[self.navigationController popToViewController:self animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification {
	id object = notification.object;
	if (object) {
		EMMessage *message = (EMMessage *)object;
		[self addMessage:message];
		[[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
	}
}

- (void)applicationDidEnterBackground {
	[_chatToolBar cancelTouchRecord];
	
	// 设置当前conversation的所有message为已读
	[_conversation markAllMessagesAsRead:YES];
}

#pragma mark - getter

- (NSMutableArray *)dataSource {
	if (_dataSource == nil) {
		_dataSource = [NSMutableArray array];
	}
	
	return _dataSource;
}

- (SRRefreshView *)slimeView {
	if (_slimeView == nil) {
		_slimeView = [[SRRefreshView alloc] init];
		_slimeView.delegate = self;
		_slimeView.upInset = 0;
		_slimeView.slimeMissWhenGoingBack = YES;
		_slimeView.slime.bodyColor = [UIColor grayColor];
		_slimeView.slime.skinColor = [UIColor grayColor];
		_slimeView.slime.lineWith = 1;
		_slimeView.slime.shadowBlur = 4;
		_slimeView.slime.shadowColor = [UIColor grayColor];
	}
	
	return _slimeView;
}

- (UITableView *)tableView {
	if (_tableView == nil) {
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height) style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.backgroundColor = RGBACOLOR(235, 235, 235, 1);
		_tableView.tableFooterView = [[UIView alloc] init];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
		lpgr.minimumPressDuration = .5;
		[_tableView addGestureRecognizer:lpgr];
	}
	
	return _tableView;
}

- (DXMessageToolBar *)chatToolBar {
	if (_chatToolBar == nil) {
		_chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
		_chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		_chatToolBar.delegate = self;
		
		ChatMoreType type = self.isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
		_chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) typw:type];
		_chatToolBar.moreView.backgroundColor = RGBACOLOR(240, 242, 247, 1);
		_chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
	
	return _chatToolBar;
}

- (UIImagePickerController *)imagePicker {
	if (_imagePicker == nil) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
		_imagePicker.delegate = self;
	}
	
	return _imagePicker;
}

- (MessageReadManager *)messageReadManager {
	if (_messageReadManager == nil) {
		_messageReadManager = [MessageReadManager defaultManager];
	}
	
	return _messageReadManager;
}

- (NSDate *)chatTagDate {
	if (_chatTagDate == nil) {
		_chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
	}
	
	return _chatTagDate;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	// Return the number of sections.
//	return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [self.dataSource count]) {
		id obj = [self.dataSource objectAtIndex:indexPath.row];
		if ([obj isKindOfClass:[NSString class]]) {
			EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
			if (timeCell == nil) {
				timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
				timeCell.backgroundColor = [UIColor clearColor];
				timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
			timeCell.textLabel.text = (NSString *)obj;
			
			return timeCell;
		}
		else{
			MessageModel *model = (MessageModel *)obj;
			NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
			EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
				cell.backgroundColor = [UIColor clearColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			cell.messageModel = model;
			return cell;
		}
	}
	
	return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
	if ([obj isKindOfClass:[NSString class]]) {
		return 40;
	}
	else{
		return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
	}
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_slimeView) {
		[_slimeView scrollViewDidScroll];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (_slimeView) {
		[_slimeView scrollViewDidEndDraging];
	}
}

#pragma mark - slimeRefresh delegate

//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
	_chatTagDate = nil;
	EMMessage *firstMessage = [self.messages firstObject];
	if (firstMessage)
	{
		[self loadMoreMessagesFrom:firstMessage.timestamp count:KPageCount append:YES];
	}
	[_slimeView endRefresh];
}

#pragma mark - private

- (void)addMessage:(EMMessage *)message {
	[_messages addObject:message];
	__weak ChatViewController *weakSelf = self;
	dispatch_async(_messageQueue, ^{
		NSArray *messages = [weakSelf formatMessage:message];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.dataSource addObjectsFromArray:messages];
			[weakSelf.tableView reloadData];
			[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		});
	});
}

- (NSMutableArray *)formatMessage:(EMMessage *)message {
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
	NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
	if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
		[ret addObject:[createDate formattedTime]];
		self.chatTagDate = createDate;
	}
	
	MessageModel *model = [MessageModelManager modelWithMessage:message];
	if ([_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
		NSString *showName = [_delelgate nickNameWithChatter:model.username];
		model.nickName = showName?showName:model.username;
	} else {
		model.nickName = model.username;
	}
	
	if ([_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
		model.headImageURL = [NSURL URLWithString:[_delelgate avatarWithChatter:model.username]];
       
        
	} else {
		model.headImageURL = nil;
	}
	
	if (model) {
		[ret addObject:model];
	}
	
	return ret;
}

- (NSArray *)formatMessages:(NSArray *)messagesArray {
	NSMutableArray *formatArray = [[NSMutableArray alloc] init];
	if ([messagesArray count] > 0) {
		for (EMMessage *message in messagesArray) {
			NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
			NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
			if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
				[formatArray addObject:[createDate formattedTime]];
				self.chatTagDate = createDate;
			}
			
			MessageModel *model = [MessageModelManager modelWithMessage:message];
			if ([_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
				NSString *showName = [_delelgate nickNameWithChatter:model.username];
				model.nickName = showName?showName:model.username;
			}else {
				model.nickName = model.username;
			}
			
			if ([_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
				model.headImageURL = [NSURL URLWithString:[_delelgate avatarWithChatter:model.username]];
			} else {
				model.headImageURL = nil;
			}
			
			if (model) {
				[formatArray addObject:model];
			}
		}
	}
	
	return formatArray;
}

- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append {
	__weak typeof(self) weakSelf = self;
	dispatch_async(_messageQueue, ^{
		NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
		if ([messages count] > 0) {
			NSInteger currentCount = 0;
			if (append)
			{
				[weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
				NSArray *formated = [weakSelf formatMessages:messages];
				id model = [weakSelf.dataSource firstObject];
				if ([model isKindOfClass:[NSString class]])
				{
					NSString *timestamp = model;
					[formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
						if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
						{
							[weakSelf.dataSource removeObjectAtIndex:0];
							*stop = YES;
						}
					}];
				}
				currentCount = [weakSelf.dataSource count];
				[weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
				
				EMMessage *latest = [weakSelf.messages lastObject];
				weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
			} else {
				weakSelf.messages = [messages mutableCopy];
				weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.tableView reloadData];
				
				[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
			});
			
			//从数据库导入时重新下载没有下载成功的附件
//			for (EMMessage *message in messages)
//			{
//				[weakSelf downloadMessageAttachments:message];
//			}
			
			NSMutableArray *unreadMessages = [NSMutableArray array];
			for (NSInteger i = 0; i < [messages count]; i++)
			{
				EMMessage *message = messages[i];
				if ([self shouldAckMessage:message read:NO])
				{
					[unreadMessages addObject:message];
				}
			}
			if ([unreadMessages count])
			{
				[self sendHasReadResponseForMessages:unreadMessages];
			}
		}
	});
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read {
	NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
	if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
	{
		return NO;
	}
	
	id<IEMMessageBody> body = [message.messageBodies firstObject];
	if (((body.messageBodyType == eMessageBodyType_Video) ||
		 (body.messageBodyType == eMessageBodyType_Voice) ||
		 (body.messageBodyType == eMessageBodyType_Image)) &&
		!read)
	{
		return NO;
	} else {
		return YES;
	}
}

- (void)scrollViewToBottom:(BOOL)animated {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
		CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
		[self.tableView setContentOffset:offset animated:animated];
	}
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType {
	if (_menuController == nil) {
		_menuController = [UIMenuController sharedMenuController];
	}
	if (_copyMenuItem == nil) {
		_copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMenuAction:)];
	}
	if (_deleteMenuItem == nil) {
		_deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMenuAction:)];
	}
	
	if (messageType == eMessageBodyType_Text) {
		[_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
	}
	else{
		[_menuController setMenuItems:@[_deleteMenuItem]];
	}
	
	[_menuController setTargetRect:showInView.frame inView:showInView.superview];
	[_menuController setMenuVisible:YES animated:YES];
}

- (BOOL)shouldMarkMessageAsRead {
	if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible) {
		return NO;
	}
	
	return YES;
}

- (EMMessageType)messageType {
	EMMessageType type = eMessageTypeChat;
	switch (_conversationType) {
		case eConversationTypeChat:
			type = eMessageTypeChat;
			break;
		case eConversationTypeGroupChat:
			type = eMessageTypeGroupChat;
			break;
		case eConversationTypeChatRoom:
			type = eMessageTypeChatRoom;
			break;
		default:
			break;
	}
	return type;
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	if (_longPressIndexPath.row > 0) {
		MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
		pasteboard.string = model.content;
	}
	
	_longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender {
	if (_longPressIndexPath && _longPressIndexPath.row > 0) {
		MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
		NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
		[_conversation removeMessage:model.message];
		[self.messages removeObject:model.message];
		NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
		if (_longPressIndexPath.row - 1 >= 0) {
			id nextMessage = nil;
			id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
			if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
				nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
			}
			if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
				[indexs addIndex:_longPressIndexPath.row - 1];
				[indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
			}
		}
		
		[self.dataSource removeObjectsAtIndexes:indexs];
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
	
	_longPressIndexPath = nil;
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error {
	[self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 if ([obj isKindOfClass:[MessageModel class]])
		 {
			 MessageModel *model = (MessageModel*)obj;
			 if ([model.messageId isEqualToString:message.messageId])
			 {
				 model.message.deliveryState = message.deliveryState;
				 *stop = YES;
			 }
		 }
	 }];
	[self.tableView reloadData];
}

- (void)didReceiveHasReadResponse:(EMReceipt*)receipt {
	[self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 if ([obj isKindOfClass:[MessageModel class]])
		 {
			 MessageModel *model = (MessageModel*)obj;
			 if ([model.messageId isEqualToString:receipt.chatId])
			 {
				 model.message.isReadAcked = YES;
				 *stop = YES;
			 }
		 }
	 }];
	[self.tableView reloadData];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message {
	__weak ChatViewController *weakSelf = self;
	dispatch_async(_messageQueue, ^{
		if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
		{
			for (int i = 0; i < weakSelf.dataSource.count; i ++) {
				id object = [weakSelf.dataSource objectAtIndex:i];
				if ([object isKindOfClass:[MessageModel class]]) {
					MessageModel *model = (MessageModel *)object;
					if ([message.messageId isEqualToString:model.messageId]) {
						MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
						if ([self->_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
							NSString *showName = [self->_delelgate nickNameWithChatter:model.username];
							cellModel.nickName = showName?showName:cellModel.username;
						}else {
							cellModel.nickName = cellModel.username;
						}
						
						if ([self->_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
							cellModel.headImageURL = [NSURL URLWithString:[self->_delelgate avatarWithChatter:cellModel.username]];
                            NSLog(@"=========%@",cellModel.headImageURL);
						} else {
							cellModel.headImageURL = nil;
						}
						
						dispatch_async(dispatch_get_main_queue(), ^{
							[weakSelf.tableView beginUpdates];
							[weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
							[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
							[weakSelf.tableView endUpdates];
						});
						break;
					}
				}
			}
		}
	});
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error {
	if (!error) {
		id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
		if ([fileBody messageBodyType] == eMessageBodyType_Image) {
			EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
			if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
			{
				[self reloadTableViewDataWithMessage:message];
			}
		}else if([fileBody messageBodyType] == eMessageBodyType_Video){
			EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
			if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
			{
				[self reloadTableViewDataWithMessage:message];
			}
		}else if([fileBody messageBodyType] == eMessageBodyType_Voice){
			if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
			{
				[self reloadTableViewDataWithMessage:message];
			}
		}
		
	}else{
		
	}
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress {
	NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message {
	if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
		[self addMessage:message];
		if ([self shouldAckMessage:message read:NO])
		{
			[self sendHasReadResponseForMessages:@[message]];
		}
		if ([self shouldMarkMessageAsRead])
		{
			[self markMessagesAsRead:@[message]];
		}
	}
}

-(void)didReceiveCmdMessage:(EMMessage *)message {
	if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
		[self showHint:@"receive cmd message"];
	}
}

- (void)didReceiveMessageId:(NSString *)messageId
					chatter:(NSString *)conversationChatter
					  error:(EMError *)error {
	if (error && [_conversation.chatter isEqualToString:conversationChatter]) {
		
		__weak ChatViewController *weakSelf = self;
		for (int i = 0; i < self.dataSource.count; i ++) {
			id object = [self.dataSource objectAtIndex:i];
			if ([object isKindOfClass:[MessageModel class]]) {
				MessageModel *currentModel = [self.dataSource objectAtIndex:i];
				EMMessage *currMsg = [currentModel message];
				if ([messageId isEqualToString:currMsg.messageId]) {
					currMsg.deliveryState = eMessageDeliveryState_Failure;
					MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
					dispatch_async(dispatch_get_main_queue(), ^{
						[weakSelf.tableView beginUpdates];
						[weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
						[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
						[weakSelf.tableView endUpdates];
						
					});
					
					if (error && error.errorCode == EMErrorMessageContainSensitiveWords)
					{
						CGRect frame = self.chatToolBar.frame;
						[self showHint:@"Your message contains forbidden words" yOffset:-frame.size.height + KHintAdjustY];
					}
					break;
				}
			}
		}
	}
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages {
	if ([self shouldMarkMessageAsRead])
	{
		[_conversation markAllMessagesAsRead:YES];
	}
	if (![offlineMessages count])
	{
		return;
	}
	_chatTagDate = nil;
	long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
	[self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
	if (![offlineMessages count])
	{
		return;
	}
	if ([self shouldMarkMessageAsRead])
	{
		[_conversation markAllMessagesAsRead:YES];
	}
	_chatTagDate = nil;
	long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
	[self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error {
	if (self.isChatGroup && [group.groupId isEqualToString:_chatter]) {
		[self.navigationController popToViewController:self animated:NO];
		[self.navigationController popViewControllerAnimated:NO];
	}
}

- (void)didInterruptionRecordAudio {
	[_chatToolBar cancelTouchRecord];
	
	// 设置当前conversation的所有message为已读
	[_conversation markAllMessagesAsRead:YES];
	
//	[self stopAudioPlayingWithChangeCategory:YES];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error {
	if (!error && self.isChatGroup && [_chatter isEqualToString:group.groupId])
	{
		self.title = group.groupSubject;
	}
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice {
	if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
		[self.imagePicker stopVideoCapture];
	}
}

- (void)didRemovedFromServer {
	if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
		[self.imagePicker stopVideoCapture];
	}
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
	// 隐藏键盘
	[self keyBoardHidden];
	
	// 弹出照片选择
	self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
	isBack = NO;
	[self presentViewController:self.imagePicker animated:YES completion:NULL];
	self.isInvisible = YES;
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
	[self keyBoardHidden];
	
#if TARGET_IPHONE_SIMULATOR
	[self showHint:@"simulator does not support taking picture"];
#elif TARGET_OS_IPHONE
	self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
	isBack = NO;
	[self presentViewController:self.imagePicker animated:YES completion:NULL];
	self.isInvisible = YES;
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView {
	// 隐藏键盘
	[self keyBoardHidden];
	
//	LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
//	locationController.delegate = self;
//	[self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView {
	// 隐藏键盘
	[self keyBoardHidden];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:@{@"chatter":self.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeAudio]}];
}

- (void)moreViewVideoCallAction:(DXChatBarMoreView *)moreView {
	// 隐藏键盘
	[self keyBoardHidden];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:@{@"chatter":self.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeVideo]}];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
	[_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight {
	[UIView animateWithDuration:0.3 animations:^{
		CGRect rect = self.tableView.frame;
		rect.origin.y = 0;
		rect.size.height = self.view.frame.size.height - toHeight;
		self.tableView.frame = rect;
	}];
	[self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text {
	if (text && text.length > 0) {
		[self sendTextMessage:text];
	}
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView {
//	if ([self canRecord]) {
//		DXRecordView *tmpView = (DXRecordView *)recordView;
//		tmpView.center = self.view.center;
//		[self.view addSubview:tmpView];
//		[self.view bringSubviewToFront:recordView];
//		int x = arc4random() % 100000;
//		NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//		NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
//		
//		[[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
//																 completion:^(NSError *error)
//		 {
//			 if (error) {
//				 NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
//			 }
//		 }];
//	}
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView {
//	[[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView {
//	__weak typeof(self) weakSelf = self;
//	[[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//		if (!error) {
//			EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
//													   displayName:@"audio"];
//			voice.duration = aDuration;
//			[weakSelf sendAudioMessage:voice];
//		}else {
//			[weakSelf showHudInView:self.view hint:NSLocalizedString(@"media.timeShort", @"The recording time is too short")];
//			weakSelf.chatToolBar.recordButton.enabled = NO;
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//				[weakSelf hideHud];
//				weakSelf.chatToolBar.recordButton.enabled = YES;
//			});
//		}
//	}];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSString *mediaType = info[UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
//		NSURL *videoURL = info[UIImagePickerControllerMediaURL];
		[picker dismissViewControllerAnimated:YES completion:^{
			// 设置状态栏的字体颜色为白色
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
		}];
		// video url:
		// file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
		// we will convert it to mp4 format
//		NSURL *mp4 = [self convert2Mp4:videoURL];
//		NSFileManager *fileman = [NSFileManager defaultManager];
//		if ([fileman fileExistsAtPath:videoURL.path]) {
//			NSError *error = nil;
//			[fileman removeItemAtURL:videoURL error:&error];
//			if (error) {
//				NSLog(@"failed to remove file, error:%@.", error);
//			}
//		}
//		EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
//		[self sendVideoMessage:chatVideo];
		
	}else{
		UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
		[picker dismissViewControllerAnimated:YES completion:^{
			// 设置状态栏的字体颜色为白色
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
		}];
		[self sendImageMessage:orgImage];
	}
	self.isInvisible = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
	[self.imagePicker dismissViewControllerAnimated:YES completion:nil];
	// 设置状态栏的字体颜色为白色
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	self.isInvisible = NO;
}

#pragma mark - other functions

- (void)reloadData {
	_chatTagDate = nil;
	self.dataSource = [[self formatMessages:self.messages] mutableCopy];
	[self.tableView reloadData];
	
	//回到前台时
	if (!self.isInvisible)
	{
		NSMutableArray *unreadMessages = [NSMutableArray array];
		for (EMMessage *message in self.messages)
		{
			if ([self shouldAckMessage:message read:NO])
			{
				[unreadMessages addObject:message];
			}
		}
		if ([unreadMessages count])
		{
			[self sendHasReadResponseForMessages:unreadMessages];
		}
		
		[_conversation markAllMessagesAsRead:YES];
	}
}

#pragma mark - public

- (void)hideImagePicker {
	[self.imagePicker dismissViewControllerAnimated:YES completion:nil];
	self.isInvisible = NO;
}

#pragma mark - send message

-(void)sendTextMessage:(NSString *)textMessage {
	NSString *nickname = [AppConfigure valueForKey:LOGINED_USER_NICKNAME];
	NSString *extContent = [NSString stringWithFormat:@"%@ send you a message", nickname];
	NSDictionary *ext = @{ @"em_apns_ext" : @{ @"em_push_title" : extContent ,@"nickname":nickname} };
	EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
															toUsername:_conversation.chatter
														   messageType:[self messageType]
													 requireEncryption:NO
																   ext:ext];
	[self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)image {
    NSString *nickname = [AppConfigure valueForKey:LOGINED_USER_NICKNAME];
    NSDictionary *ext = @{ @"em_apns_ext" : @{@"nickname":nickname} };
	EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:image
															toUsername:_conversation.chatter
														   messageType:[self messageType]
													 requireEncryption:NO
																   ext:ext];
	[self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice {
	EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
											toUsername:_conversation.chatter
										   messageType:[self messageType]
									 requireEncryption:NO ext:nil];
	[self addMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video {
	EMMessage *tempMessage = [ChatSendHelper sendVideo:video
											toUsername:_conversation.chatter
										   messageType:[self messageType]
									 requireEncryption:NO ext:nil];
	[self addMessage:tempMessage];
}

- (void)sendHasReadResponseForMessages:(NSArray*)messages {
	dispatch_async(_messageQueue, ^{
		for (EMMessage *message in messages)
		{
			[[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
		}
	});
}

- (void)markMessagesAsRead:(NSArray*)messages {
	EMConversation *conversation = _conversation;
	dispatch_async(_messageQueue, ^{
		for (EMMessage *message in messages) {
			[conversation markMessageWithId:message.messageId asRead:YES];
		}
	});
}

#pragma mark - Touch Events

- (void)lookUserProfile {

}

#pragma mark - GestureRecognizer

// 点击背景隐藏
- (void)keyBoardHidden {
	[self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
		CGPoint location = [recognizer locationInView:self.tableView];
		NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
		id object = [self.dataSource objectAtIndex:indexPath.row];
		if ([object isKindOfClass:[MessageModel class]]) {
			EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell becomeFirstResponder];
			_longPressIndexPath = indexPath;
			[self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
		}
	}
}

#pragma mmark - Router

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
	MessageModel *messageModel = userInfo[KMESSAGEKEY];
	
	if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {
		UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
		
		if (messageModel.isSender) {
			userInfoViewController.uid = [[AppConfigure valueForKey:LOGINED_USER_ID] integerValue];
			userInfoViewController.uname = [AppConfigure valueForKey:LOGINED_USER_NICKNAME];
		} else {
			userInfoViewController.uid = self.chatterUserID;
			userInfoViewController.uname = self.title;
		}
		// 将关闭界面标记改为 NO，防止关闭聊天
		isBack = NO;
		userInfoViewController.userInfoFrom = UserInfoFromChat;
		[self.navigationController pushViewController:userInfoViewController animated:YES];
	} else if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        //  解析出URL
        NSString *string =messageModel.content;
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSLog(@"found URL: %@", url);
                
                UIWebView *webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
                [self.view addSubview:webView];
                NSURLRequest *request =[NSURLRequest requestWithURL:url];
                [webView loadRequest:request];
            }
        }
	} else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
		
	} else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
		[self chatImageCellBubblePressed:messageModel];
	} else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
		
	} else if([eventName isEqualToString:kResendButtonTapEventName]){
		EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
		MessageModel *messageModel = resendCell.messageModel;
		if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending)) {
			return;
		}
		id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
		[chatManager asyncResendMessage:messageModel.message progress:nil];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
		[self.tableView beginUpdates];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView endUpdates];
	} else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
		
	}
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model {
	__weak ChatViewController *weakSelf = self;
	id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
	if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
		EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
		if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
			if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed) {
				//发送已读回执
				if ([self shouldAckMessage:model.message read:YES]) {
					[self sendHasReadResponseForMessages:@[model.message]];
				}
				NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
				if (localPath && localPath.length > 0) {
					UIImage *image = [UIImage imageWithContentsOfFile:localPath];
					self.isScrollToBottom = NO;
					if (image) {
						[self.messageReadManager showBrowserWithImages:@[image]];
					} else {
						NSLog(@"Read %@ failed!", localPath);
					}
					
					return;
				}
			}
			[weakSelf showHudInView:weakSelf.view hint:@"downloading an image..."];
			[chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
				[weakSelf hideHud];
				if (!error) {
					//发送已读回执
					if ([weakSelf shouldAckMessage:model.message read:YES]) {
						[weakSelf sendHasReadResponseForMessages:@[model.message]];
					}
					NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
					if (localPath && localPath.length > 0) {
						UIImage *image = [UIImage imageWithContentsOfFile:localPath];
						weakSelf.isScrollToBottom = NO;
						if (image){
							[weakSelf.messageReadManager showBrowserWithImages:@[image]];
						} else {
							NSLog(@"Read %@ failed!", localPath);
						}
						return;
					}
				}
				[weakSelf showHint:@"image for failure!"];
			} onQueue:nil];
		} else {
			//获取缩略图
			[chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
				if (!error) {
					[weakSelf reloadTableViewDataWithMessage:model.message];
				} else {
					[weakSelf showHint:@"thumbnail for failure!"];
				}
				
			} onQueue:nil];
		}
	} else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
		//获取缩略图
		EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
		if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
			[chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
				if (!error) {
					[weakSelf reloadTableViewDataWithMessage:model.message];
				} else {
					[weakSelf showHint:@"thumbnail for failure!"];
				}
			} onQueue:nil];
		}
	}
}

@end
