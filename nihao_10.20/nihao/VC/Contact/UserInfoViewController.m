//
//  UserInfoViewController.m
//  nihao
//
//  Created by 刘志 on 15/7/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <DTCoreText.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import "UserInfoViewController.h"
#import "SettingMenu.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "UserFollowListViewController.h"
#import "ChatViewController.h"
#import "BaseFunction.h"
#import "NihaoContact.h"
#import "ContactDao.h"
#import "PlaceholderTextView.h"
#import "SendFriendRequestViewController.h"
#import "DismissingAnimator.h"
#import "PresentingAnimator.h"
#import "ReportViewController.h"
#import "MWPhotoBrowser.h"
#import "UserInfoHeader.h"
#import "ListingLoadingStatusView.h"
#import "UserInfoDynamicTableViewCell.h"
#import "UserPost.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PostDetailViewController.h"
#import "UserBaseInfoViewController.h"
#import "UserMoreViewController.h"

//图片点击类型，头像被点击，post里的图片被点击
typedef NS_ENUM(NSInteger, PhotoClickType) {
    USER_LOGO = 0,
    USER_POST,
};

@interface UserInfoViewController () <ChatViewControllerDelegate,UIViewControllerTransitioningDelegate,MWPhotoBrowserDelegate,UITableViewDelegate,UITableViewDataSource,UserInfoHeaderClickDelegate,PostPhotoBrowerClickDelegate> {
    SettingMenu *_menu;
    //环信聊天的用户名
    NSString *_chatUserName;

    //当前用户和登录用户的关系
    NSInteger _relation;
    NihaoContact *_contact;
    NSString *_birthday;
    
    NSString *userIconURLString;
    NSString *selfIconURLString;

    MWPhotoBrowser *photoBrowser;
    
    ListingLoadingStatusView *_loadingStatus;
    
    UserInfoHeader *_userInfoHeader;
    
    NSMutableArray *_postData;
    NSInteger _page;
    NSInteger _photoClickType;
    UserPost *_userPost;
    NSUInteger _postClickPhotoIndex;
    
    NSInteger _followersCount;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *followStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *followStatusLabel;
- (IBAction)chat:(id)sender;
- (IBAction)followActions:(id)sender;

@end

@implementation UserInfoViewController

static NSString *const UserInfoDynamicTableViewCellIdentifier = @"UserInfoDynamicTableViewCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _uname;
    [self dontShowBackButtonTitle];
    [self addSettingMenu];
    [self initLoadingStatusView];
    [self hideBottomView];
	selfIconURLString = [BaseFunction convertServerImageURLToURLString:[AppConfigure objectForKey:LOGINED_USER_ICON_URL]];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reqUserInfo];
    [self initTableView];
    [self requestUserPost];
    [self.tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - init views

- (void) addSettingMenu {
    UIButton *button = [self createNavBtnByTitle:nil icon:@"icon_menu" action:@selector(menuClick)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -20;
    self.navigationItem.rightBarButtonItems = @[spacerButton,barButton];
}

- (void) initTableView {
    _postData = [NSMutableArray array];
    _page = 1;
    _tableView.tableFooterView = [[UIView alloc] init];
    _userInfoHeader = [[UserInfoHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 138)];
    _tableView.tableHeaderView = _userInfoHeader;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [BaseFunction addRefreshHeaderAndFooter:_tableView refreshAction:nil loadMoreAction:@selector(requestUserPost) target:nil];
    _tableView.header.hidden = YES;
    _tableView.footer.hidden = YES;
    [_tableView registerNib:[UINib nibWithNibName:@"UserInfoDynamicTableViewCell" bundle:nil] forCellReuseIdentifier:UserInfoDynamicTableViewCellIdentifier];
    _tableView.backgroundColor = ColorWithRGB(244, 244, 244);
    self.view.backgroundColor = ColorWithRGB(244, 244, 244);
    
    UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_bottomView.frame) / 2 - 0.5, 0, 0.5, CGRectGetHeight(_bottomView.frame))];
    middleLine.backgroundColor = SeparatorColor;
    [_bottomView addSubview:middleLine];
}

- (void) initLoadingStatusView {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak typeof(self) weakSelf = self;
    __weak typeof(_loadingStatus) weakStatus = _loadingStatus;
    _loadingStatus.refresh = ^ {
        __strong typeof(self) strongSelf = weakSelf;
        __strong typeof(weakStatus) strongStatus = weakStatus;
        [strongStatus showWithStatus:Loading];
        [strongSelf reqUserInfo];
        [strongSelf requestUserPost];
    };
    [self.view addSubview:_loadingStatus];
}

/**
 *  如果是登录用户查看自己的用户信息，需要将底部的关注和聊天按钮去掉
 */
- (void) hideBottomView {
    if([AppConfigure integerForKey:LOGINED_USER_ID] == _uid) {
        [_bottomView removeFromSuperview];
        _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        [_tableView removeConstraints:_tableView.constraints];
        _tableView.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

- (void) showPhotoBrower {
    photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //设置浏览图片的navigationbar为蓝色
    photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    photoBrowser.displayActionButton = NO;
    photoBrowser.enableGrid = NO;
    // Manipulate
    [photoBrowser showNextPhotoAnimated:YES];
    [photoBrowser showPreviousPhotoAnimated:YES];
    if(_photoClickType == USER_POST) {
        [photoBrowser setCurrentPhotoIndex:_postClickPhotoIndex];
    }
    // Present
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

#pragma mark - click events

- (void) followingTouched {
    [self openFollowListVCByType:UserFollowListTypeFollow];
}

- (void) followersTouched {
    [self openFollowListVCByType:UserFollowListTypeFollower];
}

- (void) userLogoTouched {
    _photoClickType = USER_LOGO;
    [self showPhotoBrower];
}

- (void) userBaseInfoTouched {
    //进入用户基本信息页面
    UserBaseInfoViewController *baseInfoController = [[UserBaseInfoViewController alloc] init];
    baseInfoController.nickname = _contact.ci_nikename;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
    NSDate *date = [formatter dateFromString:_birthday];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSString *month = [BaseFunction getMonth:components.month];
    NSString *birthday = [NSString stringWithFormat:@"%@ %ldth",month,components.day];
    baseInfoController.birthday = birthday;
    NSString *nationality = IsStringEmpty(_contact.country_name_en) ? @"Unknown" : _contact.country_name_en;
    baseInfoController.nationality = nationality;
    baseInfoController.region = IsStringEmpty(_contact.city_name_en) ? @"Unknown" : _contact.city_name_en;
    [self.navigationController pushViewController:baseInfoController animated:YES];
}

- (IBAction)chat:(id)sender {
    [self chatWithThisUser];
}

- (IBAction)followActions:(id)sender {
    if(_relation == UserFriendTypeNone || _relation == UserFriendTypeFollower) {
        [self followUser:_contact];
    } else {
        [self unFollowUser:_contact];
    }
}

- (void) menuClick {
//    if(!_menu) {
//        return;
//    }
//    if(_menu.hidden) {
//        [_menu showInView:self.view];
//    } else {
//        [_menu dismiss];
//    }
    
    UserMoreViewController *userMoreViewController = [[UserMoreViewController alloc] init];
    userMoreViewController.contact = _contact;
    userMoreViewController.uid = _uid;
    
    [self.navigationController pushViewController:userMoreViewController animated:YES];
}

/**
 *  查看对方的follow list或者follower list
 *
 *  @param type follow or follower
 */
- (void)openFollowListVCByType:(UserFollowListType)type {
	UserFollowListViewController *userFollowListViewController = [[UserFollowListViewController alloc] init];
	userFollowListViewController.userFollowListType = type;
	userFollowListViewController.userID = [NSString stringWithFormat:@"%ld",_uid];
	[self.navigationController pushViewController:userFollowListViewController animated:YES];
}

/**
 *  与对方聊天
 */
- (void)chatWithThisUser {
	if (IsStringNotEmpty(_chatUserName)) {
		if (self.userInfoFrom == UserInfoFromChat) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_chatUserName conversationType:eConversationTypeChat];
			ChatViewController *chatViewController = [[ChatViewController alloc] initWithChatter:_chatUserName conversationType:conversation.conversationType];
			chatViewController.delelgate = self;
            chatViewController.title = _contact.ci_nikename;
			chatViewController.chatterUserID = self.uid;
            chatViewController.chatterUserName=_contact.ci_username;
           // NSLog( @"==USERINFO ==%@",_contact.ci_header_img );
			[self.navigationController pushViewController:chatViewController animated:YES];
		}
	}
}

/**
 *  放入黑名单
 *
 *  @param contact
 */
- (void) putInBlackList : (NihaoContact *) contact {
    
}

/**
 *  更改用户备注
 *
 *  @param contact
 */
- (void) changeUserBackup : (NihaoContact *) contact {
    
}

/**
 *  举报
 */
- (void) report {
    ReportViewController *reportViewController = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    reportViewController.userId = _contact.ci_id;
    [self.navigationController pushViewController:reportViewController animated:YES];
}

#pragma mark - 网络请求
- (void) reqUserInfo {
    NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSDictionary *params = @{@"by_ci_id":[NSString stringWithFormat:@"%ld",_uid],@"ci_id":loginUid};
    [HttpManager requestUserInfo:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(_tableView.hidden == YES) {
            _tableView.hidden = NO;
        }
        if([responseObject[@"code"] integerValue] == 0) {
            NSDictionary *result = responseObject[@"result"];
            _chatUserName = result[@"ci_username"];
            
            userIconURLString = result[@"ci_header_img"];
            
            //用户年龄
            if([result.allKeys containsObject:@"ci_birthday"]) {
                _birthday = result[@"ci_birthday"];
            } else {
                _birthday = @"Unknown";
            }
            
            //设置列表头部用户信息
            _followersCount = [result[@"byCount"] integerValue];
            [_userInfoHeader configureUserInfo:responseObject];
            _userInfoHeader.delegate = self;
            
            NSLog(@"result===%@",result);
            
            //用户关系
            _menu = [[SettingMenu alloc] init];
            __weak typeof(self) weakSelf = self;
            _relation = [result[@"friend_type"] integerValue];
            NihaoContact *contact = [[NihaoContact alloc] init];
            contact.ci_nikename = result[@"ci_nikename"];
            contact.ci_header_img = result[@"ci_header_img"];
            contact.ci_sex = [result[@"ci_sex"] integerValue];
            contact.ci_username = result[@"ci_username"];
            contact.ci_id = [result[@"ci_id"] integerValue];
            contact.ci_type = [result[@"ci_type"] integerValue];
            contact.country_name_en = result[@"country_name_en"];
            contact.city_name_en = result[@"ci_city_id"];
            contact.not_look_her = [result[@"not_look_her"]integerValue];
            contact.her_not_look_me = [result[@"her_not_look_me"]integerValue];
            _contact = contact;
            
            // 根据用户类型决定点击右上角的弹出框内容
            switch (_relation) {
                case UserFriendTypeNone: {
                    [_menu setData:@[@"Report"]];
                    _followStatusImage.image = ImageNamed(@"icon_follow");
                    _followStatusLabel.text = @"Follow";
                    _followStatusLabel.textColor = ColorWithRGB(74, 183, 253);
                }
                    break;
                case UserFriendTypeFollowed: {
                    [_menu setData:@[@"Report"]];
                    _followStatusImage.image = ImageNamed(@"icon_followed");
                    _followStatusLabel.text = @"Unfollow";
                    _followStatusLabel.textColor = ColorWithRGB(182, 191, 197);
                }
                    break;
                case UserFriendTypeFollower: {
                    [_menu setData:@[@"Report"]];
                    _followStatusImage.image = ImageNamed(@"icon_follow");
                    _followStatusLabel.text = @"Follow";
                    _followStatusLabel.textColor = ColorWithRGB(74, 183, 253);
                }
                    break;
                case UserFriendTypeFriend : {
                    //将用户数据更新到本地数据库
                    [self updateFriendInfoInDB:contact];
                    [_menu setData:@[@"Report"]];
                    _followStatusImage.image = ImageNamed(@"icon_followed_each_other");
                    _followStatusLabel.text = @"Unfollow";
                    _followStatusLabel.textColor = ColorWithRGB(182, 191, 197);
                }
                    break;
                default:
                    break;
            }
            
            _menu.menuClickAtIndex = ^(NSInteger item) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf report];
            };
            [self.view addSubview:_menu];
        } else {
            [self showHUDErrorWithText:responseObject[@"message"]];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDErrorWithText:BAD_NETWORK];
    }];
}

/**
 *  如果这个页面的用户为登录用户的好友，则需要将此用户的数据更新到数据库
 *
 *  @param contact 当前显示的用户信息
 */
- (void) updateFriendInfoInDB : (NihaoContact *) contact {
    ContactDao *dao = [[ContactDao alloc] init];
    //查询数据库是否已存在相同的用户数据
    [dao queryContactByUsername:contact.ci_username query:^(FMResultSet *set) {
        if(set && set.columnCount > 0 && [set next]) {
            //数据发生变化,则更新数据
            if([set intForColumn:@"SEX"] != contact.ci_sex || ![[set stringForColumn:@"NICK_NAME"] isEqualToString:contact.ci_nikename] || ![[set stringForColumn:@"LOGO"] isEqualToString:contact.ci_header_img]) {
                [dao updateContact:contact];
            }
        } else {
            //数据不存在，插入数据即可
            [dao insertContacts:@[contact]];
        }
    }];
}

/**
 *  关注对方
 *
 *  @param user
 */
- (void)followUser:(NihaoContact *)user {
    [self showHUDWithText:@"Following..."];
    [HttpManager addRelationBySelfUserID:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] toPeerUserID:[NSString stringWithFormat:@"%ld", user.ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(_tableView.hidden == YES) {
            _tableView.hidden = NO;
        }
        [self showHUDDoneWithText:@"Followed"];
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
            if(_relation == UserFriendTypeFollower) {
                _relation = UserFriendTypeFriend;
                // 更新ui界面显示
                [_menu setData:@[@"Change name",@"Black List",@"Report"]];
                _followStatusImage.image = ImageNamed(@"icon_followed_each_other");
                _followStatusLabel.text = @"Unfollow";
                _followStatusLabel.textColor = ColorWithRGB(182, 191, 197);
                
            } else {
                _relation = UserFriendTypeFollowed;
                [_menu setData:@[@"Report"]];
                _followStatusImage.image = ImageNamed(@"icon_followed");
                _followStatusLabel.text = @"Unfollow";
                _followStatusLabel.textColor = ColorWithRGB(182, 191, 197);
            }
            
            //follower数量＋1
            _followersCount ++;
            [_userInfoHeader setFollowersCount:_followersCount];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDErrorWithText:BAD_NETWORK];
    }];
}

/**
 *  取消关注对方
 *
 *  @param user 
 */
- (void) unFollowUser : (NihaoContact *)user {
    [self showHUDWithText:@"Unfollowing..."];
    [HttpManager removeRelationBySelfUserID:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] toPeerUserID:[NSString stringWithFormat:@"%ld", user.ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if(rtnCode == 0) {
            [self showHUDDoneWithText:@"Unfollowed"];
            if(_relation == UserFriendTypeFriend) {
                _relation = UserFriendTypeFollower;
                [_menu setData:@[@"Report"]];
                _followStatusImage.image = ImageNamed(@"icon_follow");
                _followStatusLabel.text = @"Follow";
                _followStatusLabel.textColor = ColorWithRGB(74, 183, 253);
            } else {
                _relation = UserFriendTypeNone;
                [_menu setData:@[@"Report"]];
                _followStatusImage.image = ImageNamed(@"icon_follow");
                _followStatusLabel.text = @"Follow";
                _followStatusLabel.textColor = ColorWithRGB(74, 183, 253);
            }
            
            //follower数量-1
            _followersCount --;
            [_userInfoHeader setFollowersCount:_followersCount];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (void) requestUserPost {
    NSString *pageString = [NSString stringWithFormat:@"%ld", _page];
    NSString *currentUserID = [NSString stringWithFormat:@"%ld", _uid];
    NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSString *cd_id = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[cd_id, currentUserID, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"ci_id", @"cd_ci_id", @"page", @"rows", @"random"]];
    [HttpManager requestUserPostListByParameters : parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if(rtnCode == 0) {
            [UserPost setupObjectClassInArray:^NSDictionary *{
                return @{@"pictures" : @"Picture",};
            }];
            NSArray *postsTempArray = [UserPost objectArrayWithKeyValuesArray:resultDict[@"result"][@"rows"]];
            [_postData addObjectsFromArray:postsTempArray];
            if (_postData.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = NO;
            } else {
                // 已经获取全部数据
                self.tableView.footer.hidden = YES;
            }
            // 如果列表有数据
            if (_postData.count > 0) {
                [_loadingStatus showWithStatus:Done];
            } else {// 如果列表没有数据
                self.tableView.footer.hidden = YES;
            }
            
            if (self.tableView.footer.isRefreshing) {
                [self.tableView.footer endRefreshing];
            }
            if (self.tableView.header.isRefreshing) {
                [self.tableView.header endRefreshing];
            }
            
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView reloadData];
            _tableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 138);
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        _tableView.hidden = YES;
        if(!_loadingStatus.superview) {
            [self.view addSubview:_loadingStatus];
        }
        [_loadingStatus showWithStatus:NetErr];
    }];
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

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if(_photoClickType == USER_LOGO) {
        return 1;
    } else {
        return _userPost.pictures.count;
    }
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSString *headerImg = nil;
    if(_photoClickType == USER_LOGO) {
        headerImg = _contact.ci_header_img;
    } else {
        Picture *pic = [_userPost.pictures objectAtIndex:index];
        headerImg = pic.picture_original_network_url;
    }
    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:headerImg]]];
    return photo;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:UserInfoDynamicTableViewCellIdentifier configuration:^(id cell) {
        [(UserInfoDynamicTableViewCell *) cell configureUserInfoDynamic:_postData[indexPath.row] indexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PostDetailViewController *controller = [[PostDetailViewController alloc] initWithNibName:@"PostDetailViewController" bundle:nil];
    UserPost *post = _postData[indexPath.row];
    controller.postID = [NSString stringWithFormat:@"%d", post.cd_id];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    sectionView.backgroundColor = ColorWithRGB(244, 244, 244);
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Moments";
    label.font = FontNeveLightWithSize(14.0);
    label.textColor = ColorWithRGB(158, 158, 158);
    [label sizeToFit];
    label.frame = CGRectMake(15, (35 - CGRectGetHeight(label.frame)) / 2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
    [sectionView addSubview:label];
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 34.5, SCREEN_WIDTH, 0.5)];
    seperator.backgroundColor = SeparatorColor;
    [sectionView addSubview:seperator];
    return sectionView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _postData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoDynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoDynamicTableViewCellIdentifier];
    [cell configureUserInfoDynamic:_postData[indexPath.row] indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - PostPhotoBrowerClickDelegate
- (void) postPhotoClickAtIndex : (NSUInteger) photoIndex cellIndexPath : (NSIndexPath *) indexPath {
    _photoClickType = USER_POST;
    _postClickPhotoIndex = photoIndex;
    _userPost = _postData[indexPath.row];
    [self showPhotoBrower];
}

@end
