//
//  UserFollowListViewController.m
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "UserFollowListViewController.h"
#import "ListingLoadingStatusView.h"
#import "UserFollowListCell.h"
#import "HttpManager.h"
#import "FollowUser.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "UserInfoViewController.h"

@interface UserFollowListViewController () <UITableViewDelegate, UITableViewDataSource, UserFollowListCellDelegate> {
	ListingLoadingStatusView *_loadingStatus;
    BOOL _executeOnce;
}

@property (strong, nonatomic) UITableView *tableView;

@end

static NSString *FollowCellReuseIdentifier = @"FollowTableViewCell";
static NSString *FollowerCellReuseIdentifier = @"FollowerTableViewCell";

@implementation UserFollowListViewController {
	NSMutableArray *userList;
	NSInteger page;
//	BOOL isChanged;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self dontShowBackButtonTitle];
    // Do any additional setup after loading the view.
	if (IsStringNotEmpty(self.userID)) {
		if (self.userFollowListType == UserFollowListTypeFollow) {
//			if ([self.userID isEqualToString:[AppConfigure valueForKey:LOGINED_USER_ID]]) {
//				self.title = @"I Follow";
//			} else {
//				self.title = @"Following";
//			}
			self.title = @"Following";
		} else if (self.userFollowListType == UserFollowListTypeFollower) {
			self.title = @"Followers";
		}
		
		[self initDatas];
		[self initViews];
		[self initLoadingViews];
        _executeOnce = YES;
		[self requestUserList];
	}
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDatas {
	userList = [[NSMutableArray alloc] init];
	page = 1;
//	isChanged = NO;
}

- (void)initViews {
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 71;
	self.tableView.tableFooterView = [[UIView alloc] init];
	if (self.userFollowListType == UserFollowListTypeFollow) {
		[self.tableView registerNib:[UINib nibWithNibName:@"UserFollowListCell" bundle:nil] forCellReuseIdentifier:FollowCellReuseIdentifier];
	} else if (self.userFollowListType == UserFollowListTypeFollower) {
		[self.tableView registerNib:[UINib nibWithNibName:@"UserFollowListCell" bundle:nil] forCellReuseIdentifier:FollowerCellReuseIdentifier];
	}
	
	[self.view addSubview:self.tableView];
	
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshUserList) loadMoreAction:@selector(loadMoreUserList) target:self];
	self.tableView.footer.hidden = YES;
}

- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.view.bounds];
	__weak UserFollowListViewController *weakSelf = self;
	_loadingStatus.refresh = ^() {
		__strong UserFollowListViewController *strongSelf = weakSelf;
		[strongSelf requestUserList];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
	self.tableView.hidden = YES;
}

#pragma mark - networking
- (void)requestUserList {
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSString *myUserID = [AppConfigure objectForKey:LOGINED_USER_ID];
	if (self.userFollowListType == UserFollowListTypeFollow) {
		NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.userID, myUserID, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"cr_relation_ci_id", @"ci_id", @"page", @"rows", @"random"]];
		[HttpManager requestUserFollowListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *resultDict = (NSDictionary *)responseObject;
			NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
			if (rtnCode == 0) {
				[self processUserList:resultDict[@"result"][@"rows"]];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
			[_loadingStatus showWithStatus:NetErr];
		}];
	} else if (self.userFollowListType == UserFollowListTypeFollower) {
		NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.userID, myUserID, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"cr_by_ci_id", @"ci_id", @"page", @"rows", @"random"]];
		[HttpManager requestUserFollowerListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *resultDict = (NSDictionary *)responseObject;
            NSLog(@"%@",resultDict);
			NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
			if (rtnCode == 0) {
                if(_executeOnce) {
                    _executeOnce = NO;
                    if(_delegate) {
                        [_delegate clearNewFollowsRedPoint];
                    }
                }
				[self processUserList:responseObject[@"result"][@"rows"]];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
			[_loadingStatus showWithStatus:NetErr];
		}];
	}
}

- (void)processUserList:(NSArray *)users {
	NSArray *tempArray = [FollowUser objectArrayWithKeyValuesArray:users];
	if (page == 1) {
		[userList removeAllObjects];
	}
	[userList addObjectsFromArray:tempArray];
	NSLog(@"userList.count = %ld", userList.count);
	
	if (tempArray.count < DEFAULT_REQUEST_DATA_ROWS_INT) {// 没有更多数据
		self.tableView.footer.hidden = YES;
	} else {
		self.tableView.footer.hidden = NO;
	}
	if (userList.count > 0) {
		self.tableView.hidden = NO;
		[_loadingStatus showWithStatus:Done];
	} else {
		self.tableView.hidden = YES;
		[_loadingStatus showWithStatus:Empty];
        if(self.userFollowListType == UserFollowListTypeFollow) {
            [_loadingStatus setEmptyImage:@"icon_no_contact" emptyContent:@"Find new people and follow their Life in China" imageSize:NO_CONTACT];
        } else if(self.userFollowListType == UserFollowListTypeFollower) {
            [_loadingStatus setEmptyImage:@"icon_no_contact" emptyContent:@"Be more active to get followers" imageSize:NO_CONTACT];
        }
	}
	
	if (self.tableView.footer.isRefreshing) {
		[self.tableView.footer endRefreshing];
	}
	if (self.tableView.header.isRefreshing) {
		[self.tableView.header endRefreshing];
	}
	
	[self.tableView reloadData];
}

- (void)refreshUserList {
	page = 1;
	[self requestUserList];
}

- (void)loadMoreUserList {
	page++;
	[self requestUserList];
}

#pragma mark - click events
//- (void)addFollowUser {
//	
//}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserFollowListCell *cell;
	if (self.userFollowListType == UserFollowListTypeFollow) {
		cell = (UserFollowListCell  *)[tableView dequeueReusableCellWithIdentifier:FollowCellReuseIdentifier forIndexPath:indexPath];
	} else if (self.userFollowListType == UserFollowListTypeFollower) {
		cell = (UserFollowListCell  *)[tableView dequeueReusableCellWithIdentifier:FollowerCellReuseIdentifier forIndexPath:indexPath];
	}
	
	if (cell) {
		FollowUser *user = userList[indexPath.row];
		
		if (user) {
			[cell configureCellWithUserInfo:user forRowAtIndexPath:indexPath withUserFollowListType:self.userFollowListType withOwnerUserID:self.userID];
			cell.delegate = self;
			
			return cell;
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    FollowUser *user = userList[indexPath.row];
    UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    controller.uid = user.ci_id;
    controller.uname = user.ci_nikename;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UserFollowListCellDelegate
- (void)userFollowListCellClickFollowBtnAtIndexPath:(NSIndexPath *)indexPath {
	FollowUser *toUser = userList[indexPath.row];
	NSLog(@"toUser.friend_type = %d", toUser.friend_type);
	NSString *myUserID = [AppConfigure objectForKey:LOGINED_USER_ID];
	NSString *toUserID = [NSString stringWithFormat:@"%d", toUser.ci_id];
	
	if (toUser.friend_type == UserFriendTypeFriend || toUser.friend_type == UserFriendTypeFollowed) {// 已关注，点击想要取消关注
		[self showHUDWithText:@"Unfollowing"];
		[HttpManager removeRelationBySelfUserID:myUserID toPeerUserID:toUserID success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *resultDict = (NSDictionary *)responseObject;
			NSInteger rtnCode = [resultDict[@"code"] integerValue];
			if (rtnCode == 0) {
				// 取消关注成功
				//                NSLog(@"unfollow success");
				if (toUser.friend_type == 2) {
					toUser.friend_type = 1;
				} else if (toUser.friend_type == 4) {
					toUser.friend_type = 3;
				}
				//                NSLog(@"2---user = %@", toUser);
				[self showHUDDoneWithText:@"Unfollowed"];
//				isChanged = YES;
				[AppConfigure setValue:@"YES" forKey:ME_SHOULD_REFRESH];
				[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
		}];
	} else {// 未关注，点击想要关注
		[self showHUDWithText:@"Following"];
		[HttpManager addRelationBySelfUserID:myUserID toPeerUserID:toUserID success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *resultDict = (NSDictionary *)responseObject;
			NSInteger rtnCode = [resultDict[@"code"] integerValue];
			if (rtnCode == 0) {
				// 关注成功
				//                NSLog(@"follow success");
				if (toUser.friend_type == 1) {
					toUser.friend_type = 2;
				} else if (toUser.friend_type == 3) {
					toUser.friend_type = 4;
				}
				//                NSLog(@"1---user = %@", toUser);
				[self showHUDDoneWithText:@"Followed"];
				[AppConfigure setValue:@"YES" forKey:ME_SHOULD_REFRESH];
				[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
		}];
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
