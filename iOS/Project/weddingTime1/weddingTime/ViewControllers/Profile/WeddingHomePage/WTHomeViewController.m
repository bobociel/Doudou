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
#import "WTBlessListViewController.h"
#import "WTThemeListViewController.h"
#import "UUAVAudioPlayer.h"
#import "CommAnimationPresent.h"
#import "UserInfoManager.h"
#import "PostDataService.h"
#import "GetService.h"
#import "KYCuteView.h"
#define kTabBarHeight 50.0
@interface WTHomeViewController ()<UITabBarDelegate,UIWebViewDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) KYCuteView *badgeView;
@end

@implementation WTHomeViewController
{
	UIWebView *homeWebView;
	UIView *errView;
	WTAlertView *alertView;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[UUAVAudioPlayer sharedInstance] stopSound];
	[homeWebView stringByEvaluatingJavaScriptFromString:@"music.stop()"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.badgeView.frontView.hidden = [[UserInfoManager instance] getUnreadBlessCount].length == 0;
	self.badgeView.bubbleLabel.text = [[UserInfoManager instance] getUnreadBlessCount];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initTabBar];
	[self initView];
	[self loadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:HomePageWebShouldBeReloadNotify object:nil];
}

- (void)loadData {
	NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:HomePageBaseUrl]];
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
		titleLable.font          = defaultFont12;
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
	homeWebView.allowsInlineMediaPlayback = YES;
	[self.view addSubview:homeWebView];

	UIButton *closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
	closeBtn.frame=CGRectMake(10, 30, 32, 32);
	[closeBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
	[closeBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
	[self.view addSubview:closeBtn];
}

- (void)initTabBar {

	UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kTabBarHeight)];
	tabBar.bottom=self.view.height;
	tabBar.opaque = YES;
	tabBar.delegate = self;
	tabBar.backgroundImage=[LWUtil imageWithColor:[UIColor whiteColor] frame:tabBar.bounds];
	tabBar.tintColor=[LWUtil colorWithHexString:@"#888888"];
	[self.view addSubview:tabBar];

	UITabBarItem * (^WTHomeItem)(NSString *title,NSString *imageName,WTHomeItemType type) = ^(NSString *title,NSString *imageName,WTHomeItemType type){
		return [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:type];
	};

	//自定义邀请按钮
	UIView *(^GuestButton)(UIImage *image,NSString *title) = ^(UIImage *image,NSString *title){
		UIView *guestView = [[UIView alloc] init];
		guestView.frame = CGRectMake(screenWidth/4.0* 3, 0, screenWidth/4.0, 50);
		guestView.backgroundColor = WeddingTimeBaseColor;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = CGRectMake( (screenWidth/4.0 - 20) / 2.0, 8, 22, 22);
		[guestView addSubview:imageView];

		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, screenWidth/4.0, 12)];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
		titleLabel.text = title;
		[guestView addSubview:titleLabel];

		self.badgeView = [guestView whiteBadgeViewWithViewWidth:(screenWidth/4.0)];

		return guestView;
	};

	[tabBar addSubview:GuestButton([UIImage imageNamed:@"homepage_invitecustom_white"],@"邀请嘉宾")];

	[tabBar setItems:@[WTHomeItem(@"完善资料",@"homepage_information",WTHomeItemTypeProfile),
					   WTHomeItem(@"请柬设置",@"homepage_theme",WTHomeItemTypeTheme),
					   WTHomeItem(@"谱写故事",@"homepage_story",WTHomeItemTypeStory ),
					   WTHomeItem(@"",@"",WTHomeItemTypeBless),
					   ]];
	
	[tabBar setSelectedItem:tabBar.items[0]];
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
	}
}

-(void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end

//- (void)doneDomain:(NSString *)domian {
//	[PostDataService postWeddingHomePageUpadateInfomationWithName:nil
//													 andLoverName:nil
//														  androle:UserGenderUnknow
//											  andweddingTimestamp:-10
//														anddomain:domian
//												andWeddingAddress:nil
//												  andWeddingPoint:nil
//													   andMyAvata:nil
//												  andPartnerAvata:nil
//														withBlock:^(NSDictionary *result, NSError *error)
//	 {
//		 if (error) {
//			 MSLog(@"修改domain失败,%@",error);
//		 }else {
//			 MSLog(@"修改domain成功,%@",result);
//			 //  [PushNotifyCore pushMessageUpdateUserInfo];
//			 NSMutableDictionary *mudata = [[NSMutableDictionary alloc] initWithCapacity:10];
//			 for (id key in [result[@"data"] allKeys]) {
//				 mudata[key] = [LWAssistUtil cellInfo:result[@"data"][key] andDefaultStr:@""];
//			 }
//			 [LoginManager loginSucceedAfter:mudata];
//		 }
//	 }];
//}

