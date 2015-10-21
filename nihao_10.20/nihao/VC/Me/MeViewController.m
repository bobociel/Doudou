//
//  MeViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MeViewController.h"
#import "MeHeaderView.h"
#import "MeTableViewCell.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "MineInfo.h"
#import <MJExtension/MJExtension.h>
#import "UserFollowListViewController.h"
#import "BaseFunction.h"
#import "SettingsViewController.h"
#import "ExchangeRateViewController.h"
#import "ModifyProfileViewController.h"
#import "MyWalletViewController.h"
#import "MobileRechargeViewController.h"
#import "NotificationCenterViewController.h"
#import "MWPhotoBrowser.h"
#import "GuideView.h"
#import "UITabBar+badge.h"
#import "BlacklistViewController.h"

@interface MeViewController () <MeHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource,ClearNotificationRedPointDelegate,ClearNewFollowsRedPointDelegate,MWPhotoBrowserDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MeHeaderView *meHeaderView;

@end

static NSString *MeCellReuseIdentifier = @"MeTableViewCell";

@implementation MeViewController {
	NSArray *iconArray;
	NSArray *textArray;
	MineInfo *mineInfo;
	
	NSInteger followCount;
	NSInteger followerCount;
	
	BOOL isFirst;
    BOOL needRedPointInNotification;
    
    //新增加的关注数
    NSUInteger newFollowsNum;
    //未读的动态评论数
    NSUInteger unreadCommentsNum;
    //未读的ask回复数
    NSUInteger unreadAnswersNum;
    //未读的动态点赞数量
    NSUInteger unreadLikesNum;
    
    MWPhotoBrowser *photoBrowser;

    NSArray *collecIcons;
    NSArray *collecTexts;

    UIView *collectionView ;
}

#pragma mark - view life cycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_icon_me_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_icon_me_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnreadMessages:) name:KNOTIICATION_UNREAD_MESSAGE_COMES object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Profile";
//	self.view.backgroundColor = RootBackgroundWhitelyColor;
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
	self.tableView.rowHeight = 51.0;
	self.tableView.sectionHeaderHeight = 15.0;
	self.tableView.backgroundColor = self.view.backgroundColor;
	[self.tableView registerNib:[UINib nibWithNibName:@"MeTableViewCell" bundle:nil] forCellReuseIdentifier:MeCellReuseIdentifier];
    
    //@[@"icon_unverified"],
	iconArray = [NSArray arrayWithObjects:@[@""],@[@"icon_notifications", @"icon_my_questions"], @[@"icon_black_list"], @[@"icon_settings"], nil];
    //@[@"Unverified"], 
	textArray = [NSArray arrayWithObjects:@[@""],@[@"Notifications", @"My questions"], @[@"Blacklist"], @[@"Set"], nil];
	
	followCount = 0;
	followerCount = 0;
	isFirst = YES;
	
    collecIcons = [NSArray arrayWithObjects:@"icon_recharge-1",@"icon_exchange-rate",@"icon_train-tickets",@"icon_express", nil];
    collecTexts = [NSArray arrayWithObjects:@"Recharge",@"Exchange Rate",@"Train Tickets",@"Express", nil];
    
	[self getMineInfo];
	[self initMineInfoHeaderView];
	[self requestMineInfo];
    [self showUserGuide];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITabBarController *tabbarController = (UITabBarController *) self.navigationController.parentViewController;
    if(tabbarController.tabBar.isHidden) {
        tabbarController.tabBar.hidden = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    
	if (!isFirst) {
		NSString *shouldRefresh = [AppConfigure objectForKey:ME_SHOULD_REFRESH];
		if (IsStringNotEmpty(shouldRefresh) && [@"YES" isEqualToString:shouldRefresh]) {
			[self requestMineInfo];
			[AppConfigure setValue:@"NO" forKey:ME_SHOULD_REFRESH];
		}
	} else {
		isFirst = NO;
	}
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)getMineInfo {
	if (!mineInfo) {
		mineInfo = [[MineInfo alloc] init];
	}
	
	mineInfo.ci_id = [AppConfigure integerForKey:LOGINED_USER_ID];
	mineInfo.ci_nikename = [AppConfigure valueForKey:LOGINED_USER_NICKNAME];
	mineInfo.ci_header_img = [AppConfigure valueForKey:LOGINED_USER_ICON_URL];
	mineInfo.byCount = [AppConfigure integerForKey:LOGINED_USER_BY_COUNT];
	mineInfo.relationCount = [AppConfigure integerForKey:LOGINED_USER_RELATION_COUNT];
	mineInfo.ci_is_verified = [AppConfigure integerForKey:LOGINED_USER_IS_VERIFIED];
	mineInfo.ci_sex = [[AppConfigure valueForKey:LOGINED_USER_SEX] integerValue];
    mineInfo.ci_city_id = [AppConfigure valueForKey:REGISTER_USER_CITY_ID];
    
}

- (void)initMineInfoHeaderView {
	if (!self.meHeaderView) {
		self.meHeaderView = [[MeHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 140)];
		self.meHeaderView.delegate = self;
		
		self.tableView.tableHeaderView = self.meHeaderView;
        if(newFollowsNum > 0) {
            [self.meHeaderView setNewFollowersCount:newFollowsNum];
        }
	}
	
	[self.meHeaderView configureMeHeaderViewWithMineInfo:mineInfo];
}

- (void)initCollectionView{
    collectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    collectionView.backgroundColor = [UIColor whiteColor];
    for (int i = 0 ; i < collecIcons.count ; i++){
        UIButton *iconImg = [[UIButton alloc] initWithFrame:CGRectMake(30+SCREEN_WIDTH/4*i, 18, 34, 34)];
        NSString *icon = collecIcons[i];
        [iconImg setImage:ImageNamed(icon) forState:UIControlStateNormal];
        iconImg.tag = i;
        [iconImg addTarget:self action:@selector(toolButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [collectionView addSubview:iconImg];
        
        NSString *text = collecTexts[i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4*i+15, 64, SCREEN_WIDTH/4-30, 35)];
        label.numberOfLines = 0;
        label.font = FontNeveLightWithSize(14.0);
        label.textColor = ColorWithRGB(120, 120, 120);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        //        label.frame = [label textRectForBounds:label.frame limitedToNumberOfLines:0];
        [label sizeToFit];
        [label setFrame:CGRectMake(SCREEN_WIDTH/8*(2*i+1)-label.frame.size.width/2,label.frame.origin.y,label.frame.size.width,label.frame.size.height)];
        [collectionView addSubview:label];
    }
}
#pragma mark - networking
- (void)requestMineInfo {
	NSString *userID = [AppConfigure objectForKey:LOGINED_USER_ID];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[userID, userID, random] forKeys:@[@"by_ci_id", @"ci_id", @"random"]];
	[HttpManager requestUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			MineInfo *tempMineInfo = [MineInfo objectWithKeyValues:resultDict[@"result"]];
			if (tempMineInfo.ci_id != 0) {// 如果获取过来的个人信息不为空，则保存到本地
				mineInfo = tempMineInfo;
				if (IsStringNotEmpty(mineInfo.ci_job)) {
					[AppConfigure setValue:mineInfo.ci_job forKey:LOGINED_USER_JOB];
				}
				if (IsStringNotEmpty(mineInfo.ci_email)) {
					[AppConfigure setValue:mineInfo.ci_email forKey:LOGINED_USER_EMAIL];
				}
				[AppConfigure setInteger:mineInfo.byCount forKey:LOGINED_USER_BY_COUNT];
				[AppConfigure setInteger:mineInfo.relationCount forKey:LOGINED_USER_RELATION_COUNT];
				[AppConfigure setInteger:mineInfo.ci_is_verified forKey:LOGINED_USER_IS_VERIFIED];
                [AppConfigure setValue:mineInfo.ci_city_id forKey:REGISTER_USER_CITY_ID];
				
				[self initMineInfoHeaderView];
				followCount = mineInfo.relationCount;
				followerCount = mineInfo.byCount;
				if (mineInfo.ci_is_verified == 1) {// 已认证
					if (IsStringNotEmpty(mineInfo.country_name_en)) {
						iconArray = [NSArray arrayWithObjects:@[@"icon_verified"], @[@"icon_recharge", @"icon_exchange_rate"], @[@"icon_notifications", @"icon_my_questions", @"icon_black_list"], @[@"icon_settings"], nil];
						textArray = [NSArray arrayWithObjects:@[mineInfo.country_name_en], @[@"Mobile Recharge", @"Exchange Rate"], @[@"Notifications", @"My Questions", @"Black List"], @[@"Settings"], nil];
					}
				}
				
				self.tableView.hidden = NO;
				[self.tableView reloadData];
			} else {// 如果为空，则加载本地数据
				NSLog(@"mineInfo is nil");
			}
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return textArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *texts = textArray[section];
	return texts.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 100;
    }
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MeTableViewCell *cell = (MeTableViewCell  *)[tableView dequeueReusableCellWithIdentifier:MeCellReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        [self initCollectionView];
        [cell.contentView addSubview:collectionView];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if(indexPath.section == 1) {
        [cell configureCellWithIconName:iconArray[indexPath.section][indexPath.row] andLabelText:textArray[indexPath.section][indexPath.row] hasIcon:YES hasRedPoint:needRedPointInNotification];
    } else {
        [cell configureCellWithIconName:iconArray[indexPath.section][indexPath.row] andLabelText:textArray[indexPath.section][indexPath.row] hasIcon:YES hasRedPoint:NO];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15.0)];
	sectionHeaderView.backgroundColor = self.view.backgroundColor;
	
	return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 1) {
		// Payment
        if (indexPath.row == 0) {
            //Notification
            NotificationCenterViewController *controller = [[NotificationCenterViewController alloc] init];
            controller.unreadLikeNum = unreadLikesNum;
            controller.unreadAnswerNum = unreadAnswersNum;
            controller.unreadCommentNum = unreadCommentsNum;
            controller.delegate = self;
            [self pushViewController:controller];
        } else if (indexPath.row == 1) {
            // My questions
        }
	} else if (indexPath.section == 2) {
        BlacklistViewController *controller = [[BlacklistViewController alloc] init];
        [self pushViewController:controller];
    }else if (indexPath.section == 3){
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        [self pushViewController:settingsViewController];
    }
}

#pragma mark - MeHeaderViewDelegate
// 点击 Follow 或者 Follower
- (void)meHeaderView:(MeHeaderView *)meHeaderView clickedFollowType:(MeHeaderViewFollowType)type {
	UserFollowListViewController *userFollowListViewController = [[UserFollowListViewController alloc] init];
	userFollowListViewController.userFollowListType = (NSInteger)type;
	userFollowListViewController.userID = [AppConfigure objectForKey:LOGINED_USER_ID];
    userFollowListViewController.delegate = self;
    [self pushViewController:userFollowListViewController];
}

// 点击用户头像，查看大图
- (void)meHeaderViewclickedHeaderIcon {
    photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //设置浏览图片的navigationbar为蓝色
    photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    photoBrowser.displayActionButton = NO;
    photoBrowser.enableGrid = NO;
    // Manipulate
    [photoBrowser showNextPhotoAnimated:YES];
    [photoBrowser showPreviousPhotoAnimated:YES];
    // Present
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

//修改用户信息
- (void) viewUserInfo {
    ModifyProfileViewController *modifyProfileViewController = [[ModifyProfileViewController alloc] init];
    //[self.navigationController pushViewController:modifyProfileViewController animated:YES];
    [self pushViewController:modifyProfileViewController];
}

#pragma mark - unread message notification
- (void) showUnreadMessages : (NSNotification *) notification {
    NSDictionary *result = notification.object;
    if([result.allKeys containsObject:@"pushType"]) {
        NSInteger pushType = [result[@"pushType"] integerValue];
        if(pushType == 2) {
            unreadLikesNum ++;
        } else if(pushType == 3) {
            unreadCommentsNum ++;
        } else if(pushType == 4) {
            unreadAnswersNum ++;
        }
        
    } else {
        unreadAnswersNum = [result[@"askCommentCount"] integerValue];
        unreadCommentsNum = [result[@"dynamicCommentCount"] integerValue];
        unreadLikesNum = [result[@"dynamicPraiseCount"] integerValue];
        newFollowsNum = [result[@"followCount"] integerValue];
    }
    
    if(unreadLikesNum > 0 || unreadCommentsNum > 0 || unreadAnswersNum > 0) {
        needRedPointInNotification = YES;
        if(self.isViewLoaded && self.view.window) {
            [self.tableView reloadData];
        }
        [self.tabBarController.tabBar showBadgeAtIndex:4];
    }
}

#pragma mark - clearNotificationRedPointDelegate
- (void) clearNotificationRedPoint {
    unreadAnswersNum = 0;
    unreadCommentsNum = 0;
    unreadLikesNum = 0;
    needRedPointInNotification = NO;
    [self.tabBarController.tabBar hideBadgeAtIndex:4];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) clearNewFollowsRedPoint {
    if(newFollowsNum > 0) {
        newFollowsNum = 0;
        [self.meHeaderView setNewFollowersCount:newFollowsNum];
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:mineInfo.ci_header_img]]];
    return photo;
}

- (void) showUserGuide {
    BOOL isNotFirstOpenSetting = [AppConfigure boolForKey:FIRST_OPEN_SETTING];
    if(!isNotFirstOpenSetting) {
        GuideView *chargeGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_recharge"];
        [[UIApplication sharedApplication].keyWindow addSubview:chargeGuide];
        __weak typeof(chargeGuide) weakGuide = chargeGuide;
        chargeGuide.getItButtonClick = ^() {
            __strong typeof(weakGuide) strongGuide = weakGuide;
            [strongGuide removeFromSuperview];
            GuideView *rateGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_exchange"];
            [[UIApplication sharedApplication].keyWindow addSubview:rateGuide];
        };
        [AppConfigure setBool:YES forKey:FIRST_OPEN_SETTING];
    }
}

- (void) pushViewController : (UIViewController *) viewController {
    UITabBarController *controller = (UITabBarController *)self.navigationController.parentViewController;
    if(!controller.tabBar.isHidden) {
        [controller.tabBar setHidden:YES];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark - buttonClick
-(void)toolButtonClick:(UIButton *)btn{
    if (btn.tag == 0) {
        //MobaleRecharge
        MobileRechargeViewController *controller = [[MobileRechargeViewController alloc] init];
        [self pushViewController:controller];
    }
    if (btn.tag == 1) {
        //ExchangeRate
        ExchangeRateViewController *exchangeRateViewController = [[ExchangeRateViewController alloc] init];
        [self pushViewController:exchangeRateViewController];

    }
    if (btn.tag == 2) {
        //Tran Tickets
        
    }
    if (btn.tag == 3) {
        //Utilities
    }
}
@end
