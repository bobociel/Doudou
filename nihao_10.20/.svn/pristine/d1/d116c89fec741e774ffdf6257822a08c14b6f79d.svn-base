//
//  CommentsNotificationsViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "CommentsNotificationsViewController.h"
#import "CommentNotificationTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import "BaseFunction.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "AppConfigure.h"
#import "CommentNotification.h"
#import "PostDetailViewController.h"
#import "UserInfoViewController.h"

@interface CommentsNotificationsViewController () <UITableViewDataSource,UITableViewDelegate,UserLogoTappedDelegate> {
    UITableView *_table;
    NSUInteger _page;
    NSMutableArray *_data;
    ListingLoadingStatusView *_statusView;
    BOOL _executeOnce;
}

@end

@implementation CommentsNotificationsViewController

static NSString *const CELL_IDENTIFIER = @"cellIndentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Comments";
    [self dontShowBackButtonTitle];
    [self initTable];
    [self initLoadingView];
    [self requestUnreadCommentList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) initTable {
    _page = 1;
    _data = [NSMutableArray array];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = [[UIView alloc] init];
    [_table registerNib:[UINib nibWithNibName:@"CommentNotificationTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(requestUnreadCommentList) loadMoreAction:@selector(requestUnreadCommentList) target:self];
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    [self.view addSubview:_table];
    _executeOnce = YES;
}

- (void) initLoadingView {
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:self.view.bounds];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestUnreadCommentList];
    };
    [_statusView showWithStatus:Loading];
    [self.view addSubview:_statusView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    CommentNotification *notification = _data[indexPath.row];
    [cell configureCell:notification indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:CELL_IDENTIFIER cacheByIndexPath:indexPath configuration:^(id cell) {
        [((CommentNotificationTableViewCell *) cell) configureCell:_data[indexPath.row] indexPath:indexPath];
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	CommentNotification *notification = _data[indexPath.row];
	PostDetailViewController *detailController = [[PostDetailViewController alloc] initWithNibName:@"PostDetailViewController" bundle:nil];
	detailController.postID = [NSString stringWithFormat:@"%ld", notification.cd_id];
	[self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - net work
- (void) requestUnreadCommentList {
    if([_table.header isRefreshing]) {
        _page = 1;
    }
    [HttpManager requestUnreadCommentNums:[NSString stringWithFormat:@"%lu",[AppConfigure integerForKey:LOGINED_USER_ID]] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self stopTableRefresh];
        if([responseObject[@"code"] integerValue] == 0) {
            if(_delegate && _executeOnce) {
                [_delegate messageReaded:COMMENT];
                _executeOnce = NO;
            }
            NSArray *rows = responseObject[@"result"][@"rows"];
            if(rows.count == 0) {
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_comment" emptyContent:@"No comment" imageSize:NO_COMMENT];
            } else {
                if(_page == 1) {
                    [_data removeAllObjects];
                }
                for(NSDictionary *item in rows) {
                    CommentNotification *notification = [CommentNotification objectWithKeyValues:item];
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
- (void) userLogoTapped:(NSIndexPath *)indexPath {
    CommentNotification *notification = _data[indexPath.row];
    UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    userInfoViewController.uid = notification.ci_id;
    userInfoViewController.uname = notification.ci_nikename;
    [self.navigationController pushViewController:userInfoViewController animated:YES];
}

@end
