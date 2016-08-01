//
//  WTShopViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWeddingShopViewController.h"
#import "WTShopListViewController.h"
#import "WTFilterCityViewController.h"
#import "WTChatListViewController.h"
#import "WTLocationCityViewController.h"
#import "WTWeddingShopCell.h"
#import "WTTopView.h"
#import "MJRefresh.h"
#define kItemWidth (screenWidth / 4.5)
#define kScrollViewH 56
#define kScrollViewY (screenHeight - kScrollViewH)
@interface WTWeddingShopViewController () <UIScrollViewDelegate,WTTopViewDelegate,FilterSelectDelegate>
@property (nonatomic,assign) double preContentOffsetY;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) UIScrollView   *scrollView;
@property (nonatomic, strong) UIButton       *currentBtn;
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic, strong) WTShopListViewController  *mainVC;
@property (nonatomic, strong) WTShopListViewController  *planVC;
@property (nonatomic, strong) WTShopListViewController  *photoVC;
@property (nonatomic, strong) WTShopListViewController  *captureVC;
@property (nonatomic, strong) WTShopListViewController  *hostVC;
@property (nonatomic, strong) WTShopListViewController  *dressVC;
@property (nonatomic, strong) WTShopListViewController  *makeupVC;
@property (nonatomic, strong) WTShopListViewController  *videoVC;
@property (nonatomic, assign) WTWeddingType  type;
@property (nonatomic, copy) NSString         *cityID;
@end

@implementation WTWeddingShopViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	_topView.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.type = WTWeddingTypeShopMain;
	self.cityID = @([UserInfoManager instance].curCityId).stringValue;
    [self initView];
	[self loadData];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadNumUpdateNotificationAction:) name:unreadNumUpdateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
 
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)loadData
{
	if(self.type == WTWeddingTypeShopMain){
		[_mainVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_mainVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypePlan){
		[_planVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_planVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypePhoto){
		[_photoVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_photoVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypeCapture){
		[_captureVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_captureVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypeHost){
		[_hostVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_hostVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypeDress){
		[_dressVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_dressVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypeMakeUp){
		[_makeupVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_makeupVC.view belowSubview:_scrollView];
	}else if (self.type == WTWeddingTypeVideo){
		[_videoVC loadDataWithType:self.type andCity:self.cityID];
		[self.view insertSubview:_videoVC.view belowSubview:_scrollView];
	}

	CATransition* animation = [CATransition animation];
	[animation setDuration:0.3f];
	[animation setType:kCATransitionFade];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[[self.view layer]addAnimation:animation forKey:@"switchView"];
}

#pragma mark - Action
-(void)unreadNumUpdateNotificationAction:(NSNotification*)not
{
	self.topView.unreadCount = [not.userInfo[key_unread] doubleValue];
}

- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedCityFilter:(UIControl *)likeButton
{
	WTLocationCityViewController *locationVC = [[WTLocationCityViewController alloc] init];
	[locationVC setRefreshBlock:^(BOOL refresh) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_cityID = @([UserInfoManager instance].curCityId).stringValue;
			[self loadData];
		});
	}];
	[self.navigationController presentViewController:locationVC animated:YES completion:nil];
}
 
- (void)topView:(WTTopView *)topView didSelectedChat:(UIControl *)chatButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTChatListViewController new] animated:YES];
	}
}

- (void)cateAction:(UIButton *)cateBtn
{
	if([cateBtn isEqual:_currentBtn]) {return ;}
	_currentBtn.backgroundColor = [UIColor clearColor];
	cateBtn.backgroundColor = rgba(255, 140, 180, 1);
	_currentBtn = cateBtn;
	self.type = (WTWeddingType)cateBtn.tag;
	[self loadData];
}

#pragma mark - View
- (void)initView
{
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScrollViewY, screenWidth, kScrollViewH)];
    _scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	_scrollView.contentSize = CGSizeMake(kItemWidth * 8, kTabBarHeight);
	for (int i = 0; i < self.categoryArray.count; i++) {
        NSDictionary *cateDic = self.categoryArray[i];
        UIButton *cateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cateButton.frame = CGRectMake( i * kItemWidth, 0, kItemWidth, kScrollViewH);
		cateButton.contentEdgeInsets = UIEdgeInsetsMake(-12, 0, 0, 0);
        cateButton.tag = [cateDic[@"tag"] intValue];
        [cateButton setImage:[UIImage imageNamed:cateDic[@"image"]] forState:UIControlStateNormal];
        [cateButton addTarget:self action:@selector(cateAction:) forControlEvents:UIControlEventTouchUpInside];

		if(cateButton.tag == WTWeddingTypeShopMain){
			cateButton.backgroundColor = rgba(255, 140, 180, 1);
			_currentBtn = cateButton;
		}

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = DefaultFont12;
        titleLabel.text = cateDic[@"text"];
        titleLabel.frame = CGRectMake(i * kItemWidth, kTabBarHeight - 12, kItemWidth, 12);

		[_scrollView addSubview:cateButton];
        [_scrollView addSubview:titleLabel];
    }
    [self.view addSubview:self.scrollView];
 
    self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeCityFilter),@(WTTopViewTypeChat)]];
    self.topView.delegate = self;
    [self.view addSubview:_topView];

	_mainVC = [WTShopListViewController new];
	[self addChildViewController:_mainVC];
	_planVC = [WTShopListViewController new];
	[self addChildViewController:_planVC];
	_photoVC = [WTShopListViewController new];
	[self addChildViewController:_photoVC];
	_captureVC = [WTShopListViewController new];
	[self addChildViewController:_captureVC];
	_hostVC = [WTShopListViewController new];
	[self addChildViewController:_hostVC];
	_dressVC = [WTShopListViewController new];
	[self addChildViewController:_dressVC];
	_makeupVC = [WTShopListViewController new];
	[self addChildViewController:_makeupVC];
	_videoVC = [WTShopListViewController new];
	[self addChildViewController:_videoVC];
}

- (NSMutableArray *)categoryArray
{
return [@[@{@"tag":@(WTWeddingTypeShopMain),@"image":@"category_wedding_shop",@"text":@"新娘精选"}
          ,@{@"tag":@(WTWeddingTypePlan),@"image":@"category_wedding_plan",@"text":@"婚礼策划"}
          ,@{@"tag":@(WTWeddingTypePhoto),@"image":@"category_wedding_photo",@"text":@"婚纱写真"}
          ,@{@"tag":@(WTWeddingTypeCapture),@"image":@"category_wedding_follow",@"text":@"婚礼跟拍"}
          ,@{@"tag":@(WTWeddingTypeHost),@"image":@"category_wedding_holder",@"text":@"婚礼主持"}
          ,@{@"tag":@(WTWeddingTypeDress),@"image":@"category_wedding_choth",@"text":@"婚纱礼服"}
          ,@{@"tag":@(WTWeddingTypeMakeUp),@"image":@"category_wedding_sculpt",@"text":@"新娘跟妆"}
          ,@{@"tag":@(WTWeddingTypeVideo),@"image":@"category_wedding_video",@"text":@"婚礼摄像"}]
        mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
