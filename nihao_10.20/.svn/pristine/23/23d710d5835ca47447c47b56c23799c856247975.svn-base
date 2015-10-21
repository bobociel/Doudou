//
//  AsksNotificationsViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "AsksNotificationsViewController.h"
#import "AskNotificationTableViewCell.h"
#import "AskReplyTableViewCell.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "AskCommentNotification.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AskDetailViewController.h"
#import "UserInfoViewController.h"

@interface AsksNotificationsViewController () <UITableViewDelegate,UITableViewDataSource,UserLogoTappedDelegate> {
    UITableView *_table;
    NSMutableArray *_data;
    NSUInteger _page;
    ListingLoadingStatusView *_statusView;
    BOOL _executeOnce;
}

@end

@implementation AsksNotificationsViewController

static NSString *ASK_NOTIFICATION_IDENTIFIER = @"askNotificationIdentifier";
static NSString *ASK_REPLY_IDENTIFIER = @"askReplayIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ask Reply";
    [self dontShowBackButtonTitle];
    [self initTables];
    [self initLoadingView];
    [self requestUnreadAskComments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) initTables {
    _page = 1;
    _data = [NSMutableArray array];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _table.tableFooterView = [[UIView alloc] init];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table registerNib:[UINib nibWithNibName:@"AskReplyTableViewCell" bundle:nil] forCellReuseIdentifier:ASK_REPLY_IDENTIFIER];
    [_table registerNib:[UINib nibWithNibName:@"AskNotificationTableViewCell" bundle:nil] forCellReuseIdentifier:ASK_NOTIFICATION_IDENTIFIER];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(requestUnreadAskComments) loadMoreAction:@selector(requestUnreadAskComments) target:self];
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _executeOnce = YES;
}

- (void) initLoadingView {
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:self.view.bounds];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestUnreadAskComments];
    };
    [_statusView showWithStatus:Loading];
    [self.view addSubview:_statusView];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 != 0) {
        return [tableView fd_heightForCellWithIdentifier:ASK_REPLY_IDENTIFIER configuration:^(id cell) {
            [(AskReplyTableViewCell *) cell configureAskReplyCell:_data[indexPath.row / 2]];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:ASK_NOTIFICATION_IDENTIFIER configuration:^(id cell) {
            [(AskNotificationTableViewCell *) cell configureAskNotification:_data[indexPath.row / 2] indexPath:indexPath];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AskDetailViewController *controller = [[AskDetailViewController alloc] init];
    AskCommentNotification *notification = _data[indexPath.row / 2];
    controller.questionID = [NSString stringWithFormat:@"%ld",notification.aki_id];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0) {
        AskNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ASK_NOTIFICATION_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureAskNotification:_data[indexPath.row / 2] indexPath:indexPath];
        cell.delegate = self;
        return cell;
    } else {
        AskReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ASK_REPLY_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureAskReplyCell:_data[indexPath.row / 2]];
        return cell;
    }
}

#pragma mark - net work
- (void) requestUnreadAskComments {
    if([_table.header isRefreshing]) {
        _page = 1;
    }
    [HttpManager requestUnreadAskCommentList:[AppConfigure integerForKey:LOGINED_USER_ID] page:_page success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self stopTableRefresh];
        if([responseObject[@"code"] integerValue] == 0) {
            if(_delegate && _executeOnce) {
                [_delegate messageReaded:ASK];
                _executeOnce = NO;
            }
            NSArray *rows = responseObject[@"result"][@"rows"];
            if(rows.count == 0) {
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_comment" emptyContent:@"No comments" imageSize:NO_COMMENT];
            } else {
                if(_page == 1) {
                    [_data removeAllObjects];
                }
                for(NSDictionary *item in rows) {
                    AskCommentNotification *notification = [AskCommentNotification objectWithKeyValues:item];
                    [_data addObject:notification];
                }
                [_table reloadData];
                if([self.view.subviews containsObject:_statusView]) {
                    [_statusView showWithStatus:Done];
                }
                _table.header.hidden = NO;
                if(_data.count < DEFAULT_REQUEST_DATA_ROWS_INT) {
                    _table.footer.hidden = YES;
                } else {
                    _table.footer.hidden = NO;
                    _page++;
                }
            }
        } else {
            if(_data.count > 0) {
                [self showHUDNetError];
            } else {
                [_statusView showWithStatus:NetErr];
            }
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self stopTableRefresh];
        if(_data.count > 0) {
            [self showHUDNetError];
        } else {
            [_statusView showWithStatus:NetErr];
        }
    }];
}

- (void) stopTableRefresh {
    if(_table.header.isRefreshing) {
        [_table.header endRefreshing];
    }
    
    if(_table.footer.isRefreshing) {
        [_table.footer endRefreshing];
    }
}

#pragma mark - 用户头像点击
- (void) userLogoTapped : (NSIndexPath *)indexPath {
    AskCommentNotification *notification = _data[indexPath.row / 2];
    UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    userInfoViewController.uid = notification.ci_id;
    userInfoViewController.uname = notification.ci_nikename;
    [self.navigationController pushViewController:userInfoViewController animated:YES];
}

@end
