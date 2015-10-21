//
//  LikeNotificationsController.m
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "LikeNotificationsController.h"
#import "LikeNotificationTableViewCell.h"
#import "ListingLoadingStatusView.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "LikeNotification.h"
#import "PostDetailViewController.h"
#import "UserInfoViewController.h"

@interface LikeNotificationsController () <UITableViewDelegate,UITableViewDataSource,UserLogoTappedDelegate> {
    UITableView *_table;
    NSMutableArray *_data;
    NSUInteger _page;
    ListingLoadingStatusView *_statusView;
    BOOL _executeOnce;
}

@end

@implementation LikeNotificationsController

static NSString *const CELL_IDENTIFIER = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Like";
    [self dontShowBackButtonTitle];
    [self initTableView];
    [self initLoadingView];
    [self requestUnreadLikeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) initTableView {
    _page = 1;
    _data = [NSMutableArray array];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    [_table registerNib:[UINib nibWithNibName:@"LikeNotificationTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = 91;
    _table.tableFooterView = [[UIView alloc] init];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(requestUnreadLikeNotifications) loadMoreAction:@selector(requestUnreadLikeNotifications) target:self];
    [self.view addSubview:_table];
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    _executeOnce = YES;
}

- (void) initLoadingView {
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:self.view.frame];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestUnreadLikeNotifications];
    };
    [self.view addSubview:_statusView];
    [_statusView showWithStatus:Loading];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LikeNotification *notification = _data[indexPath.row];
    PostDetailViewController *detailController = [[PostDetailViewController alloc] initWithNibName:@"PostDetailViewController" bundle:nil];
    detailController.postID = [NSString stringWithFormat:@"%ld", notification.cd_id];
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikeNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    LikeNotification *notification = _data[indexPath.row];
    [cell configureLikeNotification:notification indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - net work
- (void) requestUnreadLikeNotifications {
    if(_table.header.isRefreshing) {
        _page = 1;
    }
    [HttpManager requestUnreadLikeList:[AppConfigure integerForKey:LOGINED_USER_ID] page:_page success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self stopTableRefresh];
        if([responseObject[@"code"] integerValue] == 0) {
            if(_delegate && _executeOnce) {
                [_delegate messageReaded:LIKE];
                _executeOnce = NO;
            }
            NSArray *rows = responseObject[@"result"][@"rows"];
            if(rows.count == 0) {
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_like" emptyContent:@"No likes" imageSize:NO_LIKE];
            } else {
                if(_page == 1) {
                    [_data removeAllObjects];
                }
                if([self.view.subviews containsObject:_statusView]) {
                    [_statusView showWithStatus:Done];
                }
                _table.header.hidden = NO;
                for(NSDictionary *item in rows) {
                    LikeNotification *likeNotification = [LikeNotification objectWithKeyValues:item];
                    [_data addObject:likeNotification];
                }
                [_table reloadData];
                if(_data.count < [DEFAULT_REQUEST_DATA_ROWS integerValue]) {
                    _table.footer.hidden = YES;
                } else {
                    _page++;
                }
            }
        } else {
            [_statusView showWithStatus:NetErr];
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self stopTableRefresh];
        [_statusView showWithStatus:NetErr];
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
- (void) userLogoTapped:(NSIndexPath *)indexPath {
    LikeNotification *notification = _data[indexPath.row];
    UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    userInfoViewController.uid = notification.ci_id;
    userInfoViewController.uname = notification.ci_nikename;
    [self.navigationController pushViewController:userInfoViewController animated:YES];
}

@end
