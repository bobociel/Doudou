//
//  FriendsMessageView.m
//  nihoo
//
//  Created by 刘志 on 15/5/7.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "FriendsMessageView.h"
#import "MessageCell.h"
#import "MessageDetailController.h"
#import "AppDelegate.h"
#import "EaseMob.h"
#import "AppConfigure.h"
#import "ContactDao.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "HttpManager.h"
#import "NihaoContact.h"
#import <MJExtension.h>
#import "ChatViewController.h"
#import "Constants.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ListingLoadingStatusView.h"

@interface FriendsMessageView()<UITableViewDelegate,UITableViewDataSource, ChatViewControllerDelegate,MGSwipeTableCellDelegate> {
    UITableView *_table;
    NSMutableArray *_data;
    ContactDao *_dao;
    ListingLoadingStatusView *_emptyStatusView;
}

@end

@implementation FriendsMessageView {
	NSString *userIconURLString;
	NSString *selfIconURLString;
}

static NSString *identifier = @"MessageCell";

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initTable];
        [self initConversationData];
        [self initEmptyStatusView];
        _dao = [[ContactDao alloc] init];
		selfIconURLString = [BaseFunction convertServerImageURLToURLString:[AppConfigure objectForKey:LOGINED_USER_ICON_URL]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageComes:) name:KNOTIFICATION_NEW_MESSAGE_COMES object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogoChanged:) name:KNOTIFICATION_LOGO_CHANGED object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化列表控件
 */
- (void) initTable {
    _table = [[UITableView alloc] initWithFrame:self.frame];
    _table.delegate = self;
    _table.dataSource = self;
    _table.showsVerticalScrollIndicator = NO;
    _table.tableFooterView = [[UIView alloc] init];
    [_table registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:identifier];
    [self addSubview:_table];
    _data = [NSMutableArray array];
}

- (void) initEmptyStatusView {
    _emptyStatusView = [[ListingLoadingStatusView alloc] initWithFrame:self.bounds];
    [self addSubview:_emptyStatusView];
    [_emptyStatusView setEmptyImage:@"icon_no_message" emptyContent:@"No message" imageSize:NO_MESSAGE];
    [_emptyStatusView showWithStatus:Empty];
    if(_data.count == 0) {
        _emptyStatusView.hidden = YES;
    } else {
        _emptyStatusView.hidden = NO;
    }
}

/**
 *  初始化聊天历史纪录列表
 */
- (void) initConversationData {
    NSArray *conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    if(_data.count > 0) {
        [_data removeAllObjects];
    }
    if(conversations.count > 0) {
        _emptyStatusView.hidden = YES;
    } else {
        _emptyStatusView.hidden = NO;
    }
    [_data addObjectsFromArray:conversations];
    [self sortConverationByLastMessageTime];
    [_table reloadData];
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //获取navigation controller
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabbarController = (UITabBarController *)delegate.window.rootViewController;
    UINavigationController *navigationController = [[tabbarController viewControllers] objectAtIndex:1];
    //进入聊天页面
    EMConversation *conversation = _data[indexPath.row];
    //将全部消息设为已读
    if(conversation.unreadMessagesCount > 0) {
        [_table reloadData];
        //向appdelegate发送通知，更新application badge和messagecontroller的tabitem badge
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MESSAGE_BADGE_CHANGED object:nil];
        [conversation markAllMessagesAsRead:YES];
    }
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithChatter:conversation.chatter conversationType:conversation.conversationType];
	chatViewController.delelgate = self;
    [_dao queryContactByUsername:conversation.chatter query:^(FMResultSet *set) {
        if(set && set.columnCount > 0 && [set next]) {
            NSString *userNickName = [set stringForColumn:@"NICK_NAME"];
            NSString *userName=conversation.chatter;
			userIconURLString = [BaseFunction convertServerImageURLToURLString:[set stringForColumn:@"LOGO"]];
            chatViewController.title = userNickName;
            chatViewController.chatterUserName=userName;
			chatViewController.chatterUserID = [set intForColumn:@"USERID"];
        }
    }];
    [navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    EMConversation *conversation = _data[indexPath.row];
    cell.dao = _dao;
    [cell loadData:conversation];
    return cell;
}

#pragma mark - 新消息到达时，需刷新列表
- (void) newMessageComes : (NSNotification *) notification {
    NSArray *conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    [_data removeAllObjects];
    [_data addObjectsFromArray:conversations];
    [self sortConverationByLastMessageTime];
    [_table reloadData];
    if(!_emptyStatusView.hidden) {
        _emptyStatusView.hidden = YES;
    }
}

#pragma mark - ChatViewControllerDelegate

// 根据环信id得到要显示头像路径，如果返回nil，则显示默认头像
- (NSString *)avatarWithChatter:(NSString *)chatter {
	NSString *selfUserID = [AppConfigure objectForKey:LOGINED_USER_NAME];
	if ([chatter isEqualToString:selfUserID]) {
		return selfIconURLString;
	} else {
		return userIconURLString;
	}
}

// 根据环信id得到要显示用户名，如果返回nil，则默认显示环信id
- (NSString *)nickNameWithChatter:(NSString *)chatter {
	return chatter;
}

- (void) userLogoChanged : (NSNotification *) notification {
    selfIconURLString = [BaseFunction convertServerImageURLToURLString:[AppConfigure objectForKey:LOGINED_USER_ICON_URL]];
}

#pragma mark - MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings; {
    if(direction == MGSwipeDirectionRightToLeft) {
        NSMutableArray * result = [NSMutableArray array];
        NSString* titles[1] = {@"Delete"};
        UIColor * colors[1] = {[UIColor redColor]};
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[0] backgroundColor:colors[0] callback:^BOOL(MGSwipeTableCell * sender){
            //autohide in delete button to improve delete expansion animation
            return YES;
        }];
        [result addObject:button];
        return result;
    } else {
        return nil;
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        NSIndexPath * path = [_table indexPathForCell:cell];
        //delete button
        EMConversation *conversation = _data[path.row];
        if(conversation.unreadMessagesCount > 0) {
            [conversation markAllMessagesAsRead:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MESSAGE_BADGE_CHANGED object:nil];
        }
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES];
        [_data removeObjectAtIndex:path.row];
        [_table deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];

        //Don't autohide to improve delete expansion animation
        if(_data.count == 0) {
            _emptyStatusView.hidden = NO;
        }
        return NO;
    }
    return YES;
}

- (void) sortConverationByLastMessageTime {
    [_data sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EMConversation *conversation1 = (EMConversation *) obj1;
        EMConversation *conversation2 = (EMConversation *) obj2;
        return conversation1.latestMessage.timestamp < conversation2.latestMessage.timestamp;
    }];
}

@end
