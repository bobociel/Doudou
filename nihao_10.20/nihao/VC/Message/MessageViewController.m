//
//  MessageViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "MessageDetailController.h"
#import "FriendsMessageView.h"
#import "GroupsMessageView.h"
#import "EaseMob.h"
#import "AppConfigure.h"
#import "GuideView.h"

@interface MessageViewController () {
    FriendsMessageView *_friendsMessageView;
    GroupsMessageView *_groupsMessageView;
    UISegmentedControl *_segmentedControl;
}

@end

@implementation MessageViewController

#pragma mark - view life cycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_icon_message_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_icon_message_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Message" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    self.title = @"Message";
    //[self addTitleSegmented];
    [self addSearchIcon];
    [self initSwipeView];
    [self showUserGuide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_friendsMessageView) {
        [_friendsMessageView initConversationData];
    }
    NSUInteger unreadMsgNums = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    NSString *badgeValue = (unreadMsgNums == 0) ? nil : [NSString stringWithFormat:@"%ld",unreadMsgNums];
    self.tabBarItem.badgeValue = badgeValue;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 给标题添加选择器
- (void) addTitleSegmented {
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Friends", @"Groups"]];
    [_segmentedControl setTintColor:[UIColor colorWithRed:183.0/255 green:227.0/255 blue:255.0/255 alpha:1.0]];
    [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [_segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _segmentedControl;
}

- (void) segmentedControlChanged : (id) sender {
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    if(index == 0) {
        _groupsMessageView.hidden = YES;
        _friendsMessageView.hidden = NO;
    } else {
        _friendsMessageView.hidden = YES;
        _groupsMessageView.hidden = NO;
    }
}

#pragma mark - 搜索逻辑
- (void) addSearchIcon {
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:[self createNavBtnSearch:@"icon_search" action:@selector(search)]];
    self.navigationItem.rightBarButtonItem = searchItem;
}

-(UIButton *)createNavBtnSearch:(NSString *)icon action:(SEL) action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,25,25);
    if(icon) {
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void) search {
    
}

- (void) initSwipeView {
	CGFloat tabbarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    _friendsMessageView = [[FriendsMessageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - tabbarHeight)];
    [self.view addSubview:_friendsMessageView];
    //_groupsMessageView = [[GroupsMessageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64- tabbarHeight)];
    //[self.view addSubview:_groupsMessageView];
    //_groupsMessageView.hidden = YES;
}

- (void) showUserGuide {
    BOOL isFirstOpenMessage = [AppConfigure boolForKey:FIRST_OPEN_MESSAGE];
    if(!isFirstOpenMessage) {
        GuideView *guideView = [[GuideView alloc] initWithBackgroundImageName:@"bg_message"];
        [[UIApplication sharedApplication].keyWindow addSubview:guideView];
        [AppConfigure setBool:YES forKey:FIRST_OPEN_MESSAGE];
    }
}

@end
