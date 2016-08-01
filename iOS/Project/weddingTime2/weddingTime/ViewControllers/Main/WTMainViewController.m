//
//  WTMainViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTMainViewController.h"
#import "WTExpandViewController.h"
#import "WTCategoryViewController.h"
#import "WTStoryListViewController.h"
#import "PaperButton.h"
#import "WTPCViewController.h"
#import "UserInfoManager.h"
#import "QHNavigationController.h"
#import "WTFindViewController.h"
#import "WTLoadingViewController.h"
#import "WTLoginViewController.h"
#import "WTChatListViewController.h"
#import "ChatMessageManager.h"
#import "ConversationStore.h"
#import "LoginManager.h"
#import "WTUploadManager.h"
#import "GetService.h"
@interface WTMainViewController ()<PaperButtonDelegate,UITabBarControllerDelegate>
{
    PaperButton* button;
}
@property (nonatomic,strong)WTExpandViewController *expandViewController;
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

	if([UserInfoManager instance].userId_self.length > 0 )
	{
		[[SQLiteAssister sharedInstance] loadDataBasePersonal];
	}

    self.delegate=self;
    self.tabBar.backgroundColor=[UIColor whiteColor];
    self.tabBar.tintColor=[WeddingTimeAppInfoManager instance].baseColor;
    [self setViewControllers:[NSArray arrayWithObjects:
                              [self viewControllerWithController:[WTFindViewController new] title:nil image:[UIImage imageNamed:@"tabbar_discover"]],
                              [self viewControllerWithController:[WTCategoryViewController new] title:nil image:[UIImage imageNamed:@"tabbar_class"]],
                              [self viewControllerWithController:[UIViewController new] title:nil image:nil],
                              [self viewControllerWithController:[WTChatListViewController new] title:nil image:[UIImage imageNamed:@"tabbar_chat"]],
                              [self viewControllerWithController:[WTPCViewController new] title:nil image:[UIImage imageNamed:@"tabbar_center"]], nil] animated:YES] ;
    
    [self addCenterButton];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unreadNumUpdateNotificationAction:) name:unreadNumUpdateNotification object:nil];
}

-(void)unreadNumUpdateNotificationAction:(NSNotification*)not
{
    UIViewController *chatController = self.viewControllers[3];
    NSString *num=not.userInfo[key_unread];
    chatController.tabBarItem.title=num;
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
		self.selectedIndex = 4;
		[UserInfoManager instance].showBling = NO;
		[[UserInfoManager instance] saveOtherToUserDefaults];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	static dispatch_once_t once;
	dispatch_once(&once, ^{
		if (![[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
			WTLoadingViewController *next=[[WTLoadingViewController alloc] initWithNibName:@"WTLoadingViewController" bundle:nil];
			[self.navigationController pushViewController:next animated:NO];
		}
	});

	//判断个人视频故事上传缓存
	if([[UserInfoManager instance].tokenId_self isNotEmptyCtg])
	{
		if( [[WTUploadManager manager] hasCache] )
		{
			WTStoryListViewController *storyVC = [[WTStoryListViewController alloc] init];
			[self.navigationController pushViewController:storyVC animated:NO];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[SDImageCache sharedImageCache] clearMemory];
}

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*)viewControllerWithController:(UIViewController*) viewController title:(NSString*)title image:(UIImage*)image
{
    CGFloat offset = 5.0;
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    viewController.tabBarItem.titlePositionAdjustment=UIOffsetMake(0, -17);
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [WeddingTimeAppInfoManager fontWithSize:12], NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];

    if (!image) {
        [viewController.tabBarItem setEnabled:NO];
    }
    
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButton
{
    button = [[PaperButton alloc]initWithFrame:CGRectMake(0.0, 0.0, 50, 36)];
    [button setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
    button.tintColor = [UIColor whiteColor];
    button.layer.cornerRadius=3;
    button.delegate = self;
    button.layer.masksToBounds=YES;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    //  button.frame = CGRectMake(0.0, 0.0, 50, 36);
    
    CGFloat heightDifference = button.frame.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    //  button.frame = CGRectMake(0.0, 0.0, 50, 36);

    CGPoint center = self.tabBar.center;
    center.y =self.tabBar.height/2;
    button.center = center;
    
    [self.tabBar addSubview:button];
}

#pragma mark UITabBarDelegate

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [button animateToMenu];
    if([[UserInfoManager instance].tokenId_self isNotEmptyCtg]||(item!=tabBar.items[4]&&item!=tabBar.items[3]))
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
    [self.view insertSubview:self.expandViewController.view  belowSubview:self.tabBar];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:unreadNumUpdateNotification object:nil];
}

- ( BOOL )tabBarController:( UITabBarController *)tabBarController shouldSelectViewController :( UIViewController *)viewController{
    if(![[UserInfoManager instance].tokenId_self isNotEmptyCtg]&&([viewController isKindOfClass:[WTPCViewController class]]||[viewController isKindOfClass:[WTChatListViewController class]]))
    {
        [LoginManager pushToLoginViewControllerWithAnimation:YES];
        return NO ;
    }
    return YES ;
}
@end
