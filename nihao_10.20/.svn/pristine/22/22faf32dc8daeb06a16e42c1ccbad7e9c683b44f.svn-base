//
//  TopView.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TopView.h"
#import "TopUserHeaderView.h"
#import "TopUserCell.h"
#import "Constants.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "TopUser.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "ListingLoadingStatusView.h"
#import "BaseFunction.h"
#import "MBProgressHUD.h"
#import "UserInfoViewController.h"

@interface TopView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    ListingLoadingStatusView *_loadingStatus;
    NSInteger _pageSize;
}

@property (nonatomic, strong) UICollectionView *usersCollectionView;
@property (nonatomic, strong) TopUserHeaderView *topUserHeaderView;

@end

static NSString *UserCellReuseIdentifier = @"TopUserCell";
static NSString *TopUserHeaderReuseIdentifier = @"TopUserHeaderView";

@implementation TopView {
    NSMutableArray *topUserArray;
    CGFloat userItemWidth;
    NSUInteger page;
	NSIndexPath *lastSelectedIndexPath;
}

static const NSUInteger DEFAULT_ROWS = 18;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        topUserArray = [[NSMutableArray alloc] init];
        userItemWidth = (CGRectGetWidth(frame) - 20 - 30) / 3.0;
        page = 1;
        self.backgroundColor = RootBackgroundColor;
        [self initLoadingViews];
    }
    
    return self;
}

- (void)initLoadingViews {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.frame];
    __weak TopView *weakSelf = self;
    _loadingStatus.refresh = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestTopUsers];
    };
    [self addSubview:_loadingStatus];
    [_loadingStatus showWithStatus:Loading];
    self.usersCollectionView.hidden = YES;
    [self requestTopUsers];
}

- (void)initUserCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(userItemWidth, 140);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 230);
    self.usersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.frame) - 30, CGRectGetHeight(self.frame)) collectionViewLayout:layout];
    self.usersCollectionView.delegate = self;
    self.usersCollectionView.dataSource = self;
    self.usersCollectionView.alwaysBounceVertical = YES;
    self.usersCollectionView.alwaysBounceHorizontal = NO;
    self.usersCollectionView.showsVerticalScrollIndicator = NO;
    [self.usersCollectionView registerNib:[UINib nibWithNibName:@"TopUserCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:UserCellReuseIdentifier];
    [self.usersCollectionView registerClass:[TopUserHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TopUserHeaderReuseIdentifier];
    self.usersCollectionView.backgroundColor = RootBackgroundColor;
	self.usersCollectionView.hidden = YES;
    [self addSubview:self.usersCollectionView];
    [BaseFunction addRefreshHeaderAndFooter:self.usersCollectionView refreshAction:@selector(refreshTopUserList) loadMoreAction:@selector(loadMoreTopUserList) target:self];
}

// 获取用户列表
- (void)requestTopUsers {
    NSString *userID = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSString *pageString = [NSString stringWithFormat:@"%lu", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    
    /*int rows = DEFAULT_REQUEST_DATA_ROWS_INT;
    if(page == 1) {
        rows = 18;
    } else {
        rows = (topUserArray.count % DEFAULT_REQUEST_DATA_ROWS_INT == 0) ? DEFAULT_REQUEST_DATA_ROWS_INT : (DEFAULT_REQUEST_DATA_ROWS_INT - topUserArray.count % DEFAULT_REQUEST_DATA_ROWS_INT);
    }*/
    int rows = DEFAULT_ROWS;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[userID, pageString, [NSString stringWithFormat:@"%d",rows], random] forKeys:@[@"ci_id", @"page", @"rows", @"random"]];
    NSLog(@"request top users parameters = %@", parameters);
    [HttpManager requestTopUserListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        //NSLog(@"%@",resultDict);
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if (rtnCode == 0) {
            [self processTopUserList:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
		if(self.usersCollectionView.header.isRefreshing) {
			[self.usersCollectionView.header endRefreshing];
		} else if(self.usersCollectionView.footer.isRefreshing){
			[self.usersCollectionView.footer endRefreshing];
		}
		
		if(topUserArray.count > 0) {
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

- (void)processTopUserList:(NSDictionary *)topUsers {
    NSInteger usersCount = 0;
    NSArray *users = [TopUser objectArrayWithKeyValuesArray:topUsers[@"rows"]];
    usersCount = users.count;
    if (page == 1) {
        [topUserArray removeAllObjects];
    }
    [topUserArray addObjectsFromArray:users];
    if (!self.usersCollectionView) {
        [self initUserCollectionView];
    }
    // 还能获取更多数据
    if (usersCount >= DEFAULT_ROWS) {
        self.usersCollectionView.footer.hidden = NO;
    } else {// 已经获取全部数据
        self.usersCollectionView.footer.hidden = YES;
    }
    // 如果列表有数据
    if (topUserArray.count > 0) {
        [_loadingStatus showWithStatus:Done];
        self.usersCollectionView.header.hidden = NO;
    } else {// 如果列表没有数据
        if (!_loadingStatus.superview) {
            [self addSubview:_loadingStatus];
        }
        [_loadingStatus showWithStatus:Empty];
        self.usersCollectionView.footer.hidden = YES;
        self.usersCollectionView.header.hidden = YES;
        [_loadingStatus setEmptyImage:@"icon_no_dynamic" emptyContent:@"Share with us!" imageSize:NO_DYNAMIC];
    }
    
    if (self.usersCollectionView.footer.isRefreshing) {
        [self.usersCollectionView.footer endRefreshing];
    }
    if (self.usersCollectionView.header.isRefreshing) {
        [self.usersCollectionView.header endRefreshing];
    }
    
    self.usersCollectionView.hidden = NO;
    [self.usersCollectionView reloadData];
}

- (void)refreshTopUserList {
    page = 1;
    [self requestTopUsers];
}

- (void)loadMoreTopUserList {
    page++;
    [self requestTopUsers];
}

- (void)changingRelationWithUserIndex:(NSInteger)userIndex followStatus:(BOOL)followStatus {
    TopUser *toUser = topUserArray[userIndex];
    NSString *myUserID = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSString *toUserID = [NSString stringWithFormat:@"%d", toUser.ca_ci_id];
    if (followStatus) {// 关注
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
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showHUDNetError];
        }];
    } else {// 取消关注
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
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
			[self showHUDNetError];
        }];
    }
}

- (void)refreshTopView {
	if (lastSelectedIndexPath != nil) {
		[self.usersCollectionView reloadItemsAtIndexPaths:@[lastSelectedIndexPath]];
	}
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return topUserArray.count - 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TopUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UserCellReuseIdentifier forIndexPath:indexPath];
    [cell configureCellWithUserInfo:topUserArray[indexPath.row + 3] forRowAtIndexPath:indexPath];
    cell.followUserForRowAtIndexPath = ^(NSIndexPath *indexPath, BOOL isFollow) {
        [self changingRelationWithUserIndex:(indexPath.row + 3) followStatus:isFollow];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	lastSelectedIndexPath = indexPath;
    //查看用户详情
    TopUser *user = topUserArray[indexPath.row + 3];
    UserInfoViewController *userViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    userViewController.uid = user.ca_ci_id;
    userViewController.uname = user.ci_nikename;
    [_navigationController pushViewController:userViewController animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
		self.topUserHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TopUserHeaderReuseIdentifier forIndexPath:indexPath];
		NSArray *topThreeUsers;
        if (topUserArray.count >= 3) {
            topThreeUsers = [NSArray arrayWithObjects:topUserArray[0], topUserArray[1], topUserArray[2], nil];
        } else {
			topThreeUsers = [NSArray arrayWithArray:topUserArray];
		}
		
		[self.topUserHeaderView configureHeaderViewWithUsersInfo:topThreeUsers];
		self.topUserHeaderView.navigationController = _navigationController;
		__weak TopView *weakSelf = self;
		self.topUserHeaderView.followUserForRowAtIndexPath = ^(NSInteger userIndex, BOOL isFollow) {
			[weakSelf changingRelationWithUserIndex:userIndex followStatus:isFollow];
		};
		
		reusableview = self.topUserHeaderView;
    }
	
    return reusableview;
}

@end
