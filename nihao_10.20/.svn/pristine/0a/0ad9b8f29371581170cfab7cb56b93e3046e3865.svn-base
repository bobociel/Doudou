//
//  HomeViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "HomeViewController.h"
#import "SwipeView.h"
#import "BaseFunction.h"
#import "PostViewController.h"
#import "AskViewController.h"
#import "TranslateViewController.h"
#import "DiscoverView.h"
#import "TopView.h"
#import "NewsView.h"
#import "FollowView.h"
#import "MeView.h"
#import "HomeWeatherView.h"
#import "WeatherViewController.h"
#import "UINavigationController+JZExtension.h"
#import <CoreLocation/CoreLocation.h>
#import "AppConfigure.h"
#import "HttpManager.h"
#import "GuideView.h"

@interface HomeViewController () <SwipeViewDataSource, SwipeViewDelegate, CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	CLGeocoder *_geocoder;
}

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (weak, nonatomic) IBOutlet UIButton *askBtn;
@property (weak, nonatomic) IBOutlet UIButton *translateBtn;
@property (weak, nonatomic) IBOutlet UILabel *discoverLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UILabel *meLabel;

@property (strong, nonatomic) HomeWeatherView *homeWeatherView;

// 蓝色滑块
@property (strong, nonatomic) UIView *slider;

@property (strong, nonatomic) DiscoverView *discoverView;
@property (strong, nonatomic) TopView *topView;
@property (strong, nonatomic) NewsView *newsView;
@property (strong, nonatomic) FollowView *followView;
@property (strong, nonatomic) MeView *meView;

@end

@implementation HomeViewController {
	// 保存头部的5个 UILabel，方便按照下标来使用
    NSArray *labels;
	// 保存每个 Tab 的显示状态
    NSMutableArray *categoriesShowStatus;
	// 当前显示的 Tab 的下标
    NSInteger currentIndex;
	// 滑块的宽度
    CGFloat sliderWidth;
	// 当前定位的坐标
	MyLocationCoordinate2D currentCoordinate;
	// 当前定位的城市名称
	NSString *currentCityName;
	// 所有的天气
	NSDictionary *allWeatherInfo;
	// 当前的天气情况
	NSDictionary *currentWeatherInfo;
	// 判断是否正在获取天气数据，防止同时多次获取
	BOOL isRequestWeather;
	// 天气现象字典
	NSDictionary *weatherPhenomenon;
}

#pragma mark - View Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_icon_home_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_icon_home_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"NiHao";
    [self initViews];
    [self initDatas];
	[self requestLocation];
    [self showUserGuide];
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
//	self.navigationController.navigationBar.translucent = NO;
	
	self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBarBackgroundAlpha = 1;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    static BOOL isAdded = NO;
    if (!isAdded) {
        [self drawLines];
        isAdded = YES;
	} else {
		// 不是第一次进入当前 VC，则刷新当前 Tab
		[self refreshCurrentSwipeView];
	}
	self.navigationController.navigationBarBackgroundAlpha = 1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.homeWeatherView = nil;
	self.discoverView = nil;
	self.topView = nil;
	self.newsView = nil;
	self.followView = nil;
	self.meView = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)initViews {
    _swipeView.pagingEnabled = YES;
    _swipeView.delegate = self;
    _swipeView.dataSource = self;
    _swipeView.bounces = NO;
    sliderWidth = SCREEN_WIDTH / 5.0;
    self.slider = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.categoryView.frame) - 2, sliderWidth, 2)];
    self.slider.backgroundColor = AppBlueColor;
    [self.categoryView addSubview:self.slider];
    self.discoverLabel.textColor = AppBlueColor;
	// Init Weather View
	self.homeWeatherView = [[HomeWeatherView alloc] initWithFrame:CGRectMake(0, 0, 70, 32)];
	[self.homeWeatherView configuerWeatherViewWithWeatherInfo:nil];
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showWeatherDetail)];
	[self.homeWeatherView addGestureRecognizer:tapGestureRecognizer];
	UIBarButtonItem *weatherItem = [[UIBarButtonItem alloc] initWithCustomView:self.homeWeatherView];
	self.navigationItem.rightBarButtonItem = weatherItem;
//	self.navigationBarBackgroundHidden = NO;
}

- (void)initDatas {
    labels = [NSArray arrayWithObjects:self.discoverLabel, self.topLabel, self.newsLabel, self.followLabel, self.meLabel, nil];
    currentIndex = 0;
    categoriesShowStatus = [NSMutableArray arrayWithObjects:@1, @0, @0, @0, @0, nil];
	isRequestWeather = NO;
	
	NSString *wpFilePath = [[NSBundle mainBundle] pathForResource:@"weather_phenomenon" ofType:@".txt"];
	NSData *tempWPData = [NSData dataWithContentsOfFile:wpFilePath];
	NSError *error = nil;
	weatherPhenomenon = [NSJSONSerialization JSONObjectWithData:tempWPData options:0 error:&error];
}

- (void)requestLocation {
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
	
	if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
		[_locationManager requestAlwaysAuthorization]; // 永久授权
	}
	
	_locationManager.delegate = self;
	// 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// 开始定位
	[_locationManager startUpdatingLocation];
	
	_geocoder = [[CLGeocoder alloc] init];
}

- (void)refreshWeatherView {
	NSMutableDictionary *weatherInfo = [[NSMutableDictionary alloc] initWithDictionary:currentWeatherInfo];
	NSString *weatherImageName = weatherPhenomenon[currentWeatherInfo[@"weather"]][@"home_image_name"];
    if(IsStringEmpty(weatherImageName)) {
        weatherImageName = @"icon_home_weather_sunny";
    }
	[weatherInfo setObject:weatherImageName forKey:@"weather_image_name"];
	[self.homeWeatherView configuerWeatherViewWithWeatherInfo:weatherInfo];
}

#pragma mark - SwipeViewDataSource, SwipeViewDelegate
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 5;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    NSInteger showStatus = [(NSNumber *)categoriesShowStatus[index] integerValue];
    if (!view) {
        NSLog(@"view is nil");
    }
    switch (index) {
        case 0:
            if (showStatus) {
                if (!self.discoverView) {
                    self.discoverView = [[DiscoverView alloc] initWithFrame:self.swipeView.bounds];
                    self.discoverView.navController = self.navigationController;
                }
                view = self.discoverView;
            }
            break;
        case 1:
            if (showStatus) {
                if (!self.topView) {
                    self.topView = [[TopView alloc] initWithFrame:self.swipeView.bounds];
                    self.topView.navigationController = self.navigationController;
                }
                
                view = self.topView;
            } else {
                view.backgroundColor = [UIColor whiteColor];
            }
            break;
        case 2:
            if (showStatus) {
                if (!self.newsView) {
                    self.newsView = [[NewsView alloc] initWithFrame:self.swipeView.bounds];
                    self.newsView.navController = self.navigationController;
                }
                
                view = self.newsView;
            } else {
                view.backgroundColor = [UIColor whiteColor];
            }
            break;
        case 3:
            if (showStatus) {
                if (!self.followView) {
                    self.followView = [[FollowView alloc] initWithFrame:self.swipeView.bounds];
					self.followView.navController = self.navigationController;
                }
                
                view = self.followView;
            } else {
                view.backgroundColor = [UIColor whiteColor];
            }
            break;
        case 4:
            if (showStatus) {
                if (!self.meView) {
                    self.meView = [[MeView alloc] initWithFrame:self.swipeView.bounds];
					self.meView.navController = self.navigationController;
                }
                
                view = self.meView;
            } else {
                view.backgroundColor = [UIColor whiteColor];
            }
            break;
    }
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return CGSizeMake(SCREEN_WIDTH, CGRectGetHeight(self.swipeView.frame));
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    NSInteger index = swipeView.currentItemIndex;
    UILabel *currentLabel = [labels objectAtIndex:currentIndex];
    UILabel *toLabel = [labels objectAtIndex:index];
    CGRect currentFrame = self.slider.frame;
    float x = sliderWidth * index;
    [UIView animateWithDuration:kSliderMoveDuration animations:^{
        currentLabel.textColor = HomeCategoryUnSelectedTextColor;
        self.slider.frame = CGRectMake(x, CGRectGetMinY(self.slider.frame), sliderWidth, CGRectGetHeight(currentFrame));
        toLabel.textColor = AppBlueColor;
    } completion:^(BOOL finished) {
    }];
    currentIndex = index;
}

// 当用户停止滑动界面时，再刷新界面
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    NSInteger index = swipeView.currentItemIndex;
    NSInteger showStatus = [categoriesShowStatus[index] integerValue];
    if (!showStatus) {
        [categoriesShowStatus replaceObjectAtIndex:index withObject:@1];
        [self.swipeView reloadItemAtIndex:index];
    }
}

#pragma mark - Touch Events

- (void)showWeatherDetail {
    if(allWeatherInfo) {
        if([allWeatherInfo[@"showapi_res_body"][@"ret_code"] integerValue] == 0 && [allWeatherInfo[@"showapi_res_code"] integerValue] == 0) {
            WeatherViewController *weatherViewController = [[WeatherViewController alloc] init];
            weatherViewController.navigationBarBackgroundHidden = YES;
            weatherViewController.locationCityName = currentCityName;
            weatherViewController.locationWeatherInfo = allWeatherInfo;
            weatherViewController.currentCoordinate = currentCoordinate;
            weatherViewController.weatherPhenomenon = weatherPhenomenon;
            [self.navigationController pushViewController:weatherViewController animated:YES];
        }
    }
}

- (IBAction)postBtnClick:(id)sender {
    PostViewController *postViewController = [[PostViewController alloc] init];
    postViewController.post = ^(UserPost *post) {
        //更新discover页面
        if(_swipeView.currentPage != 0) {
            [_swipeView scrollToPage:0 duration:0];
        }
        //更新discover页面
        [_discoverView addUserPost:post atIndex:0];
		//更新 Me 页面
		[self.meView addUserPost:post atIndex:0];
    };
    [self.navigationController pushViewController:postViewController animated:YES];
}

- (IBAction)askBtnClick:(id)sender {
    AskViewController *askViewController = [[AskViewController alloc] init];
    [self.navigationController pushViewController:askViewController animated:YES];
}

- (IBAction)translateBtnClick:(id)sender {
    TranslateViewController *translateViewController = [[TranslateViewController alloc] init];
    [self.navigationController pushViewController:translateViewController animated:YES];
}

- (IBAction)discoverClick:(id)sender {
    [self.swipeView scrollToItemAtIndex:0 duration:0];
}

- (IBAction)topClick:(id)sender {
    [categoriesShowStatus replaceObjectAtIndex:1 withObject:@1];
    [self.swipeView scrollToItemAtIndex:1 duration:0];
}

- (IBAction)newsClick:(id)sender {
    [categoriesShowStatus replaceObjectAtIndex:2 withObject:@1];
    [self.swipeView scrollToItemAtIndex:2 duration:0];
}

- (IBAction)followClick:(id)sender {
    [categoriesShowStatus replaceObjectAtIndex:3 withObject:@1];
    [self.swipeView scrollToItemAtIndex:3 duration:0];
}

- (IBAction)meClick:(id)sender {
    [categoriesShowStatus replaceObjectAtIndex:4 withObject:@1];
    [self.swipeView scrollToItemAtIndex:4 duration:0];
}

#pragma mark - Network
#pragma mark 获取当前的天气情况
- (void)requestCurrentWeather {
	isRequestWeather = YES;
	// 参数串排序
	// from3lat30.162546lng120.198408needIndex1needMoreDay1showapi_appid4644showapi_timestamp20150730134522
//	NSString *timeStamp = [BaseFunction getTimeStampAtCurrentTime];
	NSString *lat = [NSString stringWithFormat:@"%lf", currentCoordinate.latitude];
	NSString *lng = [NSString stringWithFormat:@"%lf", currentCoordinate.longitude];
//	NSString *argsString = [NSString stringWithFormat:@"from3lat%@lng%@needIndex1needMoreDay1showapi_appid%@showapi_timestamp%@%@", lat, lng, ShowAPI_Appid, timeStamp, ShowAPI_Secret];
//	NSLog(@"weather args string = %@", argsString);
//	// 签名加密参数串
//	NSString *signString = [BaseFunction md5Digest:argsString];
//	NSLog(@"sha1 signString = %@", signString);
//	
//	// 配置参数
//	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//	[parameters setObject:@"3" forKey:@"from"];
//	[parameters setObject:lat forKey:@"lat"];
//	[parameters setObject:lng forKey:@"lng"];
//	[parameters setObject:@"1" forKey:@"needIndex"];
//	[parameters setObject:@"1" forKey:@"needMoreDay"];
//	[parameters setObject:ShowAPI_Appid forKey:@"showapi_appid"];
//	[parameters setObject:timeStamp forKey:@"showapi_timestamp"];
//	[parameters setObject:signString forKey:@"showapi_sign"];
//	
//	NSLog(@"weather parameters = %@", parameters);
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:lat forKey:@"lat"];
	[parameters setObject:lng forKey:@"lng"];
	
	[HttpManager requestWeatherByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"showapi_res_code"] integerValue] == 0) {// 为0就是获取成功，否则为失败
			allWeatherInfo = (NSDictionary *)responseObject;
            if([allWeatherInfo[@"showapi_res_body"][@"ret_code"] integerValue] != 0) {
                [self showHUDErrorWithText:@"Fail to get weather condition"];
            }
			currentWeatherInfo = allWeatherInfo[@"showapi_res_body"][@"now"];
			[self refreshWeatherView];
		} else {
			[self showHUDErrorWithText:responseObject[@"showapi_res_error"]];
		}
		isRequestWeather = NO;
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		isRequestWeather = NO;
	}];
	
//	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"weather" ofType:@".txt"];
//	NSData *tempData = [NSData dataWithContentsOfFile:filePath];
//	allWeatherInfo = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
//	currentWeatherInfo = allWeatherInfo[@"showapi_res_body"][@"now"];
//	[self refreshWeatherView];
}

#pragma mark - other functions
- (void)drawLines {
    CGFloat x = 0;
    for (int i = 0; i < 2; i++) {
        x += self.postBtn.frame.size.width;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, 8, 0.5f, CGRectGetHeight(self.actionView.frame) - 16)];
        line.backgroundColor = SeparatorColor;
        [self.actionView addSubview:line];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.actionView.frame) - 0.5, SCREEN_WIDTH, 0.5f)];
    line.backgroundColor = SeparatorColor;
    [self.actionView addSubview:line];
}

// 刷新当前的 Tab
- (void)refreshCurrentSwipeView {
	NSInteger index = self.swipeView.currentItemIndex;
	switch (index) {
		case 0:
			[self.discoverView refreshTableView];
			break;
		case 1:
			[self.topView refreshTopView];
			break;
		case 2:
			[self.newsView refreshTableView];
			break;
		case 3:
			[self.followView refreshTableView];
			break;
		case 4:
			[self.meView refreshTableView];
			break;
	}
}

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[manager stopUpdatingLocation];
	currentCoordinate.latitude = location.coordinate.latitude;
	currentCoordinate.longitude = location.coordinate.longitude;
	NSLog(@"latitude = %lf, longitude = %lf", location.coordinate.latitude, location.coordinate.longitude);
	[self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// 定位失败，默认杭州
	currentCoordinate.latitude = 30.319;
	currentCoordinate.longitude = 120.165;
	CLLocation *location = [[CLLocation alloc] initWithLatitude:30.319 longitude:120.165];
	[self getCityInfoByLocation:location];
	if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can't get your location" message:@"please open app location service in settings" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
		[alert show];
	} else {
		
	}
}

/*
 * @param coordinate 经纬度
 *
 */
- (void) getCityInfoByLocation : (CLLocation *) location {
	//反向地理编码
	[_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (!error && [placemarks count] > 0) {
			NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
			currentCityName = dict[@"City"];
			[AppConfigure setObject:currentCityName ForKey:LOCATE_CITY];
			if (!isRequestWeather) {
				// 定位成功之后，获取当前天气
				[self requestCurrentWeather];
			}
		} else {
			NSLog(@"ERROR: %@", error);
		}}];
}

/**
 *  显示消息页面未读消息数量的小红点
 */
- (void) showMsgUnreadMessages {
    NSInteger unreadMsg = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    UINavigationController *msgNavController = (UINavigationController *)self.navigationController.tabBarController.viewControllers[1];
    UIViewController *msgViewController = msgNavController.viewControllers[0];
    msgViewController.tabBarItem.badgeValue = (unreadMsg == 0) ? nil : [NSString stringWithFormat:@"%ld",unreadMsg];
}

- (void) showUserGuide {
    BOOL isNotFirstOpen = [AppConfigure boolForKey:FIRST_OPEN_HOME];
    if(!isNotFirstOpen) {
        GuideView *postGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_post"];
        __weak typeof(postGuide) weakPostGuide = postGuide;
        postGuide.getItButtonClick = ^(){
            __strong typeof(weakPostGuide) strongPostGuide = weakPostGuide;
            [strongPostGuide removeFromSuperview];
            GuideView *askGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_ask"];
            [[UIApplication sharedApplication].keyWindow addSubview:askGuide];
            __weak typeof(postGuide) weakAskGuide = askGuide;
            askGuide.getItButtonClick = ^(){
                __strong typeof(weakAskGuide) strongAskGuide = weakAskGuide;
                [strongAskGuide removeFromSuperview];
                GuideView *translateGuide = [[GuideView alloc] initWithBackgroundImageName:@"bg_translate"];
                [[UIApplication sharedApplication].keyWindow addSubview:translateGuide];
            };
        };
        [[UIApplication sharedApplication].keyWindow addSubview:postGuide];
        [AppConfigure setBool:YES forKey:FIRST_OPEN_HOME];
    }
}

@end
