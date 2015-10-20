//
//  FollowView.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "FollowView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "HttpManager.h"
#import "DynamicCell.h"
#import "DynamicCollectionView.h"
#import "UserPost.h"
#import "AppConfigure.h"
#import "PostDetailViewController.h"
#import "MBProgressHUD.h"
#import "PicCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoViewController.h"

// collectionview cell之间的间距
#define COLLECTION_CELL_EDGE 1.5

@interface FollowView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;// 菊花

@end

static NSString *MyFollowPostCellReuseIdentifier = @"MyFollowPostCell";

@implementation FollowView {
    NSMutableArray *myFollowPostsArray;
    NSUInteger page;
	NSIndexPath *lastSelectedIndexPath;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:150/255.0 green:100/255.0 blue:200/255.0 alpha:1.0];
        myFollowPostsArray = [[NSMutableArray alloc] init];
        page = 1;
        self.backgroundColor = [UIColor whiteColor];
        
        [self initMyFollowPostsTableView];
        [self initLoadingViews];
    }
    
    return self;
}

- (void)initMyFollowPostsTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 215;
//    self.tableView.fd_debugLogEnabled = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"DynamicCell" bundle:nil] forCellReuseIdentifier:MyFollowPostCellReuseIdentifier];
    [self addSubview:self.tableView];
    [BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshMyFollowPostsList) loadMoreAction:@selector(loadMoreMyFollowPostsList) target:self];
}

- (void)initLoadingViews {
	self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.indicatorView.center = self.center;
	self.indicatorView.hidesWhenStopped = YES;
	[self addSubview:self.indicatorView];
	[self updateHintLabelWithText:@""];
	[self.indicatorView startAnimating];
	
    self.tableView.hidden = YES;
    [self requestMyFollowPosts];
}

- (void)updateHintLabelWithText:(NSString *)text {
	if (!self.hintLabel) {
		self.hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.hintLabel.textColor = NormalTextColor;
		self.hintLabel.textAlignment = NSTextAlignmentCenter;
		self.hintLabel.font = FontNeveLightWithSize(14.0);
		self.hintLabel.numberOfLines = 0;
		[self addSubview:self.hintLabel];
	}
	
	[self bringSubviewToFront:self.hintLabel];
	[self bringSubviewToFront:self.indicatorView];
	
	self.hintLabel.text = text;
	[self.hintLabel sizeToFit];
	CGFloat labelOrignHeight = CGRectGetHeight(self.hintLabel.frame);
	NSInteger labelHeight = (CGRectGetWidth(self.hintLabel.frame) / (SCREEN_WIDTH - 30) + 1) * labelOrignHeight;
//	NSInteger labelY = SCREEN_HEIGHT / 2 - 64 - 49;
	self.hintLabel.frame = CGRectMake(15, 100, SCREEN_WIDTH - 30, labelHeight);
//	self.hintLabel.center = self.center;
	[self.hintLabel setNeedsDisplay];
	[self.indicatorView stopAnimating];
}

- (void)requestMyFollowPosts {
    NSString *pageString = [NSString stringWithFormat:@"%lu", page];
    NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[currentUserID, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"cr_relation_ci_id", @"page", @"rows", @"random"]];
    NSLog(@"request follow posts parameters = %@", parameters);
    [HttpManager requestUserFollowPostListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if (rtnCode == 0) {
            [self processMyFollowPostsList:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
		if(self.tableView.header.isRefreshing) {
			[self.tableView.header endRefreshing];
		} else if(self.tableView.footer.isRefreshing){
			[self.tableView.footer endRefreshing];
		}
		
		if(myFollowPostsArray.count > 0) {
			MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
			[self addSubview:hud];
			hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
			hud.mode = MBProgressHUDModeCustomView;
			hud.labelText = BAD_NETWORK;
			[hud show:YES];
			[hud hide:YES afterDelay:1.5];
		} else {
			[self updateHintLabelWithText:@""];
		}
    }];
}

- (void)refreshMyFollowPostsList {
    page = 1;
    [self requestMyFollowPosts];
}

- (void)loadMoreMyFollowPostsList {
    page++;
    [self requestMyFollowPosts];
}

- (void)processMyFollowPostsList:(NSDictionary *)postsDict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSInteger postCount = 0;
		
		[UserPost setupObjectClassInArray:^NSDictionary *{
			return @{@"pictures" : @"Picture"};
		}];
		
        NSArray *postsTempArray = [UserPost objectArrayWithKeyValuesArray:postsDict[@"rows"]];
		postCount = postsTempArray.count;
        if (page == 1) {
            [myFollowPostsArray removeAllObjects];
        }
        [myFollowPostsArray addObjectsFromArray:postsTempArray];
//        NSLog(@"myFollowPostsArray.count = %ld, totals = %ld", myFollowPostsArray.count, totals);
        dispatch_async(dispatch_get_main_queue(), ^(){
            // 还能获取更多数据
            if (postCount >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = NO;
            } else {// 已经获取全部数据
                self.tableView.footer.hidden = YES;
            }
            // 如果列表有数据
            if (myFollowPostsArray.count > 0) {
                [self updateHintLabelWithText:@""];
                self.tableView.header.hidden = NO;
            } else {// 如果列表没有数据
                [self updateHintLabelWithText:@"You did not follow friend yet. Add new friends and follow their Life in China."];
                self.tableView.footer.hidden = YES;
                self.tableView.header.hidden = YES;
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

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myFollowPostsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:MyFollowPostCellReuseIdentifier];
    cell.navigationController = _navController;
    [cell configureCellForMyFollowPosts:myFollowPostsArray[indexPath.row] forRowAtIndexPath:indexPath];
	cell.addFoucs = ^(UserPost *post){
		for(UserPost *p in myFollowPostsArray) {
			if(p.cd_ci_id == post.cd_ci_id) {
				p.friend_type = post.friend_type;
			}
		}
		[self.tableView reloadData];
	};
	cell.cancelFocus = ^(UserPost *post) {
		for(UserPost *p in myFollowPostsArray) {
			if(p.cd_ci_id == post.cd_ci_id) {
				p.friend_type = post.friend_type;
			}
		}
		[self.tableView reloadData];
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
		postDetailViewController.postDetailFromType = PostDetailFromTypeFollow;
        UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
        UINavigationController *homeNavController = currentTBC.viewControllers[0];
        [homeNavController pushViewController:postDetailViewController animated:YES];
    };
    return cell;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return  [tableView fd_heightForCellWithIdentifier:MyFollowPostCellReuseIdentifier configuration:^(DynamicCell *cell) {
		[cell configureCellForMyFollowPosts:myFollowPostsArray[indexPath.row] forRowAtIndexPath:indexPath];
	}] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSLog(@"indexPath.row = %ld", indexPath.row);
	lastSelectedIndexPath = indexPath;
	PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
	UserPost *selectedPost = myFollowPostsArray[indexPath.row];
	postDetailViewController.postID = [NSString stringWithFormat:@"%d", selectedPost.cd_id];
	postDetailViewController.userPost = selectedPost;
//	postDetailViewController.headerViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	postDetailViewController.commentCount = selectedPost.cd_sum_cmi_count;
	postDetailViewController.postDetailFromType = PostDetailFromTypeFollow;
	UITabBarController *currentTBC = (UITabBarController *)self.window.rootViewController;
	UINavigationController *homeNavController = currentTBC.viewControllers[0];
	[homeNavController pushViewController:postDetailViewController animated:YES];
}

#pragma mark - other functions
- (void)refreshTableView {
	if (lastSelectedIndexPath != nil) {
		[self.tableView reloadRowsAtIndexPaths:@[lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

@end
