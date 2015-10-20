//
//  ContactViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactHeader.h"
#import "HttpManager.h"
#import "BATableView.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension.h>
#import "AppConfigure.h"
#import "HttpManager.h"
#import "NihaoContact.h"
#import "ContactCell.h"
#import "BaseFunction.h"
#import "UserInfoViewController.h"
#import "AddFriendsViewController.h"
#import "FriendDao.h"
#import "UserInfoViewController.h"
#import "FindFriendsViewController.h"
#import "GuideView.h"

@interface ContactViewController () <BATableViewDelegate,ContactHeaderDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
    /*! 联系人列表*/
    BATableView *_table;
    /*! 列表加载状态*/
    ListingLoadingStatusView *_statusView;
    /*! 
     @brief: 用户联系人数据,key为用户昵称的首字母，value为拥有同个首字母的用户昵称的联系人对象的数据列表
     @code @{@"A":@[NihaoContact]} @endcode
     */
    NSMutableDictionary *_friendsData;
    
    FriendDao *_friendDao;
    
    UISearchDisplayController *_searchDisplayController;
    UISearchBar *_searchBar;
    
    //查询结果的数列
    NSMutableArray *_filterFriendsData;
}

@end

@implementation ContactViewController

static const CGFloat SEARCHBAR_HEIGHT = 44;

#pragma mark - view life cycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_icon_contact_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_icon_contact_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contact" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Contact";
    _friendDao = [[FriendDao alloc] init];
    _friendsData = [[NSMutableDictionary alloc] init];
    _filterFriendsData = [NSMutableArray array];
    [self initSearchView];
    [self initViews];
    [self initData];
    [self showUserGuide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
    [self reqFriendsData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 初始化控件
- (void) initSearchView {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCHBAR_HEIGHT)];
    _searchBar.placeholder = @"Search";
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    // Change search bar text color
    searchField.font = FontNeveLightWithSize(14.0);
    // Change the search bar placeholder text color
    [searchField setValue:FontNeveLightWithSize(14.0) forKeyPath:@"_placeholderLabel.font"];
    searchField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.view addSubview:_searchBar];
    _searchBar.delegate = self;
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    [_searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    _searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    _searchDisplayController.searchResultsTableView.delegate = self;
    _searchDisplayController.searchResultsTableView.dataSource = self;
    _searchDisplayController.delegate = self;
}


- (void) initViews {
    _table = [[BATableView alloc] initWithFrame:CGRectMake(0, SEARCHBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - SEARCHBAR_HEIGHT - CGRectGetHeight(self.navigationController.tabBarController.tabBar.frame))];
    _table.delegate = self;
    ContactHeader *header = [[ContactHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 145)];
    header.delegate = self;
    _table.tableView.tableHeaderView = header;
    _table.tableView.tableFooterView = [[UIView alloc] init];
    [_table.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:_table];
    _friendsData = [[NSMutableDictionary alloc] init];
    
    //将加载列表状态view放到屏幕中间，y ＝ 屏幕高度 － view高度 － statusbar高度 － navigationbar高度 － table.headerview的高度
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 105)];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^() {
        [weakSelf reqFriendsData];
    };
    [self.view addSubview:_statusView];
}

- (void) initData {
    NSArray *contacts = [_friendDao queryAllFriends];
    if(contacts.count != 0) {
        _friendsData = [self formNihaoContactData:contacts];
        [_table reloadData];
    } else {
        [_statusView showWithStatus:Loading];
    }
}

/**
 *  将好友数列处理成昵称的首字母为key，拥有相同key的用户数列为值的字典
 *
 *  @param contacts 好友数组
 *
 *  @return 字典
 */
- (NSMutableDictionary *) formNihaoContactData : (NSArray *) contacts {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for(NihaoContact *contact in contacts) {
        //用户昵称为空...
        if(IsStringEmpty(contact.ci_nikename)) {
            continue;
        }
        //如果有中文，将中文转化为拼音。取第一个字符，并将其转化为大写
        NSString *alphbet = [[[BaseFunction chineseToPinyin:contact.ci_nikename] substringToIndex:1] uppercaseString];
        if([[data allKeys] containsObject:alphbet]) {
            NSMutableArray *array = data[alphbet];
            [array addObject:contact];
        } else {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:contact];
            [data setObject:array forKey:alphbet];
        }
    }
    return data;
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
    NSArray *keys = [_friendsData allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

#pragma mark - batableview delegate
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return [self sortedKeys];
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (section < sortedKeys.count) {
            NSString *key = sortedKeys[section];
            return [_friendsData[key] count];
        } else {
            return 0;
        }
    } else {
        return _filterFriendsData.count;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == _table.tableView) {
        return [[self sortedKeys] count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (indexPath.section < sortedKeys.count) {
            ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
            NSString *key = sortedKeys[indexPath.section];
            NSArray *contacts = _friendsData[key];
            [cell loadData:contacts[indexPath.row]];
            return cell;
        } else {
            return nil;
        }
    } else {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        [cell loadData:_filterFriendsData[indexPath.row]];
        return cell;
    }
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        return 30;
    } else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (section < sortedKeys.count) {
            UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            headerSection.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
            label.text = sortedKeys[section];
            label.textColor = [UIColor colorWithRed:120.0 / 255 green:120.0 / 255 blue:120.0 / 255 alpha:1.0];
            label.font = [UIFont systemFontOfSize:12];
            [label sizeToFit];
            [headerSection addSubview:label];
            UIView *lineBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.view.frame), 0.5)];
            lineBottomSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
            [headerSection addSubview:lineBottomSeperator];
            
            UIView *lineTopSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0.5)];
            lineTopSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
            [headerSection addSubview:lineTopSeperator];
            return headerSection;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (indexPath.section < sortedKeys.count) {
            NSString *key = sortedKeys[indexPath.section];
            NSArray *contacts = _friendsData[key];
            NihaoContact *contact = contacts[indexPath.row];
            NSString *nickname = contact.ci_nikename;
            if(IsStringEmpty(nickname)) {
                nickname = contact.ci_username;
            }
            
            UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
            userInfoViewController.uid = contact.ci_id;
            userInfoViewController.uname = nickname;
            [self.navigationController pushViewController:userInfoViewController animated:YES];
        }
    } else {
        NihaoContact *contact = _filterFriendsData[indexPath.row];
        UserInfoViewController *userInfoController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
        userInfoController.uid = contact.ci_id;
        userInfoController.uname = contact.ci_nikename;
        [self.navigationController pushViewController:userInfoController animated:YES];
    }
}

#pragma mark - 请求好友联系人数据
- (void) reqFriendsData {
    NSDictionary *dic = @{@"cr_relation_ci_id":[AppConfigure objectForKey:LOGINED_USER_ID]};
    [HttpManager requestFriendsList:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_statusView showWithStatus:Done];
            NSArray *items = responseObject[@"result"][@"items"];
            NSArray *friendsFromServer = [NihaoContact objectArrayWithKeyValuesArray:items];
            if(friendsFromServer.count == 0) {
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_contact" emptyContent:@"No friend yet,invite them to join now!" imageSize:NO_CONTACT];
            } else {
                if(_friendsData.allKeys.count > 0) {
                    //friend数据库是否需要更新
                    //数据库里的好友数据
                    NSArray *friendsArraysInDb = _friendsData.allValues;
                    NSMutableArray *friendsInDb = [NSMutableArray array];
                    for(NSArray *array in friendsArraysInDb) {
                        [friendsInDb addObjectsFromArray:array];
                    }
                    NSMutableArray *addedFriends = [NSMutableArray array];
                    NSMutableArray *updatedFriends = [NSMutableArray array];
                    for(NihaoContact *friendFromServer in friendsFromServer) {
                        BOOL isNewFriend = YES;
                        for(NihaoContact *friendInDb in friendsInDb) {
                            if(friendInDb.ci_id == friendFromServer.ci_id) {
                                isNewFriend = FALSE;
                                //若字段有不一样的，需要更新本地数据库
                                if(![friendInDb isEqual:friendFromServer]) {
                                    [updatedFriends addObject:friendFromServer];
                                }
                                break;
                            }
                        }
                        
                        //新添加的好友
                        if(isNewFriend) {
                            [addedFriends addObject:friendFromServer];
                        }
                    }
                    
                    //是否有好友被删除
                    NSMutableArray *deletedFriends = [NSMutableArray array];
                    for(NihaoContact *friendInDb in friendsInDb) {
                        BOOL isDelete = YES;
                        for(NihaoContact *friendFromServer in friendsFromServer) {
                            if(friendInDb.ci_id == friendFromServer.ci_id) {
                                isDelete = NO;
                                break;
                            }
                        }
                        if(isDelete) {
                            [deletedFriends addObject:friendInDb];
                        }
                    }
                    
                    //将增加，删除，修改数据更新到数据库和列表
                    BOOL isNeedUpdateTable = NO;
                    if(addedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao insertFriends:addedFriends];
                        NSDictionary *dic = [self formNihaoContactData:addedFriends];
                        for(NSString *key in [dic allKeys]) {
                            if([[_friendsData allKeys] containsObject:key]) {
                                NSMutableArray *array = _friendsData[key];
                                [array addObjectsFromArray:dic[key]];
                            } else {
                                [_friendsData setObject:dic[key] forKey:key];
                            }
                        }
                    }
                    if(deletedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao deleteFriends:deletedFriends];
                        NSDictionary *dic = [self formNihaoContactData:deletedFriends];
                        for(NSString *key in [dic allKeys]) {
                            NSArray *array = dic[key];
                            for(NihaoContact *contact in array) {
                                [_friendsData[key] removeObject:contact];
                            }
                            
                            if([_friendsData[key] count] == 0) {
                                [_friendsData removeObjectForKey:key];
                            }
                        }
                    }
                    if(updatedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao updateFriends:updatedFriends];
                        NSDictionary *dic = [self formNihaoContactData:updatedFriends];
                        for(NSString *key in [dic allKeys]) {
                            NSArray *arrayNew = dic[key];
                            NSMutableArray *arrayOld = _friendsData[key];
                            for(NihaoContact *contactNew in arrayNew) {
                                NSInteger index = 0;
                                for(NihaoContact *contactOld in arrayOld) {
                                    if(contactNew.ci_id == contactOld.ci_id) {
                                        [arrayOld replaceObjectAtIndex:index withObject:contactNew];
                                        break;
                                    }
                                    index++;
                                }
                            }
                        }
                    }
                    
                    if(isNeedUpdateTable) {
                        [_table reloadData];
                    }
                    [_friendDao closeDB];
                } else {
                    _friendsData = [self formNihaoContactData:friendsFromServer];
                    [_friendDao insertFriends:friendsFromServer];
                    [_table reloadData];
                }
            }
        } else {
            if(_friendsData.count == 0) {
                [_statusView showWithStatus:NetErr];
            } else {
                if(_statusView.superview) {
                    [_statusView showWithStatus:Done];
                }
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(_friendsData.count == 0) {
            [_statusView showWithStatus:NetErr];
        } else {
            if(_statusView.superview) {
                [_statusView showWithStatus:Done];
            }
        }
    }];
}

#pragma mark - table header delegate
- (void) didSelectHeaderItem : (NSInteger) index {
	switch (index) {
		case 0: {
			AddFriendsViewController *addFriendsViewController = [[AddFriendsViewController alloc] init];
			[self.navigationController pushViewController:addFriendsViewController animated:YES];
			break;
		}
		case 1: {
			break;
		}
		case 2: {
			FindFriendsViewController *controller = [[FindFriendsViewController alloc] init];
            controller.enterSource = CONTACT;
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
	}
}

#pragma mark - uisearchbar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchContent = searchBar.text;
    if(!IsStringEmpty(searchContent)) {
        NSArray *array = [self filterFriendsByKeyword : searchContent];
        [_filterFriendsData removeAllObjects];
        [_filterFriendsData addObjectsFromArray:array];
        [_searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - UISearchDisplayController delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    if(!IsStringEmpty(searchString)) {
        NSArray *array = [self filterFriendsByKeyword : searchString];
        [_filterFriendsData removeAllObjects];
        [_filterFriendsData addObjectsFromArray:array];
        [_searchDisplayController.searchResultsTableView reloadData];
    }
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/**
 *  searchbar will show
 *
 *  @param controller
 *  @param tableView
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    //[self setTabBarHidden:YES];
}

/**
 *  searchbar will hide
 *
 *  @param controller
 *  @param tableView
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    //[self setTabBarHidden:NO];
}

- (UITabBar *) getTabBar {
    return self.navigationController.tabBarController.tabBar;
}

/**
 *  根据关键字筛选本地好友数据
 *
 *  @return friends对象的数列
 */
- (NSArray *) filterFriendsByKeyword : (NSString *) keyword {
    NSMutableArray *friendsArray = [NSMutableArray array];
    for(NSString *key in [_friendsData allKeys]) {
        NSArray *array = _friendsData[key];
        [friendsArray addObjectsFromArray:array];
    }
    
    //模糊查询
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ci_nikename contains[c] %@",keyword];
    NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predicate];
    return tempArray;
}

/**
 *  隐藏tabbarcontroller
 *
 *  @param hide 当hide为yes时，隐藏tabbar，否则隐藏tabbar
 */
-(void)setTabBarHidden:(BOOL)hide {
    UITabBarController *tabBarController = self.navigationController.tabBarController;
    ////隐藏
    if(hide == YES) {
        [tabBarController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 50)];
        tabBarController.tabBar.hidden = YES;
    } else {//显示
        [tabBarController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        tabBarController.tabBar.hidden = NO;
    }
}

#pragma mark - contact change notification
- (void) contactListChanged : (NSNotification *) notification {
    [self reqFriendsData];
}

- (void) showUserGuide {
    BOOL isNotFirstOpen = [AppConfigure boolForKey:FIRST_OPEN_CONTACT];
    if(!isNotFirstOpen) {
        GuideView *guideView = [[GuideView alloc] initWithBackgroundImageName:@"bg_contact"];
        [[UIApplication sharedApplication].keyWindow addSubview:guideView];
        [AppConfigure setBool:YES forKey:FIRST_OPEN_CONTACT];
    }
}

@end
