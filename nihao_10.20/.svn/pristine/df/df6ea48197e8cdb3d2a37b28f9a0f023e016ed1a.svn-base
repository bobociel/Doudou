//
//  AddFriendsViewController.m
//  nihao
//
//  Created by YW on 15/7/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "BaseFunction.h"
#import "FriendSearchViewController.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import <MJExtension.h>
#import "FollowUserCell.h"
#import "FollowUser.h"
#import "UserInfoViewController.h"
#import "MailListViewController.h"
#import "PermissionDeniedViewController.h"
#import <AddressBook/AddressBook.h>
#import "PeopleYouMayKnowViewController.h"

@interface AddFriendsViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIScrollViewDelegate> {
    NSMutableArray *_usersData;
    NSInteger _page;
    //最新查询的昵称关键字
    NSString *_lastSearchKeyword;
    
    NSMutableDictionary *_allContacts;
    BOOL _isUploadContacts;
    NSMutableArray *_allUsedAppFromContactsUsers;
}

@property (weak, nonatomic) IBOutlet UIControl *phone;
@property (weak, nonatomic) IBOutlet UIControl *peopleYouMayKnow;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDController;
- (IBAction)addMobileContacts:(id)sender;
- (IBAction)viewPeopleYouMayKnow:(id)sender;

@end

static NSString *const PAGESIZE = @"10";
static NSString *const identifier = @"followUserIdentifier";

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add friends";
    [self dontShowBackButtonTitle];
    [self initViews];
    _page = 1;
    _usersData = [NSMutableArray array];
    _allContacts = [[NSMutableDictionary alloc] init];
    _isUploadContacts = NO;
    _allUsedAppFromContactsUsers = [[NSMutableArray alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initViews {
    [self addLinesBetweenViews];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FollowUserCell" bundle:nil] forCellReuseIdentifier:identifier];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    UITextField *searchField = [_searchDController.searchBar valueForKey:@"_searchField"];
    // Change search bar text color
    searchField.font = FontNeveLightWithSize(14.0);
    // Change the search bar placeholder text color
    [searchField setValue:FontNeveLightWithSize(14.0) forKeyPath:@"_placeholderLabel.font"];
    searchField.keyboardType = UIKeyboardTypeASCIICapable;
}

/**
 *  在扫描二维码和添加手机通讯录好友的底部添加灰色的分割线
 */
- (void) addLinesBetweenViews {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    seperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [_peopleYouMayKnow addSubview:seperator];
    
    UIView *topSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    topSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [_phone addSubview:topSeperator];
    UIView *seperator2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_phone.frame) - 0.5, SCREEN_WIDTH, 0.5)];
    seperator2.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [_phone addSubview:seperator2];
}

#pragma mark - uitableview datasouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _usersData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    FollowUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell initCellWithUser:_usersData[indexPath.row] forRowAtIndexPath:indexPath];
    cell.followUser = ^(FollowUser *user, NSIndexPath *indexPath) {
        [self followUser:user forRowAtIndexPath:indexPath];
    };
    return cell;
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfoViewController *userInfoController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    FollowUser *user = _usersData[indexPath.row];
    userInfoController.uid = user.ci_id;
    userInfoController.uname = user.ci_nikename;
    [self.navigationController pushViewController:userInfoController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *name = searchBar.text;
    if(!IsStringEmpty(name)) {
        [self requestUserByNickname:name isLoadingMore:NO];
    }
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(!IsStringEmpty(searchString)) {
        [self requestUserByNickname:searchString isLoadingMore:NO];
    }
    return YES;
}

- (void) searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void) searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    _page = 1;
}

#pragma mark - 搜索请求
- (void) requestUserByNickname : (NSString *) nickname isLoadingMore : (BOOL) isLoadingMore {
    _lastSearchKeyword = nickname;
    [self showHUDWithText:@"Searching..."];
    NSDictionary *params = @{@"ci_id":[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]],@"ci_nikename":nickname,@"page":[NSString stringWithFormat:@"%ld",_page],@"rows":PAGESIZE};
    [HttpManager requestUsersByNickName:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideHud];
        if([responseObject[@"code"] integerValue] == 0) {
            NSDictionary *rows = responseObject[@"result"][@"rows"];
            NSArray *users = [FollowUser objectArrayWithKeyValuesArray:rows];
            if(_usersData.count > 0 && !isLoadingMore) {
                [_usersData removeAllObjects];
            }
            [_usersData addObjectsFromArray:users];
            [_searchDController.searchResultsTableView reloadData];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDErrorWithText:BAD_NETWORK];
    }];
}

- (void)followUser:(FollowUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showHUDWithText:@"Following..."];
    [HttpManager addRelationBySelfUserID:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] toPeerUserID:[NSString stringWithFormat:@"%d", user.ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showHUDDoneWithText:@"Followed"];
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
            user.friend_type = 2;
            [_searchDController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDErrorWithText:BAD_NETWORK];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    {
        if((scrollView.contentOffset.y > 0)) {
            if (scrollView.contentSize.height > scrollView.frame.size.height) {
                if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + 10) {
                    [self loadMore];
                }
            } else if (scrollView.contentOffset.y > 10) {
                [self loadMore];
            }
        }
    }
}

/**
 *  上拉加载更多
 */
- (void) loadMore {
    if(_usersData.count < PAGESIZE.integerValue * _page) {
        return;
    }
    _page++;
    [self requestUserByNickname:_lastSearchKeyword isLoadingMore:YES];
}

#pragma mark - click events
- (IBAction)scanQrCode:(id)sender {

}

- (IBAction)addMobileContacts:(id)sender {
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusDenied || status == kABAuthorizationStatusRestricted) {
        [self showContactsPermissionDeniedVC];
    } else {
        [self showHUDWithText:@"Loading Contacts..."];
        [self accessUserContacts];
    }
}

- (IBAction)viewPeopleYouMayKnow:(id)sender {
    PeopleYouMayKnowViewController *controller = [[PeopleYouMayKnowViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)accessUserContacts {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (!addressBook) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (error) {
            NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
        }
        
        if (granted) {
            // if they gave you permission, then just carry on
            [self listPeopleInAddressBook:addressBook];
        } else {
            // however, if they didn't give you permission, handle it gracefully, for example...
            dispatch_async(dispatch_get_main_queue(), ^{
                // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                //                [[[UIAlertView alloc] initWithTitle:nil message:AUTH_CONTACTS_ERR delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }
        
        CFRelease(addressBook);
    });
}

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
    
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSInteger numberOfPeople = [allPeople count];
    
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //        NSLog(@"Name:%@ %@", firstName, lastName);
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            //            NSLog(@"phone:%@", phoneNumber);
            NSString *finalPhoneNumber = [[NSString stringWithString:phoneNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            finalPhoneNumber = [finalPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            BOOL isStartWithOne = [finalPhoneNumber hasPrefix:@"1"];
            if (finalPhoneNumber.length == 11 && (IsStringNotEmpty(firstName) || IsStringNotEmpty(lastName)) && isStartWithOne) {
                NSMutableString *userNickName = [[NSMutableString alloc] init];
                if (IsStringNotEmpty(firstName)) {
                    [userNickName appendString:[NSString stringWithFormat:@"%@ ", firstName]];
                }
                if (IsStringNotEmpty(lastName)) {
                    [userNickName appendString:lastName];
                }
                [_allContacts setValue:userNickName forKey:finalPhoneNumber];
            }
        }
        
        CFRelease(phoneNumbers);
    }
    // 上传到服务器匹配
    [self uploadContacts];
}

- (void)uploadContacts {
    NSMutableString *allPhoneNumbers = [[NSMutableString alloc] init];
    for (NSString *phoneNumber in _allContacts.allKeys) {
        [allPhoneNumbers appendString:[NSString stringWithFormat:@"%@,", phoneNumber]];
    }
    
    if (allPhoneNumbers.length >= 12) {
        NSString *allNumbers = [allPhoneNumbers substringToIndex:(allPhoneNumbers.length - 1)];
        [HttpManager importContacts:allNumbers userID:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *resultDict = (NSDictionary *)responseObject;
            NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
            [self hideHud];
            if (rtnCode == 0) {
                _allUsedAppFromContactsUsers = [[[resultDict objectForKey:@"result"] objectForKey:@"items"] mutableCopy];
                // 跳转到Mail List界面
                MailListViewController *mailListViewController = [[MailListViewController alloc] init];
                mailListViewController.allUsedAppFromContactsUsers = _allUsedAppFromContactsUsers;
                mailListViewController.userID = [NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]];
                [self.navigationController pushViewController:mailListViewController animated:YES];
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showHUDNetError];
        }];
    }
}

- (void)showContactsPermissionDeniedVC {
    PermissionDeniedViewController *permissionDeniedViewController = [[PermissionDeniedViewController alloc] init];
    permissionDeniedViewController.permissionDeniedType = PermissionDeniedTypeContacts;
    [self.navigationController pushViewController:permissionDeniedViewController animated:YES];
}

@end
