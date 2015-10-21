//
//  WeatherViewController.m
//  nihao
//
//  Created by HelloWorld on 7/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "WeatherViewController.h"
#import "UINavigationController+JZExtension.h"
#import "Constants.h"
#import "ForecastCell.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AppConfigure.h"

@interface WeatherViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	CLGeocoder *_geocoder;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weatherStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherCurrentTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherPM25Label;
@property (weak, nonatomic) IBOutlet UILabel *weatherAirQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherWindDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherWindLevelLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *weatherForecastCollectionView;
@property (weak, nonatomic) IBOutlet UIView *weatherMiddleIndexView;
@property (weak, nonatomic) IBOutlet UILabel *weatherAirHumidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherAirIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherAirCOLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherUltravioletRayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDressingIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherComfortLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherSportsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherTourLabel;

@end

static NSString *ForecastCellIdentifier = @"ForecastCell";

@implementation WeatherViewController {
	// 用户选择城市之后的该城市全部的天气信息
	NSDictionary *selectedCityWeatherInfo;
	// 当前的天气信息
	NSDictionary *currentWeatherInfo;
	// 今天的天气信息
	NSDictionary *todayWeatherInfo;
	// 是否是选择的城市
	BOOL isSelectedCityWeather;
	// 是否是第一次进入
	BOOL isFirst;
	BOOL hasWeatherInfo;
	MyLocationCoordinate2D privateCoordinate;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.view.backgroundColor = RootBackgroundColor;
	// 不显示返回 Title
	[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
	
//	UIBarButtonItem *selectLocationItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_select_location_btn_img"] style:UIBarButtonItemStylePlain target:self action:@selector(selectLocation)];
//	self.navigationItem.rightBarButtonItem = selectLocationItem;
	self.title = self.locationCityName;
	
	isFirst = YES;
	
	self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
	self.navigationController.navigationBar.translucent = YES;
	
	[self initDatas];
	[self setUpViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!isFirst) {
//		[self requestCurrentWeather];
		[self requestLocation];
	} else {
		isFirst = NO;
	}
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.scrollView.delegate = nil;
	self.weatherForecastCollectionView.delegate = nil;
	self.weatherForecastCollectionView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initDatas {
//	if (!self.locationWeatherInfo) {// 测试数据
//		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"weather" ofType:@".txt"];
//		NSData *tempData = [NSData dataWithContentsOfFile:filePath];
//		self.locationWeatherInfo = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
//	}
	if (self.locationWeatherInfo) {
		isSelectedCityWeather = NO;
//		isFirst = YES;
		hasWeatherInfo = YES;
		
		privateCoordinate.latitude = self.currentCoordinate.latitude;
		privateCoordinate.longitude = self.currentCoordinate.longitude;
		
		currentWeatherInfo = self.locationWeatherInfo[@"showapi_res_body"][@"now"];
		todayWeatherInfo = self.locationWeatherInfo[@"showapi_res_body"][@"f1"];
		
//		NSString *wpFilePath = [[NSBundle mainBundle] pathForResource:@"weather_phenomenon" ofType:@".txt"];
//		NSData *tempWPData = [NSData dataWithContentsOfFile:wpFilePath];
//		NSError *error = nil;
//		self.weatherPhenomenon = [NSJSONSerialization JSONObjectWithData:tempWPData options:0 error:&error];
	} else {
		hasWeatherInfo = NO;
		[self requestCurrentWeather];
	}
}

- (void)setUpViews {
	CGRect frame = self.view.frame;
	frame.origin.y = -64;
	self.view.frame = frame;
	
	self.weatherView.frame = CGRectMake(0, -64, SCREEN_WIDTH, CGRectGetHeight(self.weatherView.frame));
	self.scrollView.contentSize = self.weatherView.frame.size;
	self.scrollView.backgroundColor = [UIColor whiteColor];
	[self.scrollView addSubview:self.weatherView];
	self.scrollView.delegate = self;
	
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(100, 200);
	layout.minimumLineSpacing = 0;
	layout.minimumInteritemSpacing = 0;
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.weatherForecastCollectionView.collectionViewLayout = layout;
	self.weatherForecastCollectionView.delegate = self;
	self.weatherForecastCollectionView.dataSource = self;
	[self.weatherForecastCollectionView registerNib:[UINib nibWithNibName:@"ForecastCell" bundle:nil] forCellWithReuseIdentifier:ForecastCellIdentifier];
	
	[self drawLines];

	if (hasWeatherInfo) {
		[self configureWeatherView];
	} else {
		[self refreshToBlankView];
	}
}

- (void)drawLines {
	// 顶部两条白色竖线
	UIView *topInfoView = self.weatherPM25Label.superview;
	CGFloat infoX = SCREEN_WIDTH / 3.0;
	for (int i = 0; i < 2; i++) {
		UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(infoX, 5, 0.5, 60)];
		verticalLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
		[topInfoView addSubview:verticalLine];
		infoX *= 2;
	}
	
	// 未来6天天气5条竖线
	NSInteger forecastX = 100;
	for (int i = 0; i < 5; i++) {
		UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(forecastX, 15, 0.5, 170)];
		verticalLine.backgroundColor = SeparatorColor;
		[self.weatherForecastCollectionView addSubview:verticalLine];
		forecastX += 100;
	}
	
	// Index
	CGFloat indexViewY = 0;
	for (int i = 0; i < 2; i++) {
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, indexViewY, SCREEN_WIDTH, 0.5)];
		line.backgroundColor = SeparatorColor;
		[self.weatherMiddleIndexView addSubview:line];
		indexViewY += (CGRectGetHeight(self.weatherMiddleIndexView.frame) - 0.5);
	}
	
	// More Information View
	NSInteger moreY = CGRectGetMaxY(self.weatherMiddleIndexView.frame) + 70;
	for (int i = 0; i < 4; i++) {
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, moreY, SCREEN_WIDTH, 0.5)];
		line.backgroundColor = SeparatorColor;
		[self.weatherView addSubview:line];
		moreY += 70;
	}
	
	UIView *veriticalLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0, CGRectGetMaxY(self.weatherMiddleIndexView.frame), 0.5, 280)];
	veriticalLine.backgroundColor = SeparatorColor;
	[self.weatherView addSubview:veriticalLine];
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

- (void)configureWeatherView {
	self.title = self.locationCityName;
	
	NSString *weatherBGImageName = self.weatherPhenomenon[currentWeatherInfo[@"weather"]][@"weather_bg_image_name"];
	self.weatherImageView.image = [UIImage imageNamed:weatherBGImageName];
	NSString *weatherStatusImageName = self.weatherPhenomenon[currentWeatherInfo[@"weather"]][@"weather_status_image_name"];
	self.weatherStatusImageView.image = [UIImage imageNamed:weatherStatusImageName];
	
	self.weatherCurrentTemperatureLabel.text = [NSString stringWithFormat:@"%ld°", [currentWeatherInfo[@"temperature"] integerValue]];
	self.weatherStatusLabel.text = self.weatherPhenomenon[currentWeatherInfo[@"weather"]][@"en_name"];
	self.weatherPM25Label.text = [NSString stringWithFormat:@"%ld", [currentWeatherInfo[@"aqiDetail"][@"pm2_5"] integerValue]];
//	self.weatherAirQualityLabel.text = [BaseFunction getAirQualityEnglishNameByChinese:currentWeatherInfo[@"aqiDetail"][@"quality"]];
	self.weatherAirQualityLabel.text = currentWeatherInfo[@"aqiDetail"][@"quality"];
//	self.weatherWindDirectionLabel.text = [BaseFunction getWindDirectionEnglishNameByChineseName:currentWeatherInfo[@"wind_direction"]];
	self.weatherWindDirectionLabel.text = currentWeatherInfo[@"wind_direction"];
	NSMutableString *windPowerOriginal = [[NSMutableString alloc] initWithString:currentWeatherInfo[@"wind_power"]];
	NSString *windPower = [windPowerOriginal stringByReplacingOccurrencesOfString:@"级" withString:@""];
	self.weatherWindLevelLabel.text = [NSString stringWithFormat:@"Class %@", windPower];
	self.weatherAirHumidityLabel.text = currentWeatherInfo[@"sd"];
	self.weatherAirIndexLabel.text = [NSString stringWithFormat:@"%ld", [currentWeatherInfo[@"aqiDetail"][@"aqi"] integerValue]];
	self.weatherAirCOLabel.text = [NSString stringWithFormat:@"%.3f", [currentWeatherInfo[@"aqiDetail"][@"co"] floatValue]];
//	self.weatherUltravioletRayLabel.text = [BaseFunction getUVLevelByChineseName:todayWeatherInfo[@"index"][@"uv"][@"title"]];
	self.weatherUltravioletRayLabel.text = todayWeatherInfo[@"index"][@"uv"][@"title"];
//	self.weatherDressingIndexLabel.text = [BaseFunction getClothesIndexENByChineseName:todayWeatherInfo[@"index"][@"clothes"][@"title"]];
//	self.weatherComfortLevelLabel.text = [BaseFunction getComfortLevelENByChineseName:todayWeatherInfo[@"index"][@"comfort"][@"title"]];
//	self.weatherSportsLabel.text = [BaseFunction getSportsLevenENByChineseName:todayWeatherInfo[@"index"][@"sports"][@"title"]];
//	self.weatherTourLabel.text = [BaseFunction getTravelLevelENByChineseName:todayWeatherInfo[@"index"][@"travel"][@"title"]];
	self.weatherDressingIndexLabel.text = todayWeatherInfo[@"index"][@"clothes"][@"title"];
	self.weatherComfortLevelLabel.text = todayWeatherInfo[@"index"][@"comfort"][@"title"];
	self.weatherSportsLabel.text = todayWeatherInfo[@"index"][@"sports"][@"title"];
	self.weatherTourLabel.text = todayWeatherInfo[@"index"][@"travel"][@"title"];
	[self.weatherForecastCollectionView reloadData];
}

- (void)refreshToBlankView {
	self.weatherImageView.image = [UIImage imageNamed:@"weather_sunny.jpg"];
	self.weatherStatusImageView.image = nil;
	self.weatherCurrentTemperatureLabel.text = @"";
	self.weatherStatusLabel.text = @"";
	self.weatherPM25Label.text = @"";
	self.weatherAirQualityLabel.text = @"";
	self.weatherWindDirectionLabel.text = @"";
	self.weatherWindLevelLabel.text = @"";
	self.weatherAirHumidityLabel.text = @"";
	self.weatherAirIndexLabel.text = @"";
	self.weatherAirCOLabel.text = @"";
	self.weatherUltravioletRayLabel.text = @"";
	self.weatherDressingIndexLabel.text = @"";
	self.weatherComfortLevelLabel.text = @"";
	self.weatherSportsLabel.text = @"";
	self.weatherTourLabel.text = @"";
}

#pragma mark - Network
#pragma mark 获取当前的天气情况
- (void)requestCurrentWeather {
	// 参数串排序
	// from3lat30.162546lng120.198408needIndex1needMoreDay1showapi_appid4644showapi_timestamp20150730134522
	NSString *timeStamp = [BaseFunction getTimeStampAtCurrentTime];
	NSString *lat = [NSString stringWithFormat:@"%lf", privateCoordinate.latitude];
	NSString *lng = [NSString stringWithFormat:@"%lf", privateCoordinate.longitude];
	NSString *argsString = [NSString stringWithFormat:@"from3lat%@lng%@needIndex1needMoreDay1showapi_appid%@showapi_timestamp%@%@", lat, lng, ShowAPI_Appid, timeStamp, ShowAPI_Secret];
	NSLog(@"weather args string = %@", argsString);
	// 签名加密参数串
	NSString *signString = [BaseFunction md5Digest:argsString];
	NSLog(@"sha1 signString = %@", signString);
	
	// 配置参数
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:@"3" forKey:@"from"];
	[parameters setObject:lat forKey:@"lat"];
	[parameters setObject:lng forKey:@"lng"];
	[parameters setObject:@"1" forKey:@"needIndex"];
	[parameters setObject:@"1" forKey:@"needMoreDay"];
	[parameters setObject:ShowAPI_Appid forKey:@"showapi_appid"];
	[parameters setObject:timeStamp forKey:@"showapi_timestamp"];
	[parameters setObject:signString forKey:@"showapi_sign"];
	
	NSLog(@"weather parameters = %@", parameters);
	
	[HttpManager requestWeatherByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"showapi_res_code"] integerValue] == 0) {// 为0就是获取成功，否则为失败
			hasWeatherInfo = YES;
			self.locationWeatherInfo = (NSDictionary *)responseObject;
			currentWeatherInfo = self.locationWeatherInfo[@"showapi_res_body"][@"now"];
			todayWeatherInfo = self.locationWeatherInfo[@"showapi_res_body"][@"f1"];
			[self configureWeatherView];
		} else {
			hasWeatherInfo = NO;
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		hasWeatherInfo = NO;
	}];
}

#pragma mark - Touch Events

- (void)selectLocation {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.scrollView) {
		CGFloat scrollY = scrollView.contentOffset.y;
		CGFloat alpha = (scrollY + 64) / 182;
//		NSLog(@"scrollY = %lf, alpha = %lf", scrollY, alpha);
		self.navigationController.navigationBarBackgroundAlpha = alpha;
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ForecastCell *cell = (ForecastCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ForecastCellIdentifier forIndexPath:indexPath];
	
	if (hasWeatherInfo) {
		NSString *forecastKey = [NSString stringWithFormat:@"f%ld", indexPath.row + 2];
		NSDictionary *forecastInfo = self.locationWeatherInfo[@"showapi_res_body"][forecastKey];
		if (forecastKey) {
			[cell configureCellWithForecastInfo:forecastInfo forRowAtIndexPath:indexPath weatherPhenomenonDictionary:self.weatherPhenomenon];
		} else {
			[cell showCellSubViews:NO];
		}
	} else {
		[cell showCellSubViews:NO];
	}

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[manager stopUpdatingLocation];
	privateCoordinate.latitude = location.coordinate.latitude;
	privateCoordinate.longitude = location.coordinate.longitude;
	NSLog(@"latitude = %lf, longitude = %lf", location.coordinate.latitude, location.coordinate.longitude);
	[self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// 定位失败，默认杭州
	privateCoordinate.latitude = 30.319;
	privateCoordinate.longitude = 120.165;
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
			self.locationCityName = dict[@"City"];
			[AppConfigure setObject:self.locationCityName ForKey:LOCATE_CITY];
			// 定位成功之后，获取当前天气
			[self requestCurrentWeather];
		} else {
			NSLog(@"ERROR: %@", error);
		}}];
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
