//
//  WTMainViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "AppDelegate.h"
#import "QHNavigationController.h"
#import "WTMainViewController.h"
#import "WTLoadingViewController.h"
#import "WTStoryListViewController.h"
#import "WTFindViewController.h"
#import "WTExpandViewController.h"
#import "WTPCViewController.h"
#import "WTWeddingShopViewController.h"
#import "WTSupplierViewController.h"
#import "WTWebViewViewController.h"
#import "WTWorksDetailViewController.h"
#import "PaperButton.h"
#import "UserInfoManager.h"
#import "WTBudget.h"
#define kCenterBtnWidth  50.0
#define kCenterBtnHeight 36.0
#define kADShowTime      4.0
@interface WTMainViewController ()<PaperButtonDelegate,UITabBarControllerDelegate>
{
	PaperButton* button;
}
@property (nonatomic,strong)WTExpandViewController *expandViewController;
@property (nonatomic,strong)UIImageView *preImageView;
@property (nonatomic,strong)UIButton    *skipButton;
@property (nonatomic,strong)WTAd *ad;
@end

@implementation WTMainViewController
-(WTExpandViewController*)expandViewController
{
	if (!_expandViewController) {
		_expandViewController=[WTExpandViewController new];
		_expandViewController.view.frame=self.view.bounds;
		[self addChildViewController:_expandViewController];
	}
	return _expandViewController;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.delegate = self;
	self.tabBar.shadowImage = [UIImage new];
	self.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:self.tabBar.bounds.size];
	self.tabBar.tintColor = [WeddingTimeAppInfoManager instance].baseColor;

	[self setViewControllers:[NSArray arrayWithObjects:
							  [self viewControllerWithController:[WTFindViewController new] title:@"发现" image:[UIImage imageNamed:@"tabbar_discover"]],
							  [self viewControllerWithController:[UIViewController new] title:nil image:nil],
							  [self viewControllerWithController:[WTPCViewController new] title:@"个人中心" image:[UIImage imageNamed:@"tabbar_center"]],
							  nil] animated:YES];
	self.selectedIndex = 2;
	[self addCenterButton];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	//显示绑定界面
	if([UserInfoManager instance].showBling )
	{
		[button animateToMenu];
		self.selectedIndex = 2;
		[UserInfoManager instance].showBling = NO;
		[[UserInfoManager instance] saveOtherToUserDefaults];
	}

	if([UserInfoManager instance].userId_self.length > 0 ){
		[[SQLiteAssister sharedInstance] loadDataBasePersonal];
	}

	if(isEqualOrThanIOS8){
		[self showPreView];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
	if(isLessThanIOS8) {
		[self showPreView];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(UIViewController*)viewControllerWithController:(UIViewController*) viewController title:(NSString*)title image:(UIImage*)image
{
	viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];

	if (!image) {
		[viewController.tabBarItem setEnabled:NO];
	}

	return viewController;
}

- (void)addCenterButton
{
	button = [[PaperButton alloc]initWithFrame:CGRectMake((screenWidth - kCenterBtnWidth)/2,
														  screenHeight - (kTabBarHeight + kCenterBtnHeight) / 2,
														  kCenterBtnWidth, kCenterBtnHeight)];
	[button setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
	button.tintColor = [UIColor whiteColor];
	button.delegate = self;
	button.layer.cornerRadius = 3;
	button.layer.masksToBounds = YES;

	[self.view addSubview:button];
}

#pragma mark UITabBarDelegate

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	[button animateToMenu];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if([[UserInfoManager instance].tokenId_self isNotEmptyCtg])
	{
		CATransition* animation = [CATransition animation];
		[animation setDuration:0.3f];
		[animation setType:kCATransitionFade];
		[animation setSubtype:kCATransitionFromBottom];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		[[self.view layer]addAnimation:animation forKey:@"switchView"];
	}
}

#pragma mark PaperButtonDelegate
-(void)toCloseAction
{
	[self.view insertSubview:self.expandViewController.view belowSubview:self.tabBar];
	[self.expandViewController animationBegin];
}

-(void)toMenuAction
{
	CATransition* animation = [CATransition animation];
	[animation setDuration:0.3f];
	[animation setType:kCATransitionFade];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[[self.view layer] addAnimation:animation forKey:@"switchView"];

	[self.expandViewController.view removeFromSuperview];
}

#pragma mark - Pre View
- (void)showPreView
{

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_preImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_preImageView.contentMode = UIViewContentModeScaleAspectFill;
		_preImageView.userInteractionEnabled = YES;

		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpAction)];
		[_preImageView addGestureRecognizer:tap];
		[KEY_WINDOW addSubview:_preImageView];

		_skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_skipButton.frame = CGRectMake(screenWidth-40-20, 40, 40, 20);
		_skipButton.alpha = 0;
		_skipButton.titleLabel.font = DefaultFont14;
		_skipButton.backgroundColor = rgba(0, 0, 0, 0.4);
		_skipButton.layer.cornerRadius = 5.0;
		[_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
		[KEY_WINDOW addSubview:_skipButton];
		[_skipButton addTarget:self action:@selector(hidePreView) forControlEvents:UIControlEventTouchUpInside];

		UIImage *launchImage = [UIImage imageNamed:@"Default 640*960"];
		if(screenHeight == 568){
			launchImage = [UIImage imageNamed:@"Default 640*1136"];
		}else if(screenHeight == 667){
			launchImage = [UIImage imageNamed:@"Default 750*1334"];
		}else if(screenHeight == 736){
			launchImage = [UIImage imageNamed:@"Default 1242*2208"];
		}

		_preImageView.image = launchImage;
		[GetService getWeddingAdviertisementWithBlock:^(NSDictionary *result, NSError *error) {
			if(!error && [result[@"success"] boolValue]){
				_skipButton.alpha = 0.8;
				_preImageView.alpha = 0.8;
				_ad = [WTAd modelWithJSON:result[@"data"]];
				[_preImageView sd_setImageWithURL:[NSURL URLWithString:_ad.path]
								 placeholderImage:launchImage
										completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
				{
					_preImageView.image = image;
					[UIView animateWithDuration:0.5 animations:^{ _skipButton.alpha=1; _preImageView.alpha=1; }];
				}];

				[self performSelector:@selector(hidePreView) withObject:nil afterDelay:kADShowTime];
			}else{
				[self hidePreView];
			}
		}];
	});
}

- (void)hidePreView
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	[UIView animateWithDuration:1 animations:^{
		_preImageView.alpha = 0;
		_skipButton.alpha = 0;
	}completion:^(BOOL finished) {
		[_preImageView removeFromSuperview];
		[_skipButton removeFromSuperview];
	}];

	if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg])
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			WTLoadingViewController *next=[[WTLoadingViewController alloc] initWithNibName:@"WTLoadingViewController" bundle:nil];
			[self.navigationController pushViewController:next animated:NO];
		});
	}
	else if( [[WTUploadManager manager] hasCache] && [[UserInfoManager instance].tokenId_self isNotEmptyCtg])
	{
		WTStoryListViewController *storyVC = [[WTStoryListViewController alloc] init];
		[self.navigationController pushViewController:storyVC animated:NO];
	}
}

- (void)jumpAction
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	[UIView animateWithDuration:1 animations:^{
		_preImageView.alpha = 0;
		_skipButton.alpha = 0;
	}completion:^(BOOL finished) {
		[_preImageView removeFromSuperview];
		[_skipButton removeFromSuperview];
	}];

	if(_ad.jump_way == WTADTypePost && [_ad.jump_to isNotEmptyCtg]){
		WTSupplierViewController *VC = [[WTSupplierViewController alloc] init];
		VC.supplier_id = _ad.jump_to;
		[self.navigationController pushViewController:VC animated:NO];
	}else if(_ad.jump_way == WTADTypeSupplier && [_ad.jump_to isNotEmptyCtg]){
		WTWorksDetailViewController *VC = [WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:_ad.jump_to];
		[self.navigationController pushViewController:VC animated:NO];
	}else if(_ad.jump_way == WTADTypeURL && [_ad.jump_to isNotEmptyCtg]){
		WTWebViewViewController *webVC = [WTWebViewViewController instanceViewControllerWithURL:[NSURL URLWithString:_ad.jump_to]];
		[self.navigationController pushViewController:webVC animated:NO];
	}else if(_ad.jump_way == WTADTypeBao){
		[self.navigationController pushViewController:[WTWeddingShopViewController new] animated:NO];
	}

	[PostDataService postAccessLogWithServiceID:0 andCityID:nil andID:_ad.ID andLogType:WTLogTypeADs];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
	return NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[[SDImageCache sharedImageCache] clearMemory];
}

//- ( BOOL )tabBarController:( UITabBarController *)tabBarController shouldSelectViewController :( UIViewController *)viewController{
//    if(![[UserInfoManager instance].tokenId_self isNotEmptyCtg]&&([viewController isKindOfClass:[WTPCViewController class]]||[viewController isKindOfClass:[WTChatListViewController class]]))
//    {
//        [LoginManager pushToLoginViewControllerWithAnimation:YES];
//        return NO ;
//    }
//    return YES ;
//}
@end
