
//
//  PeopleYouMayKnowViewController.m
//  nihao
//
//  Created by 刘志 on 15/9/18.
//  Copyright © 2015年 jiazhong. All rights reserved.
//

#import "PeopleYouMayKnowViewController.h"
#import "BaseFunction.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "UserFollowListCell.h"
#import "FilterViewController.h"
#import "Nationality.h"
#import "ListingLoadingStatusView.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "FollowUser.h"
#import "UserInfoViewController.h"

@interface PeopleYouMayKnowViewController ()<UITableViewDelegate,UITableViewDataSource,SetFilterDelegate,UserFollowListCellDelegate> {
    NSMutableArray *_data;
    NSUInteger _page;
    
    //filter
    BOOL _all;
    Nationality *_nationality;
    NSInteger _gender;
    NSString *_city;
    
    ListingLoadingStatusView *_statusView;
}

@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation PeopleYouMayKnowViewController

static NSString *const identifier = @"UserListIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"People you may know";
    [self dontShowBackButtonTitle];
    [self addFilterButton];
    [self initTableView];
    [self initFilter];
    [self initLoadingViews];
    [self requestUserList];
}

- (void) addFilterButton {
    // 设置导航栏按钮的点击执行方法等
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterClick)];
    NSArray *rightButtonItems = @[filterItem];
    self.navigationItem.rightBarButtonItems = rightButtonItems;
}

- (void) initTableView {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_filterView.frame) - 0.5, SCREEN_WIDTH, 0.5)];
    seperator.backgroundColor = SeparatorColor;
    [_filterView addSubview:seperator];
    
    [_table registerNib:[UINib nibWithNibName:@"UserFollowListCell" bundle:nil] forCellReuseIdentifier:identifier];
    _table.tableFooterView = [[UIView alloc] init];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(requestUserList) loadMoreAction:@selector(requestUserList) target:self];
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    _data = [NSMutableArray array];
    _page = 1;
}

- (void)initLoadingViews {
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_filterView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_filterView.frame) - 64)];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^() {
        [weakSelf requestUserList];
    };
    [self.view addSubview:_statusView];
    [_statusView showWithStatus:Loading];
}

- (void) initFilter {
    _all = YES;
    _gender = -1;
    UILabel *allFilterLabel = [self createFilterLabel:@"All"];
    allFilterLabel.frame = CGRectMake(15, 5, CGRectGetWidth(allFilterLabel.frame) + 20, 30);
    [_filterView addSubview:allFilterLabel];
}

- (UILabel *) createFilterLabel : (NSString *) filter{
    UILabel *label = [[UILabel alloc] init];
    label.text = filter;
    label.textColor = ColorWithRGB(120, 120, 120);
    label.font = FontNeveLightWithSize(12.0);
    label.backgroundColor = ColorWithRGB(240, 240, 240);
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FollowUser *user = _data[indexPath.row];
    UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    controller.uid = user.ci_id;
    controller.uname = user.ci_nikename;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserFollowListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    FollowUser *user = _data[indexPath.row];
    [cell configureCellWithUserInfo:user forRowAtIndexPath:indexPath withUserFollowListType:user.friend_type withOwnerUserID:nil];
    cell.delegate = self;
    return cell;
}

#pragma mark - net work
- (void) requestUserList {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *uid = [NSString stringWithFormat:@"%lu",[AppConfigure integerForKey:LOGINED_USER_ID]];
    [params setObject:uid forKey:@"ci_id"];
    if(_all) {
        [params setObject:@"5" forKey:@"recommendType"];
    } else {
        [params setObject:@"6" forKey:@"recommendType"];
        if(_gender == 1) {
           [params setObject:@"1" forKey:@"ci_sex"];
        } else if(_gender == 0) {
           [params setObject:@"0" forKey:@"ci_sex"];
        }
        if(!IsStringEmpty(_city)) {
           [params setObject:_city forKey:@"ci_city_id"];
        }
        if(_nationality) {
           [params setObject:[NSString stringWithFormat:@"%lu",_nationality.country_id] forKey:@"ci_country_id"];
        }
    }
    NSUInteger page = _page;
    if(_table.header.isRefreshing) {
        page = 1;
    }
    [params setObject:[NSString stringWithFormat:@"%ld",page] forKey:@"page"];
    [params setObject:DEFAULT_REQUEST_DATA_ROWS forKey:@"rows"];
    NSLog(@"%@",params);
    [HttpManager getRecommendUserListByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self endRefresh];
        _statusView.hidden = YES;
        NSInteger rtnCode = [responseObject[@"code"] integerValue];
        if(rtnCode == 0) {
            NSArray *userArray = [FollowUser objectArrayWithKeyValuesArray:responseObject[@"result"][@"rows"]];
            //刷新数据处理
            if(page == 1) {
                _page = 1;
                [_data removeAllObjects];
            }
            [_data addObjectsFromArray:userArray];
            //数据为空
            if(_data.count == 0) {
                _statusView.hidden = NO;
                [_statusView showWithStatus:Empty];
            }
            //列表加载更多处理
            if(userArray.count == 0 || _data.count < DEFAULT_REQUEST_DATA_ROWS_INT) {
                _table.footer.hidden = YES;
            } else {
                _table.footer.hidden = NO;
            }
            [_table reloadData];
            _table.header.hidden = NO;
            _page++;
        } else {
            [self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
            if(_data.count == 0) {
                [_statusView showWithStatus:NetErr];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(_data.count > 0) {
            [self showHUDNetError];
        } else {
            [_statusView showWithStatus:NetErr];
        }
    }];
}

- (void) endRefresh {
    [_table.header endRefreshing];
    [_table.footer endRefreshing];
}

- (void)processServerErrorWithCode:(NSInteger)code andErrorMsg:(NSString *)msg {
    if (code == 500) {
        [self showHUDServerError];
    } else {
        [self showHUDErrorWithText:msg];
    }
}

#pragma mark - UserFollowListCellDelegate
- (void)userFollowListCellClickFollowBtnAtIndexPath:(NSIndexPath *)indexPath {
    FollowUser *toUser = _data[indexPath.row];
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
                [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}


#pragma mark - click events 
- (void) filterClick {
    FilterViewController *controller = [[FilterViewController alloc] init];
    controller.all = _all;
    controller.gender = _gender;
    controller.nationality = _nationality;
    controller.city = _city;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) setFilter :(BOOL) all gender : (NSInteger) gender city : (NSString *) city nationality : (Nationality *) nationality {
    for(UIView *view in _filterView.subviews) {
        if([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    _all = all;
    _city = city;
    _nationality = nationality;
    _gender = gender;
    
    if(_all) {
        UILabel *allFilterLabel = [self createFilterLabel:@"All"];
        allFilterLabel.frame = CGRectMake(15, 5, CGRectGetWidth(allFilterLabel.frame) + 20, 30);
        [_filterView addSubview:allFilterLabel];
    } else {
        NSMutableArray *array = [NSMutableArray array];
        if(gender == 0) {
            [array addObject:@"Female"];
        } else if(gender == 1) {
            [array addObject:@"Male"];
        }
        
        if(!IsStringEmpty(_city)) {
            [array addObject:_city];
        }
        
        if(_nationality) {
            [array addObject:_nationality.country_name_en];
        }
        
        if(array.count == 0) {
            UILabel *allFilterLabel = [self createFilterLabel:@"All"];
            allFilterLabel.frame = CGRectMake(15, 5, CGRectGetWidth(allFilterLabel.frame) + 20, 30);
            [_filterView addSubview:allFilterLabel];
        } else {
            CGFloat maxX = 0;
            for(NSString *filter in array) {
                UILabel *label = [self createFilterLabel:filter];
                label.frame = CGRectMake(15 + maxX, 5, CGRectGetWidth(label.frame) + 20, 30);
                maxX = CGRectGetMaxX(label.frame);
                [_filterView addSubview:label];
            }
        }
    }
    _page = 1;
    _table.header.hidden = YES;
    _table.footer.hidden = YES;
    _statusView.hidden = NO;
    [_statusView showWithStatus:Loading];
    [self requestUserList];
}

@end
