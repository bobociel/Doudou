//
//  MeView.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MeView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "HttpManager.h"
#import "DynamicCell.h"
#import "DynamicCollectionView.h"
#import "UserPost.h"
#import "AppConfigure.h"
#import "PostDetailViewController.h"
#import "PicCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoViewController.h"

// collectionview cell之间的间距
#define COLLECTION_CELL_EDGE 1.5

@interface MeView () <UITableViewDelegate, UITableViewDataSource> {
    ListingLoadingStatusView *_loadingStatus;
}

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *MyPostCellReuseIdentifier = @"MyPostCell";

@implementation MeView {
    NSMutableArray *myPostsArray;
    NSUInteger page;
	NSIndexPath *lastSelectedIndexPath;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        myPostsArray = [[NSMutableArray alloc] init];
        page = 1;
        self.backgroundColor = [UIColor whiteColor];
        
        [self initMyPostsTableView];
        [self initLoadingViews];
    }
    
    return self;
}

- (void)initMyPostsTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 215;
//    self.tableView.fd_debugLogEnabled = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"DynamicCell" bundle:nil] forCellReuseIdentifier:MyPostCellReuseIdentifier];
    [self addSubview:self.tableView];
    [BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshMyPostsList) loadMoreAction:@selector(loadMoreMyPostsList) target:self];
}

- (void)initLoadingViews {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.frame];
    __weak MeView *weakSelf = self;
    __weak ListingLoadingStatusView *weakStatusView = _loadingStatus;
    _loadingStatus.refresh = ^() {
        [weakStatusView showWithStatus:Loading];
        [weakSelf requestMyPosts];
    };
    [self addSubview:_loadingStatus];
    [_loadingStatus showWithStatus:Loading];
    self.tableView.hidden = YES;
    [self requestMyPosts];
}

- (void)requestMyPosts {
    NSString *pageString = [NSString stringWithFormat:@"%lu", page];
    NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[currentUserID, currentUserID, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"ci_id", @"cd_ci_id", @"page", @"rows", @"random"]];
    NSLog(@"request my posts parameters = %@", parameters);
    [HttpManager requestUserPostListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if (rtnCode == 0) {
            [self processMyPostsList:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_loadingStatus showWithStatus:NetErr];
    }];
}

- (void)refreshMyPostsList {
    page = 1;
    [self requestMyPosts];
}

- (void)loadMoreMyPostsList {
    page++;
    [self requestMyPosts];
}

- (void)processMyPostsList:(NSDictionary *)postsDict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSInteger postCount = 0;
		
		[UserPost setupObjectClassInArray:^NSDictionary *{
			return @{@"pictures" : @"Picture",};
		}];
        
        NSArray *postsTempArray = [UserPost objectArrayWithKeyValuesArray:postsDict[@"rows"]];
		postCount = postsTempArray.count;
        if (page == 1) {
            [myPostsArray removeAllObjects];
        }
        [myPostsArray addObjectsFromArray:postsTempArray];
        dispatch_async(dispatch_get_main_queue(), ^(){
            // 还能获取更多数据
            if (postCount >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = NO;
            } else {// 已经获取全部数据
                self.tableView.footer.hidden = YES;
            }
            // 如果列表有数据
            if (myPostsArray.count > 0) {
                [_loadingStatus showWithStatus:Done];
//                self.tableView.header.hidden = NO;
            } else {// 如果列表没有数据
                if (!_loadingStatus.superview) {
                    [self addSubview:_loadingStatus];
                }
                [_loadingStatus showWithStatus:Empty];
                self.tableView.footer.hidden = YES;
//                self.tableView.header.hidden = YES;
                [_loadingStatus setEmptyImage:@"icon_no_dynamic" emptyContent:@"Share with us!" imageSize:NO_DYNAMIC];
            }
            
            if (self.tableView.footer.isRefreshing) {
                [self.tableView.footer endRefreshing];
            }
            if (self.tableView.header.isRefreshing) {
                [self.tableView.header endRefreshing];
            }
            
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        });
    });
}

- (void)deletePost:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *postId = [NSString stringWithFormat:@"%d", post.cd_id];
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[postId, currentUserID] forKeys:@[@"cd_id", @"cd_ci_id"]];
    [HttpManager deleteUserPostByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if (rtnCode == 0) {
            [self userDeletePostForRowAtIndexPath:indexPath];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
		[self showHUDNetError];
    }];
}

- (void)userDeletePostForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserPost *post = myPostsArray[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DELETE_POST object:[NSNumber numberWithInt:post.cd_id]];
    [myPostsArray removeObjectAtIndex:indexPath.row];
	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} completion:^(BOOL finished) {
		[self.tableView reloadData];
        //通知discover，将对应的本地post数据删除
        
		if (myPostsArray.count == 0) {
			if (!_loadingStatus.superview) {
				[self addSubview:_loadingStatus];
			}
			[_loadingStatus showWithStatus:Empty];
		}
	}];
}

- (void)addUserPost:(UserPost *)post atIndex:(NSInteger)index {
	[myPostsArray insertObject:post atIndex:0];
	[_loadingStatus showWithStatus:Done];
	self.tableView.hidden = NO;
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myPostsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:MyPostCellReuseIdentifier];
    cell.navigationController = _navController;
    [cell configureCellForMyPosts:myPostsArray[indexPath.row] forRowAtIndexPath:indexPath];
    cell.deletePost = ^(UserPost *post, NSIndexPath *indexPath){
        [self deletePost:post forRowAtIndexPath:indexPath];
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
		postDetailViewController.postDetailFromType = PostDetailFromTypeMe;
        __weak MeView *weakSelf = self;
        postDetailViewController.deletePost = ^(){
            [weakSelf userDeletePostForRowAtIndexPath:indexPath];
        };
        UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
        UINavigationController *homeNavController = currentTBC.viewControllers[0];
        [homeNavController pushViewController:postDetailViewController animated:YES];
    };
    return cell;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [tableView fd_heightForCellWithIdentifier:MyPostCellReuseIdentifier configuration:^(DynamicCell *cell) {
		[cell configureCellForMyPosts:myPostsArray[indexPath.row] forRowAtIndexPath:indexPath];
	}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	lastSelectedIndexPath = indexPath;
	PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
	UserPost *selectedPost = myPostsArray[indexPath.row];
	postDetailViewController.postID = [NSString stringWithFormat:@"%d", selectedPost.cd_id];
	postDetailViewController.userPost = selectedPost;
//	postDetailViewController.headerViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	postDetailViewController.commentCount = selectedPost.cd_sum_cmi_count;
	postDetailViewController.postDetailFromType = PostDetailFromTypeMe;
	__weak MeView *weakSelf = self;
	postDetailViewController.deletePost = ^(){
		[weakSelf userDeletePostForRowAtIndexPath:lastSelectedIndexPath];
	};
	UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
	UINavigationController *homeNavController = currentTBC.viewControllers[0];
	[homeNavController pushViewController:postDetailViewController animated:YES];
}

#pragma mark - other functions
- (void)refreshTableView {
	[self.tableView reloadData];
}

@end
