//
//  WDHomePageMainViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import <objc/runtime.h>
#import "WTHomeViewController.h"
#import "WTProfileViewController.h"
#import "WTHomeMusicViewController.h"
#import "WTStoryListViewController.h"
#import "WTInviteGuestViewController.h"
#import "WTBlessListViewController.h"
#import "WTThemeListViewController.h"
#import "WTCardDetailViewController.h"
#import "WTTopView.h"
#import "UUAVAudioPlayer.h"
#import "CommAnimationPresent.h"
#import "UserInfoManager.h"
#import "WTWeddingTheme.h"
#import "KYCuteView.h"
#define kClearButtonW 16.0
#define kOpenCardH 40.0
#define kOpenCardY (screenHeight - kTabBarHeight - kOpenCardH)
@interface WTHomeViewController ()<UITabBarDelegate,UIWebViewDelegate,UIScrollViewDelegate,WTTopViewDelegate>
@property (nonatomic, strong) WTWeddingTheme *theme;
@property (nonatomic, strong) KYCuteView *badgeView;
@property (nonatomic, strong) UIButton *openCardButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic, assign) double preContentOffsetY;
@end

@implementation WTHomeViewController
{
	UIWebView *homeWebView;
	UIView *errView;
	WTAlertView *alertView;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.badgeView.frontView.hidden = [[UserInfoManager instance] getUnreadBlessCount].length == 0;
	self.badgeView.bubbleLabel.text = [[UserInfoManager instance] getUnreadBlessCount];

	self.theme = [WTWeddingTheme modelWithJSON:[UserInfoManager instance].themeSelected];
	_openCardButton.hidden = _theme.goods_id.length == 0;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[UUAVAudioPlayer sharedInstance] stopSound];
	[homeWebView stringByEvaluatingJavaScriptFromString:@"music.stop()"];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initTabBar];
	[self initView];
	[self loadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:HomePageWebShouldBeReloadNotify object:nil];
}

- (void)loadData {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:HomePageBaseUrl]];
	[homeWebView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self hideLoadingView];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if([self.navigationController.viewControllers.lastObject isKindOfClass:[WTHomeViewController class]]){
			[homeWebView stringByEvaluatingJavaScriptFromString:@"music.play()"];
		}else{
			[homeWebView stringByEvaluatingJavaScriptFromString:@"music.stop()"];
		}
		[homeWebView stringByEvaluatingJavaScriptFromString:@"window.rm()"];
	});
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	//[self showLoadingView:homeWebView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self doErr:YES];
}

- (void)reloadData {
	[homeWebView reload];
	[self doErr:NO];
}

- (void)doErr:(BOOL )isShow {
	if (!isShow) {
		[errView removeFromSuperview];
		return;
	}

	if (!errView) {
		errView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, homeWebView.height)];
		errView.backgroundColor= [LWUtil colorWithHexString:@"#f8f8f8"];
		UILabel *titleLable=[[UILabel alloc] init];
		titleLable.width         = 160;
		titleLable.centerX       = errView.width/2.f;
		titleLable.numberOfLines = 0;
		titleLable.centerY       = errView.height/2.f;
		titleLable.font          = DefaultFont12;
		titleLable.textAlignment = NSTextAlignmentCenter;
		titleLable.textColor     = titleLableColor;
		titleLable.height=20;
		titleLable.text =@"加载数据失败,点击刷新";
		[errView addSubview:titleLable];
		UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadData)];
		[errView addGestureRecognizer:tap];

	}
	[homeWebView addSubview:errView];
}


- (void)inviteListNavBtnEvent{
	[self.navigationController pushViewController:[WTBlessListViewController new] animated:YES];
}

- (void)initView {
	self.title = @"婚礼主页";
	homeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight)];
	homeWebView.delegate=self;
	homeWebView.scrollView.delegate = self;
	homeWebView.allowsInlineMediaPlayback = YES;
	[self.view addSubview:homeWebView];

	self.openCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_openCardButton.frame = CGRectMake(0, kOpenCardY, screenWidth, kOpenCardH);
	_openCardButton.hidden = YES;
	_openCardButton.titleLabel.font = DefaultFont14;
	_openCardButton.backgroundColor = [LWUtil colorWithHexString:@"F8B066"];
	[_openCardButton setTitle:@"此模板支持请柬配套>" forState:UIControlStateNormal];
	[self.view addSubview:_openCardButton];
	[_openCardButton addTarget:self action:@selector(openCardAction) forControlEvents:UIControlEventTouchUpInside];

	_clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clearButton.frame = CGRectMake(screenWidth - 20 - kClearButtonW, (kOpenCardH - kClearButtonW) / 2 , kClearButtonW, kClearButtonW);
	[_clearButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
	[_openCardButton addSubview:_clearButton];
	[_clearButton addTarget:self action:@selector(hideCardAction) forControlEvents:UIControlEventTouchUpInside];

	self.topView = [WTTopView topViewInView:self.view  withType:@[@(WTTopViewTypeBack)]];
	self.topView.width = 50.0;
	self.topView.delegate = self;
	[self.view addSubview:_topView];
}

- (void)initTabBar
{
	_tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kTabBarHeight)];
	_tabBar.bottom=self.view.height;
	_tabBar.opaque = YES;
	_tabBar.delegate = self;
	_tabBar.backgroundImage = [LWUtil imageWithColor:[UIColor whiteColor] frame:_tabBar.bounds];
	_tabBar.tintColor = [LWUtil colorWithHexString:@"#888888"];
	[self.view addSubview:_tabBar];

	UITabBarItem * (^WTHomeItem)(NSString *title,NSString *imageName,WTHomeItemType type) = ^(NSString *title,NSString *imageName,WTHomeItemType type){
		UITabBarItem *aItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:type];
		return aItem;
	};

	//自定义邀请按钮
	UIView *(^GuestButton)(UIImage *image,NSString *title) = ^(UIImage *image,NSString *title){
		UIView *guestView = [[UIView alloc] init];
		guestView.frame = CGRectMake(screenWidth/5.0* 4, 0, screenWidth/5.0, 50);
		guestView.backgroundColor = WeddingTimeBaseColor;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = CGRectMake( (screenWidth/5.0 - 20) / 2.0, 8, 22, 22);
		[guestView addSubview:imageView];

		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, screenWidth/5.0, 12)];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:11];
		titleLabel.text = title;
		[guestView addSubview:titleLabel];

		return guestView;
	};

	[_tabBar addSubview:GuestButton([UIImage imageNamed:@"homepage_invitecustom_white"],@"分享请柬")];

	[_tabBar setItems:@[WTHomeItem(@"完善资料",@"homepage_information",WTHomeItemTypeProfile),
					   WTHomeItem(@"请柬设置",@"homepage_theme",WTHomeItemTypeTheme),
					   WTHomeItem(@"谱写故事",@"homepage_story",WTHomeItemTypeStory ),
                       WTHomeItem(@"宾客回执",@"homepage_bless",WTHomeItemTypeBless),
					   WTHomeItem(@"",@"",WTHomeItemTypeInvite),
					   ]];
	
	[_tabBar setSelectedItem:_tabBar.items[0]];

	UIView *blessView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/5.0 * 3, 0, screenWidth/5.0, 50)];
	blessView.backgroundColor = [UIColor clearColor];
	blessView.userInteractionEnabled = NO;
	[_tabBar addSubview:blessView];

	self.badgeView = [blessView baseBadgeViewWithViewWidth:(screenWidth/5.0)];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item.tag==WTHomeItemTypeProfile) {
		[self.navigationController pushViewController:[WTProfileViewController new] animated:YES];
	}else if (item.tag==WTHomeItemTypeStory) {
		[self.navigationController pushViewController:[WTStoryListViewController new] animated:YES];
	}else if (item.tag==WTHomeItemTypeTheme) {
		[self.navigationController pushViewController:[WTThemeListViewController new] animated:YES];
	}else if(item.tag ==WTHomeItemTypeBless) {
		[self.navigationController pushViewController:[WTBlessListViewController new] animated:YES];
	}else if(item.tag == WTHomeItemTypeInvite){
        [self.navigationController pushViewController:[WTInviteGuestViewController new] animated:YES];
    }
}

- (void)openCardAction
{
	[self.navigationController pushViewController:[WTCardDetailViewController instanceWithCardId:_theme.goods_id] animated:YES];
}

- (void)hideCardAction
{
	[UIView animateWithDuration:0.25 animations:^{
		_openCardButton.alpha = 0;
		_openCardButton.frame = CGRectMake(0, screenHeight, screenWidth, kTabBarHeight);
	} completion:^(BOOL finished) {
		[_openCardButton removeFromSuperview];
	}];
}

- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end

