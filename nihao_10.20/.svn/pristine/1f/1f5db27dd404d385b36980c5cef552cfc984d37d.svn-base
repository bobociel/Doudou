//
//  PPAddFriendsViewController.m
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PPAddFriendsViewController.h"
#import "RecommendUserCell.h"
#import "HttpManager.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "MailListViewController.h"
#import "PermissionDeniedViewController.h"

#define AUTH_CONTACTS_ERR @"Please go to Settings - Privacy - Contacts to allow Nihao to acess your Contacts"

// 推荐用户类型
typedef NS_ENUM(NSUInteger, RecommendUserType) {
    RecommendUserTypeSameNationality = 1,// 相同国籍
    RecommendUserTypeSameCity,// 相同城市
    RecommendUserTypePeopleNearby,// 附近
};

@interface PPAddFriendsViewController () // <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *importMailListBtn;
@property (strong, nonatomic) UICollectionView *recommendUsersCollectionView;
@property (strong, nonatomic) UISegmentedControl *findUsersSegmentedControl;
@property (strong, nonatomic) UIButton *okBtn;
@property (strong, nonatomic) UILabel *cantLocationHintLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicatorView;

@end

static NSString *RecommendUserCellReuseIdentifier = @"RecommendUserCell";

@implementation PPAddFriendsViewController {
	// 保存附近用户列表
    NSMutableArray *peopleNearbyUserArray;
	// 保存相同居住城市用户列表
    NSMutableArray *sameCityUserArray;
	// 保存相同国籍用户列表
    NSMutableArray *sameNationalityUserArray;
	// 是否能够定位标记
    BOOL canLocation;
	// 是否已经获取附近用户列表标记
    BOOL requestedPeopleNearby;
	// 是否已经获取相同城市用户列表标记
    BOOL requestedSameCity;
	// 是否已经获取相同国籍用户列表标记
    BOOL requestedSameNationality;
	// 读取过来的用户所有的联系人
    NSMutableDictionary *allContacts;
	// 标记是否有权限访问用户的联系人列表
    BOOL hasAccessContactsPermission;
	// 标记是否已经上传过联系人列表
    BOOL isUploadContacts;
	// 保存所有使用当前 App 的联系人列表
    NSMutableArray *allUsedAppFromContactsUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Personal Profile";
//    [self dontShowBackButtonTitle];
//    
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.view.frame) - 64)];
//    self.scrollView.backgroundColor = [UIColor whiteColor];
//    self.scrollView.contentSize = CGSizeMake(0, 0);
//    self.scrollView.alwaysBounceVertical = YES;
//    self.scrollView.showsVerticalScrollIndicator = NO;
//    
//    // 初始化导入联系人按钮
//    self.importMailListBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 100, 29, 200, 40)];
//    [self.importMailListBtn setTitle:@"Import Mobile Contact" forState:UIControlStateNormal];
//    [self.importMailListBtn addTarget:self action:@selector(importMailListBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    self.importMailListBtn.layer.masksToBounds = YES;
//    self.importMailListBtn.titleLabel.font = FontNeveLightWithSize(18.0);
//    self.importMailListBtn.layer.borderWidth = 1;
//    self.importMailListBtn.layer.borderColor = AppBlueColor.CGColor;
//    [self.importMailListBtn setTitleColor:AppBlueColor forState:UIControlStateNormal];
//    [self.importMailListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//    self.importMailListBtn.backgroundColor = [UIColor whiteColor];
//    [self.importMailListBtn setImage:[UIImage imageNamed:@"icon_import_mail_list"] forState:UIControlStateNormal];
//    self.importMailListBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
//    self.importMailListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    self.importMailListBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [self.scrollView addSubview:self.importMailListBtn];
//    
//    UILabel *findLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.importMailListBtn.frame) + 30, SCREEN_WIDTH - 30, 25)];
//    findLabel.text = @"Find your peers";
//    findLabel.textColor = NormalTextColor;
//    findLabel.font = FontNeveLightWithSize(16.0);
//    [findLabel sizeToFit];
//    [findLabel setNeedsDisplay];
//    [self.scrollView addSubview:findLabel];
//    
//    // 初始化选择控件
//    self.findUsersSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"People nearby", @"Same city", @"Same nationality"]];
//    [self.findUsersSegmentedControl addTarget:self action:@selector(findUserTypeChanged) forControlEvents:UIControlEventValueChanged];
////    self.findUsersSegmentedControl.frame = CGRectMake(50, CGRectGetMaxY(findLabel.frame) + 15, SCREEN_WIDTH - 100, CGRectGetHeight(self.findUsersSegmentedControl.frame));
//    [self.findUsersSegmentedControl setBackgroundColor:[UIColor whiteColor]];
//    [self.findUsersSegmentedControl setTintColor:AppBlueColor];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:FontNeveLightWithSize(12.0) forKey:NSFontAttributeName];
//    [self.findUsersSegmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
//    self.findUsersSegmentedControl.selectedSegmentIndex = 0;
//    self.findUsersSegmentedControl.center = CGPointMake(SCREEN_WIDTH / 2, CGRectGetMaxY(findLabel.frame) + 15 + CGRectGetHeight(self.findUsersSegmentedControl.frame) / 2);
//    [self.scrollView addSubview:self.findUsersSegmentedControl];
//    
//    // 无法定位提示UILabel
//    self.cantLocationHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 25)];
//    self.cantLocationHintLabel.text = @"Unable to locate the current position";
//    self.cantLocationHintLabel.textColor = NormalTextColor;
//    self.cantLocationHintLabel.font = FontNeveLightWithSize(16.0);
//    self.cantLocationHintLabel.numberOfLines = 0;
//    self.cantLocationHintLabel.textAlignment = NSTextAlignmentCenter;
//    [self.cantLocationHintLabel sizeToFit];
//    [self.cantLocationHintLabel setNeedsDisplay];
//    self.cantLocationHintLabel.center = CGPointMake(SCREEN_WIDTH / 2, CGRectGetMaxY(self.findUsersSegmentedControl.frame) + 24 + 110);
//    [self.scrollView addSubview:self.cantLocationHintLabel];
//    
//    // 初始化推荐好友视图
//    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
//    layout.minimumLineSpacing = 24;
//    layout.minimumInteritemSpacing = 0;
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    self.recommendUsersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 274) / 2, CGRectGetMaxY(self.findUsersSegmentedControl.frame) + 24, 274, 210) collectionViewLayout:layout];
//    self.recommendUsersCollectionView.delegate = self;
//    self.recommendUsersCollectionView.dataSource = self;
//    self.recommendUsersCollectionView.bounces = NO;
//    [self.recommendUsersCollectionView registerNib:[UINib nibWithNibName:@"RecommendUserCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:RecommendUserCellReuseIdentifier];
//    self.recommendUsersCollectionView.backgroundColor = [UIColor whiteColor];
//    [self.scrollView addSubview:self.recommendUsersCollectionView];
//    
//    // 初始化加载中的菊花
//    self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.loadingIndicatorView.center =self.recommendUsersCollectionView.center;
//    [self.scrollView addSubview:self.loadingIndicatorView];
//    
//    // 初始化OK按钮
//    self.okBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.recommendUsersCollectionView.frame) + 30, SCREEN_WIDTH - 40, 40)];
//    self.okBtn.backgroundColor = AppBlueColor;
//    [self.okBtn setTitle:@"OK" forState:UIControlStateNormal];
//    [self.okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.okBtn.titleLabel.font = FontNeveLightWithSize(18.0);
//    [self.okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:self.okBtn];
//    
//    [self.view addSubview:self.scrollView];
//    
//    peopleNearbyUserArray = [[NSMutableArray alloc] init];
//    sameNationalityUserArray = [[NSMutableArray alloc] init];
//    sameCityUserArray = [[NSMutableArray alloc] init];
//    requestedPeopleNearby = NO;
//    requestedSameCity = NO;
//    requestedSameNationality = NO;
//    allContacts = [[NSMutableDictionary alloc] init];
//    isUploadContacts = NO;
//    hasAccessContactsPermission = NO;
//    allUsedAppFromContactsUsers = [[NSMutableArray alloc] init];
	
//    NSLog(@"PPAddFriendsViewController -> userRegisterInfo = %@", self.userRegisterInfo);
    
//    if (IsStringEmpty([self.userRegisterInfo objectForKey:USER_PP_LATITUDE])) {
//        self.recommendUsersCollectionView.hidden = YES;
//        self.loadingIndicatorView.hidden = YES;
//        canLocation = NO;
//    } else {
//        canLocation = YES;
//        [self requestPeopleNearbyUserList];
//    }
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self accessUserContacts];
//	
//	if (!canLocation) {
//		[self showCannotLocationAlert];
//	}
//}

#pragma mark - network request functions
// 获取People Nearby列表
//- (void)requestPeopleNearbyUserList {
//    NSArray *keys = @[@"ci_id", @"recommendType", @"ci_gpslat", @"ci_gpslong", @"page", @"rows"];
//    NSArray *objects = @[[self.userRegisterInfo objectForKey:USER_PP_ID], @"3", [self.userRegisterInfo objectForKey:USER_PP_LATITUDE], [self.userRegisterInfo objectForKey:USER_PP_LONGITUDE], @"1", @"6"];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    [self requestRecommendUserListWithParameters:parameters recommendUserType:RecommendUserTypePeopleNearby];
//}
//
//// 获取Same City列表
//- (void)requestSameCityUserList {
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[self.userRegisterInfo objectForKey:USER_PP_ID], @"2", [self.userRegisterInfo objectForKey:USER_PP_LIVE_CITY_ID], @"1", @"6"] forKeys:@[@"ci_id", @"recommendType", @"ci_city_id", @"page", @"rows"]];
//    [self requestRecommendUserListWithParameters:parameters recommendUserType:RecommendUserTypeSameCity];
//}
//
//// 获取Same Nationality列表
//- (void)requestSameNationalityUserList {
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[self.userRegisterInfo objectForKey:USER_PP_ID], @"1", [self.userRegisterInfo objectForKey:USER_PP_NATIONALITY_ID], @"1", @"6"] forKeys:@[@"ci_id", @"recommendType", @"ci_country_id", @"page", @"rows"]];
//    [self requestRecommendUserListWithParameters:parameters recommendUserType:RecommendUserTypeSameNationality
//     ];
//}
//
//// 根据传入的参数和类型来获取用户列表
//- (void)requestRecommendUserListWithParameters:(NSDictionary *)parameters recommendUserType:(RecommendUserType)type {
//    self.loadingIndicatorView.hidden = NO;
//    [HttpManager getRecommendUserListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
////        NSLog(@"type = %ld(1:Nationality, 2:City, 3:Nearby), 推荐的用户列表：%@", type, resultDict);
//        if (rtnCode == 0) {
//            switch (type) {
//                case RecommendUserTypePeopleNearby:
//                    peopleNearbyUserArray = [self setUserList:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
//                    requestedPeopleNearby = YES;
//                    break;
//                case RecommendUserTypeSameCity:
//                    sameCityUserArray = [self setUserList:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
//                    requestedSameCity = YES;
//                    break;
//                case RecommendUserTypeSameNationality:
//                    sameNationalityUserArray = [self setUserList:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
//                    requestedSameNationality = YES;
//                    break;
//            }
//            
//            self.recommendUsersCollectionView.hidden = NO;
//            [self.recommendUsersCollectionView reloadData];
//            self.loadingIndicatorView.hidden = YES;
//		} else {
//			self.loadingIndicatorView.hidden = YES;
//			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
//		}
//    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//		[self showHUDNetError];
//    }];
//}
//
//#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSInteger count = 0;
//    switch (self.findUsersSegmentedControl.selectedSegmentIndex) {
//        case 0:
//            count = peopleNearbyUserArray.count;
//            break;
//        case 1:
//            count = sameCityUserArray.count;
//            break;
//        case 2:
//            count = sameNationalityUserArray.count;
//            break;
//    }
//    
//    return count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    RecommendUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RecommendUserCellReuseIdentifier forIndexPath:indexPath];
//    NSInteger row = indexPath.row;
//    NSDictionary *userInfo;
//    switch (self.findUsersSegmentedControl.selectedSegmentIndex) {
//        case 0:
//            userInfo = [peopleNearbyUserArray objectAtIndex:row];
//            break;
//        case 1:
//            userInfo = [sameCityUserArray objectAtIndex:row];
//            break;
//        case 2:
//            userInfo = [sameNationalityUserArray objectAtIndex:row];
//            break;
//    }
//    
//    [cell initCellWithUserInfo:userInfo];
//    
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(70, 92);
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger row = indexPath.row;
//    NSMutableDictionary *selectedUserInfo;
//    switch (self.findUsersSegmentedControl.selectedSegmentIndex) {
//        case 0:
//            selectedUserInfo = [peopleNearbyUserArray objectAtIndex:row];
//            break;
//        case 1:
//            selectedUserInfo = [sameCityUserArray objectAtIndex:row];
//            break;
//        case 2:
//            selectedUserInfo = [sameNationalityUserArray objectAtIndex:row];
//            break;
//    }
//    
//    NSString *changedValue = [[selectedUserInfo objectForKey:IS_USER_SELECTED] isEqualToString:@"YES"] ? @"NO" : @"YES";
//    [selectedUserInfo setValue:changedValue forKey:IS_USER_SELECTED];
//    [self.recommendUsersCollectionView reloadItemsAtIndexPaths:@[indexPath]];
//    NSString *userID = [selectedUserInfo objectForKey:@"ci_id"];
//    [HttpManager addRelationBySelfUserID:[self.userRegisterInfo objectForKey:USER_PP_ID] toPeerUserID:userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
//        if (rtnCode == 0) {
////            NSLog(@"message = %@", [resultDict objectForKey:@"message"]);
//		}
//    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//		[self showHUDNetError];
//    }];
//}
//
//#pragma mark - click events
//- (void)importMailListBtnClick {
//    if (hasAccessContactsPermission) {
//        // 跳转到Mail List界面
//        MailListViewController *mailListViewController = [[MailListViewController alloc] init];
//        mailListViewController.allUsedAppFromContactsUsers = allUsedAppFromContactsUsers;
//        mailListViewController.userID = [self.userRegisterInfo objectForKey:USER_PP_ID];
//        [self.navigationController pushViewController:mailListViewController animated:YES];
//	} else {
//		[self showContactsPermissionDeniedVC];
//	}
//}
//
//// 访问用户联系人列表
//- (void)accessUserContacts {
//    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
//    if (status == kABAuthorizationStatusDenied || status == kABAuthorizationStatusRestricted) {
////        [[[UIAlertView alloc] initWithTitle:nil message:AUTH_CONTACTS_ERR delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        hasAccessContactsPermission = NO;
//        return;
//    }
//    hasAccessContactsPermission = YES;
//    CFErrorRef error = NULL;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
//    
//    if (!addressBook) {
//        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
//        return;
//    }
//    
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
//        if (error) {
//            NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
//        }
//        
//        if (granted) {
//            // if they gave you permission, then just carry on
//            [self listPeopleInAddressBook:addressBook];
//        } else {
//            // however, if they didn't give you permission, handle it gracefully, for example...
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
////                [[[UIAlertView alloc] initWithTitle:nil message:AUTH_CONTACTS_ERR delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//				hasAccessContactsPermission = NO;
//            });
//        }
//        
//        CFRelease(addressBook);
//    });
//}
//
//// 获取所有的联系人
//- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
//    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
//    NSInteger numberOfPeople = [allPeople count];
//    
//    for (NSInteger i = 0; i < numberOfPeople; i++) {
//        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
//        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
////        NSLog(@"Name:%@ %@", firstName, lastName);
//        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
//        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
//        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
//            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
////            NSLog(@"phone:%@", phoneNumber);
//            NSString *finalPhoneNumber = [[NSString stringWithString:phoneNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            finalPhoneNumber = [finalPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
//            BOOL isStartWithOne = [finalPhoneNumber hasPrefix:@"1"];
//            if (finalPhoneNumber.length == 11 && (IsStringNotEmpty(firstName) || IsStringNotEmpty(lastName)) && isStartWithOne) {
//                NSMutableString *userNickName = [[NSMutableString alloc] init];
//                if (IsStringNotEmpty(firstName)) {
//                    [userNickName appendString:[NSString stringWithFormat:@"%@ ", firstName]];
//                }
//                if (IsStringNotEmpty(lastName)) {
//                    [userNickName appendString:lastName];
//                }
//                [allContacts setValue:userNickName forKey:finalPhoneNumber];
//            }
//        }
//        
//        CFRelease(phoneNumbers);
//    }
////    NSLog(@"allContacts = %@", allContacts);
//    // 上传到服务器匹配
//    [self uploadContacts];
//}
//
//// 将获取来的联系人列表上传到服务器
//- (void)uploadContacts {
//    NSMutableString *allPhoneNumbers = [[NSMutableString alloc] init];
//    for (NSString *phoneNumber in allContacts.allKeys) {
//        [allPhoneNumbers appendString:[NSString stringWithFormat:@"%@,", phoneNumber]];
//    }
//
//    if (allPhoneNumbers.length >= 12) {
//        NSString *allNumbers = [allPhoneNumbers substringToIndex:(allPhoneNumbers.length - 1)];
//        
//        [HttpManager importContacts:allNumbers userID:[self.userRegisterInfo objectForKey:USER_PP_ID] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *resultDict = (NSDictionary *)responseObject;
//            NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
//            if (rtnCode == 0) {
//                allUsedAppFromContactsUsers = [[[resultDict objectForKey:@"result"] objectForKey:@"items"] mutableCopy];
////                NSLog(@"allUsedAppFromContactsUsers = %@", allUsedAppFromContactsUsers);
//			} else {
//				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
//			}
//        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
//    }
//}
//
//// 显示没有联系人访问权限界面
//- (void)showContactsPermissionDeniedVC {
//	PermissionDeniedViewController *permissionDeniedViewController = [[PermissionDeniedViewController alloc] init];
//	permissionDeniedViewController.permissionDeniedType = PermissionDeniedTypeContacts;
//	[self.navigationController pushViewController:permissionDeniedViewController animated:YES];
//}
//
//// 切换推荐用户列表类型
//- (void)findUserTypeChanged {
//    NSInteger index = self.findUsersSegmentedControl.selectedSegmentIndex;
//    
//    if (index == 0) {
//        if (canLocation) {
//            if (!requestedPeopleNearby) {
//                [self requestPeopleNearbyUserList];
//                return;
//            }
//        } else {
//            self.recommendUsersCollectionView.hidden = YES;
//            return;
//        }
//    } else if (index == 1) {
//        if (!requestedSameCity) {
//			self.cantLocationHintLabel.hidden = YES;
//            [self requestSameCityUserList];
//            return;
//        }
//    } else if (index == 2) {
//        if (!requestedSameNationality) {
//			self.cantLocationHintLabel.hidden = YES;
//            [self requestSameNationalityUserList];
//            return;
//        }
//    }
//    self.recommendUsersCollectionView.hidden = NO;
//    [self.recommendUsersCollectionView reloadData];
//}
//
//// 完成完善信息步骤
//- (void)okBtnClick {
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_ID] forKey:@"ci_id"];
//    if (IsStringNotEmpty([self.userRegisterInfo objectForKey:USER_PP_ICON_PATH])) {
//        [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_ICON_PATH] forKey:@"ci_header_img"];
//    }
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_USERNAME] forKey:@"ci_nikename"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_PHONE] forKey:@"ci_phone"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_NATIONALITY_ID] forKey:@"ci_country_id"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_LIVE_CITY_ID] forKey:@"ci_city_id"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_BIRTHDAY] forKey:@"ci_birthday"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_AGE] forKey:@"ci_age"];
//    [parameters setValue:[self.userRegisterInfo objectForKey:USER_PP_SEX] forKey:@"ci_sex"];
//    NSLog(@"complete user info parameters = %@", parameters);
//    [HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
//        if (rtnCode == 0) {
////            NSLog(@"complete user info message = %@", [resultDict objectForKey:@"message"]);
//            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//            [appDelegate initTabBar];
//		} else {
//			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
//		}
//    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//		[self showHUDNetError];
//    }];
//}
//
////#pragma mark - uialert delegate
////- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
////	NSLog(@"buttonIndex = %ld", buttonIndex);
////	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Contacts"]];
////}
//
//#pragma mark - other functions
//- (NSMutableArray *)setUserList:(NSArray *)userList {
//    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] init];
//    
//    for (NSDictionary *user in userList) {
//        NSMutableDictionary *mutableUser = [[NSMutableDictionary alloc] initWithDictionary:user];
//        // 默认未选择
//        [mutableUser setValue:@"NO" forKey:IS_USER_SELECTED];
//        [tempMutableArray addObject:mutableUser];
//    }
//    
//    return tempMutableArray;
//}
//
//- (void)showCannotLocationAlert {
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can't get your location" message:@"please open app location service in settings" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
//	[alert show];
//}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
