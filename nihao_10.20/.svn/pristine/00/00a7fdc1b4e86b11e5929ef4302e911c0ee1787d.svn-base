//
//  DiscoverView.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "DiscoverView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "DynamicCell.h"
#import "DynamicCollectionView.h"
#import "HttpManager.h"
#import <MJExtension.h>
#import "AppConfigure.h"
#import "ListingLoadingStatusView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import <MJRefresh.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UserPost.h"
#import "PicCell.h"
#import "GTMNSString+URLArguments.h"
#import "PostDetailViewController.h"
#import "UserInfoViewController.h"

//collectionview cell之间的间距
#define COLLECTION_CELL_EDGE 1

@interface DiscoverView () <UITableViewDelegate,UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *_data;
    NSInteger _total;
    NSInteger _page;
    ListingLoadingStatusView *_loadingStatus;
}

@end

@implementation DiscoverView {
	NSIndexPath *lastSelectedIndexPath;
}

static NSString *tableCellIdentifier = @"DynamicViewCellIdentifier";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initTableView];
        [self initUpTopButton];
        [self initLoadingViews];
        [self requestDiscoverList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPostDeleted:) name:KNOTIFICATION_DELETE_POST object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_DELETE_POST object:nil];
}

- (void) initTableView {
    _data = [NSMutableArray array];
    _table = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
    _table.tableFooterView = [[UIView alloc] init];
    [_table registerNib:[UINib nibWithNibName:@"DynamicCell" bundle:nil] forCellReuseIdentifier:tableCellIdentifier];
    _table.delegate = self;
    _table.dataSource = self;
    [self addSubview:_table];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(refresh) loadMoreAction:@selector(loadMore) target:self];
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    _table.fd_debugLogEnabled = NO;
}

- (void)initLoadingViews {
    // 初始化加载中的菊花
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.bounds];
    __weak DiscoverView *weakSelf = self;
    __weak ListingLoadingStatusView *weakStatusView = _loadingStatus;
    _loadingStatus.refresh = ^{
        [weakStatusView showWithStatus:Loading];
        [weakSelf requestDiscoverList];
    };
    [_loadingStatus showWithStatus:Loading];
    [self addSubview:_loadingStatus];
    _page = 1;
}

- (void)initUpTopButton{
    //创建返回头部按钮
    CGRect upRect = {self.frame.size.width - 55, self.frame.size.height - 52, 40, 40};
    UIButton *btnUp = [[UIButton alloc] initWithFrame:upRect];
    [btnUp setImage:GetImage(@"icon_up_top") forState:UIControlStateNormal];
    [btnUp addTarget:self action:@selector(backToTop) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnUp];
}
#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier forIndexPath:indexPath];
    cell.navigationController = _navController;
    UserPost *post = [_data objectAtIndex:indexPath.row];
    [cell configureCellForDiscover:post forRowAtIndexPath:indexPath];
    cell.addFoucs = ^(UserPost *post){
        for(UserPost *p in _data) {
            if(p.cd_ci_id == post.cd_ci_id) {
                p.friend_type = post.friend_type;
            }
        }
        [_table reloadData];
    };
    cell.cancelFocus = ^(UserPost *post) {
        for(UserPost *p in _data) {
            if(p.cd_ci_id == post.cd_ci_id) {
                p.friend_type = post.friend_type;
            }
        }
        [_table reloadData];
    };
    cell.viewUserInfo = ^(UserPost *post) {
        UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
        controller.uname = post.ci_nikename;
        controller.uid = post.cd_ci_id;
        [self.navController pushViewController:controller animated:YES];
    };
    cell.viewDynamicInfo = ^(UserPost *post) {
        PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
        postDetailViewController.postID = [NSString stringWithFormat:@"%d", post.cd_id];
        postDetailViewController.userPost = post;
//        postDetailViewController.headerViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        postDetailViewController.commentCount = post.cd_sum_cmi_count;
		postDetailViewController.postDetailFromType = PostDetailFromTypeDiscover;
        UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
        UINavigationController *homeNavController = currentTBC.viewControllers[0];
        [homeNavController pushViewController:postDetailViewController animated:YES];
    };
    return cell;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserPost *post = [_data objectAtIndex:indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:tableCellIdentifier configuration:^(id cell) {
        [((DynamicCell *) cell) configureCellForDiscover:post forRowAtIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	lastSelectedIndexPath = indexPath;
	PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
	UserPost *selectedPost = _data[indexPath.row];
	postDetailViewController.postID = [NSString stringWithFormat:@"%d", selectedPost.cd_id];
	postDetailViewController.userPost = selectedPost;
//	postDetailViewController.headerViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	postDetailViewController.commentCount = selectedPost.cd_sum_cmi_count;
	postDetailViewController.postDetailFromType = PostDetailFromTypeDiscover;
	UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
	UINavigationController *homeNavController = currentTBC.viewControllers[0];
	[homeNavController pushViewController:postDetailViewController animated:YES];
}

#pragma mark - http request
- (void) requestDiscoverList {
    NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *params = @{@"ci_id":uid,@"page":[NSString stringWithFormat:@"%ld",_page],@"rows":DEFAULT_REQUEST_DATA_ROWS, @"random":random};
    [HttpManager requestDiscoverListByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSInteger rtnCode = [responseObject[@"code"] integerValue];
		if (rtnCode == 0) {
			[UserPost setupObjectClassInArray:^NSDictionary *{
				return @{
						 @"pictures" : @"Picture"
						 };
			}];
			NSArray *rows = responseObject[@"result"][@"rows"];
			_total = rows.count;
			if(_total > 0) {
				
				if(_table.header.isRefreshing) {
					[_table.header endRefreshing];
					[_data removeAllObjects];
				} else if(_table.footer.isRefreshing) {
					[_table.footer endRefreshing];
				}
                
                if(!_loadingStatus.hidden) {
                    _loadingStatus.hidden = YES;
                }
				
				for(NSDictionary *item in rows) {
					UserPost *post = [UserPost objectWithKeyValues:item];
					[_data addObject:post];
				}
				[_table reloadData];
				
				//上拉和下拉是否可用
				if(_total >= DEFAULT_REQUEST_DATA_ROWS_INT) {
					_table.footer.hidden = NO;
					_page ++;
				} else {
					_table.footer.hidden = YES;
				}
				
				_table.header.hidden = NO;
				
			} else if (_total == 0) {
				[_loadingStatus showWithStatus:Empty];
                [_loadingStatus setEmptyImage:@"icon_no_dynamic" emptyContent:@"Share with us!" imageSize:NO_DYNAMIC];
			}
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[responseObject objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(_table.header.isRefreshing) {
            [_table.header endRefreshing];
        } else if(_table.footer.isRefreshing){
            [_table.footer endRefreshing];
        }
        
        if(_data.count > 0) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
            [self addSubview:hud];
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = BAD_NETWORK;
            [hud show:YES];
            [hud hide:YES afterDelay:1.5];
        } else {
            if(_loadingStatus.hidden) {
                _loadingStatus.hidden = NO;
            }
            [_loadingStatus showWithStatus:NetErr];
        }
    }];
}

#pragma mark - 上拉加载更多和下拉刷新触发事件
- (void) refresh {
    _page = 1;
    [self requestDiscoverList];
}

- (void) loadMore {
    [self requestDiscoverList];
}

#pragma mark - other functions
- (void)refreshTableView {
	if (lastSelectedIndexPath != nil) {
		[_table reloadRowsAtIndexPaths:@[lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void) addUserPost : (UserPost *) post atIndex:(NSInteger) index {
    [_data insertObject:post atIndex:0];
    [_table reloadData];
    [_table setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void) backToTop {
    [_table setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark - user delete post notification
- (void) userPostDeleted : (NSNotification *) notification {
    int postId = ((NSNumber *)notification.object).intValue;
    NSInteger postIndex = -1;
    for(UserPost *post in _data) {
        if(post.cd_id == postId) {
            postIndex = [_data indexOfObject:post];
            break;
        }
    }
    if(postIndex >= 0) {
        [_data removeObjectAtIndex:postIndex];
        [_table reloadData];
    }
}

@end
