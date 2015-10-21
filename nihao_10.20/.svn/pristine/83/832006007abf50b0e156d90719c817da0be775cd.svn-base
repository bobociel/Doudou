//
//  FindFriendsViewController.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "RecommendUserCell.h"
#import "AppConfigure.h"
#import "HttpManager.h"
#import "AppDelegate.h"

@interface FindFriendsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *okButton;

@end

static NSString *RecommendUserCellIdentifier = @"RecommendUserCell";

@implementation FindFriendsViewController {
	NSString *latitude;
	NSString *longitude;
	NSMutableArray *dataSource;
	CGFloat margin;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_enterSource == REGIST) {
	    self.title = @"Find your friends";
    } else {
        self.title = @"People You May Know";
    }

	self.view.backgroundColor = [UIColor whiteColor];
	
	latitude = [AppConfigure valueForKey:REGISTER_USER_LATITUDE];
	longitude = [AppConfigure valueForKey:REGISTER_USER_LONGITUDE];
	dataSource = [[NSMutableArray alloc] init];
	
	margin = (SCREEN_WIDTH - 70 * 3) / 4.0;
	
	// 初始化推荐好友视图
	UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
	layout.minimumLineSpacing = 24;
	layout.minimumInteritemSpacing = margin;
	layout.scrollDirection = UICollectionViewScrollDirectionVertical;
	CGRect cFrame = self.view.bounds;
	cFrame.origin.x = margin;
//	cFrame.origin.y = margin;
	cFrame.size.width -= margin * 2;
	cFrame.size.height -= 80;
	self.collectionView.frame = cFrame;
	self.collectionView = [[UICollectionView alloc] initWithFrame:cFrame collectionViewLayout:layout];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.collectionView.alwaysBounceVertical = YES;
	self.collectionView.alwaysBounceHorizontal = NO;
	self.collectionView.showsVerticalScrollIndicator = NO;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.contentInset = UIEdgeInsetsMake(margin, 0, 0, 0);
	[self.collectionView registerNib:[UINib nibWithNibName:@"RecommendUserCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:RecommendUserCellIdentifier];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.collectionView];
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 80, SCREEN_WIDTH, 80)];
	footerView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:footerView];
	
    if(_enterSource == REGIST) {
        NSInteger buttonWidth = (SCREEN_WIDTH - 30 - 30 - 30) / 2;
        self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, buttonWidth, 40)];
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [self.skipButton setTitleColor:AppBlueColor forState:UIControlStateNormal];
        self.skipButton.backgroundColor = [UIColor whiteColor];
        self.skipButton.layer.masksToBounds = YES;
        self.skipButton.layer.borderColor = AppBlueColor.CGColor;
        self.skipButton.layer.borderWidth = 1;
        [self.skipButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:self.skipButton];
        
        self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth + 60, 20, buttonWidth, 40)];
        [self.okButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.okButton.backgroundColor = AppBlueColor;
        [self.okButton addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:self.okButton];
    } else {
        NSInteger buttonWidth = (SCREEN_WIDTH - 30 - 30 - 30) / 2;
        self.okButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(footerView.frame) - buttonWidth) / 2, 20, buttonWidth, 40)];
        [self.okButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.okButton.backgroundColor = AppBlueColor;
        [self.okButton addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:self.okButton];
    }
	
	[self requestRecommendUsers];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateCollectionViewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateCollectionViewFrame];
}

- (void)updateCollectionViewFrame {
	CGRect cFrame = self.view.bounds;
	cFrame.origin.x = margin;
	cFrame.size.width -= margin * 2;
	cFrame.size.height -= 80;
	self.collectionView.frame = cFrame;
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Events

- (void)skip {
	// 直接登录
	[self showWithLabelText:@"Login..." executing:@selector(userLogin)];
}

- (void)ok {
	[self showWithLabelText:@"Following..." executing:@selector(followUsersAndFinish)];
}

#pragma mark - Networking

- (void)requestRecommendUsers {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	[parameters setObject:@"5" forKey:@"recommendType"];
	[parameters setObject:[AppConfigure valueForKey:REGISTER_USER_COUNTRY_ID] forKey:@"ci_country_id"];
	[parameters setObject:[AppConfigure valueForKey:REGISTER_USER_ID] forKey:@"ci_id"];
	
	if (IsStringNotEmpty(longitude) && [longitude doubleValue] != 0) {
		[parameters setObject:latitude forKey:@"ci_gpslat"];
		[parameters setObject:longitude forKey:@"ci_gpslong"];
	}
	
	[HttpManager getRecommendUserListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			NSArray *tempArray = resultDict[@"result"][@"rows"];
			for (int i = 0; i < tempArray.count; i++) {
				NSMutableDictionary *user = [[NSMutableDictionary alloc] initWithDictionary:tempArray[i]];
				[user setObject:@"YES" forKey:IS_USER_SELECTED];
				[dataSource addObject:user];
			}
			
			[self.collectionView reloadData];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

- (void)followUsersAndFinish {
	NSMutableString *followUserIDs = [[NSMutableString alloc] init];
	BOOL isFirst = YES;
	for (NSDictionary *user in dataSource) {
		NSString *selected = user[IS_USER_SELECTED];
		if ([selected isEqualToString:@"YES"]) {
			if (isFirst) {
				[followUserIDs appendString:[NSString stringWithFormat:@"%@", user[@"ci_id"]]];
				isFirst = NO;
			} else {
				[followUserIDs appendString:[NSString stringWithFormat:@",%@", user[@"ci_id"]]];
			}
		}
	}
	
	NSLog(@"followUserIDs = %@", followUserIDs);
	
	if (followUserIDs.length == 0) {
		// 登录
        if(_enterSource == REGIST) {
            [self showWithLabelText:@"Login..." executing:@selector(userLogin)];
        } else {
            [self showHUDErrorWithText:@"Please select at least one user to follow"];
        }
	} else {
		NSString *userID = [AppConfigure valueForKey:REGISTER_USER_ID];
		NSDictionary *parameters = @{@"cr_by_ci_id_s" : followUserIDs, @"cr_relation_ci_id" : userID};
		NSLog(@"parameters = %@", parameters);
		
		[HttpManager batchFollowUsersByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *resultDict = (NSDictionary *)responseObject;
			NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
			if (rtnCode == 0) {
				// 登录
                if(_enterSource == REGIST) {
                    [self showWithLabelText:@"Login..." executing:@selector(userLogin)];
                } else {
                    [self showHUDDoneWithText:@"Followed"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
			}
		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
			[self showHUDNetError];
		}];
	}
}

- (void)userLogin {
	// 组装请求数据
	NSString *phoneNumber = [AppConfigure valueForKey:REGISTER_USER_PHONE];
	NSString *password = [AppConfigure valueForKey:REGISTER_USER_PWD];
	
	[HttpManager userLoginWithPhoneNumber:phoneNumber password:password success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		NSLog(@"Find Friend 当前登录的用户信息：%@", resultDict);
		if (rtnCode == 0) {
			// 清除之前保存的用户密码
			[AppConfigure setValue:@"" forKey:REGISTER_USER_PWD];
			// 保存当前登录的用户信息
			[AppConfigure saveUserProfile:resultDict[@"result"]];
			// 登录成功
			AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
			// 保存登录状态
			[AppConfigure setBool:YES forKey:IS_LOGINED];
			[delegate autoLoginHuanxin];
			// 登录成功，跳转到主界面
			[delegate initTabBar];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RecommendUserCellIdentifier forIndexPath:indexPath];
    [cell initCellWithUserInfo:dataSource[indexPath.row]];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 92);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *selectedUser = dataSource[indexPath.row];
	NSString *selected = selectedUser[IS_USER_SELECTED];
	selected = [selected isEqualToString:@"YES"] ? @"NO" : @"YES";
	[selectedUser setObject:selected forKey:IS_USER_SELECTED];
	[collectionView reloadItemsAtIndexPaths:@[indexPath]];
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
