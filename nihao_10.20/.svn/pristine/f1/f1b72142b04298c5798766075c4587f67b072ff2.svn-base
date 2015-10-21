//
//  SelectCityViewController.m
//  nihao
//
//  Created by HelloWorld on 7/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "SelectCityViewController.h"
#import "BaseFunction.h"
#import "BATableView.h"
#import "CityCell.h"
#import "HttpManager.h"
#import <MJExtension/MJExtension.h>
#import "City.h"
#import "ListingLoadingStatusView.h"
#import "AppConfigure.h"
#import "SelectCityHeaderView.h"
#import <CoreLocation/CoreLocation.h>

@interface SelectCityViewController () <BATableViewDelegate, UISearchDisplayDelegate, SelectCityHeaderViewDelegate, CLLocationManagerDelegate> {
	ListingLoadingStatusView *_loadingStatusView;
	NSMutableArray *_filteredData;
	CLLocationManager *_locationManager;
	CLGeocoder *_geocoder;
	// 定位城市
	City *_locateCity;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;
@property (strong, nonatomic) BATableView *tableView;
@property (strong, nonatomic) SelectCityHeaderView *selectCityHeaderView;

@end

static NSString *CityCellIdentifier = @"citycellidentifier";

@implementation SelectCityViewController {
	BOOL isSearching;
	NSArray *hotCities;
	NSMutableDictionary *allCities;
	NSArray *allCityArray;
	NSString *locateCityName;
	NSArray *sortedKeys;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Select City";
	
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	
	isSearching = NO;
	
	[self initViews];
	[self requestLocation];
	[self requestHotCityList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews {
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	[self.view addSubview:self.searchBar];
	self.searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	self.searchBarController.delegate = self;
	[self.searchBarController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CityCell" bundle:nil] forCellReuseIdentifier:CityCellIdentifier];
	self.searchBarController.searchResultsTableView.rowHeight = 60;
	self.searchBarController.searchResultsDataSource = self;
	self.searchBarController.searchResultsDelegate = self;
	self.searchBarController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
	
	self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	self.tableView.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.tableView.rowHeight = 60;
	[self.tableView.tableView registerNib:[UINib nibWithNibName:@"CityCell" bundle:nil] forCellReuseIdentifier:CityCellIdentifier];
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	
	// 初始化加载状态view
	_loadingStatusView = [[ListingLoadingStatusView alloc] initWithFrame:self.view.frame];
	__weak SelectCityViewController *weakSelf = self;
	_loadingStatusView.backgroundColor = [UIColor clearColor];
	_loadingStatusView.refresh = ^() {
		[weakSelf requestHotCityList];
	};
	[self.view addSubview:_loadingStatusView];
	
	self.tableView.hidden = YES;
	self.searchBar.hidden = YES;
}

- (void)initHeaderView {
	self.selectCityHeaderView = [[SelectCityHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 192)];
	[self.selectCityHeaderView configureViewWithHotCities:hotCities];
	if (IsStringNotEmpty(_locateCity.city_name_en)) {
		locateCityName = _locateCity.city_name_en;
	} else {
		locateCityName = @"Locating...";
	}
	[self.selectCityHeaderView setCurrentCityName:locateCityName];
	self.selectCityHeaderView.delegate = self;
	
	self.tableView.tableView.tableHeaderView = self.selectCityHeaderView;
}

#pragma mark - Private

- (BOOL)isCityAvailable:(NSString *)cityNameEn {
	NSArray *cities = [City getCityListFromUserDefault];
	BOOL available = NO;
	for(City *city in cities) {
		NSString *cityName = city.city_name_en;
		// 去除字符串中间的空格并转为小写字母后与默认城市比较
		cityName = [[cityName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
		if ([cityNameEn compare:cityName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			available = YES;
			_locateCity = city;
			break;
		}
	}
	return available;
}

/**
 *  请求定位
 */
- (void) requestLocation {
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
	
	if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
		[_locationManager requestAlwaysAuthorization]; // 永久授权
	}
	
	_locationManager.delegate = self;
	// 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// 开始定位
	[_locationManager startUpdatingLocation];
	
	_geocoder = [[CLGeocoder alloc] init];
	_locateCity = [[City alloc] init];
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *)sortKeys {
	if (!sortedKeys) {
		NSArray *keys = [allCities allKeys];
		sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
		}];
	}
	
	return sortedKeys;
}

#pragma mark - locate delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[manager stopUpdatingLocation];
	[self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// 定位失败
	if (self.selectCityHeaderView) {
		[self.selectCityHeaderView setCurrentCityName:@"Locate failed"];
	}
//	//定位失败时，使用上一次定位的城市来代替；若上一次也未定位成功，使用默认城市
//	_locateCity = [City getCityFromUserDefault:LOCATE_CITY];
//	if(!_locateCity) {
//		_locateCity = [City getCityFromUserDefault:DEFAULT_CITY];
////		NSLog(@"SelectCityViewController didFailWithError _locateCity.city_name_en = %@, _locateCity.id = %d", _locateCity.city_name_en, _locateCity.city_id);
//		if (self.selectCityHeaderView) {
//			[self.selectCityHeaderView setCurrentCityName:_locateCity.city_name_en];
//		}
//	}
}

/*
 * @param coordinate 经纬度
 *
 */
- (void)getCityInfoByLocation:(CLLocation *)location {
	// 反向地理编码
	[_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		NSString *result;
		if (!error && [placemarks count] > 0) {
			NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
//			NSLog(@"SelectCityViewController getCityInfoByLocation dict = %@", dict);
			NSString *city = dict[@"City"];
			_locateCity.city_name_en = city;
			result = city;
		} else {
			result = @"Locate failed";
			// 若无法反向地理编码，使用上一次定位城市；若上一次定位城市为nil，则使用默认城市
//			City *locateCity = [City getCityFromUserDefault:LOCATE_CITY];
//			if(locateCity) {
//				_locateCity = locateCity;
//			} else {
//				_locateCity = [City getCityFromUserDefault:DEFAULT_CITY];
//			}
		}
//		NSLog(@"SelectCityViewController getCityInfoByLocation _locateCity.city_name_en = %@, _locateCity.id = %d", _locateCity.city_name_en, _locateCity.city_id);
		if (self.selectCityHeaderView) {
			[self.selectCityHeaderView setCurrentCityName:result];
		}
	}];
}

#pragma mark - Network

- (void)requestHotCityList {
	[HttpManager requestHotCityListWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			NSArray *items = resultDict[@"result"][@"items"];
			NSMutableArray *tempArray = [City objectArrayWithKeyValuesArray:items];
			City *nationWide = [[City alloc] init];
			nationWide.city_id = 0;
			nationWide.city_name = @"全国";
			nationWide.city_name_en = @"China";
			[tempArray insertObject:nationWide atIndex:0];
			hotCities = tempArray;
			[self requestAskCityList];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[_loadingStatusView showWithStatus:NetErr];
	}];
}

- (void)requestAskCityList {
	if (self.selectCityFromType == SelectCityFromTypeAskList) {
		[self requestAskCity];
	} else {
		[self requestCity];
	}
}

- (void)requestAskCity {
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.askCategoryID] forKeys:@[@"akc_id"]];
	[HttpManager requestAskCityListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			NSArray *items = resultDict[@"result"][@"items"];
			NSArray *cities = [City objectArrayWithKeyValuesArray:items];
			NSMutableArray *temp = [NSMutableArray arrayWithArray:hotCities];
			[temp addObjectsFromArray:cities];
			allCityArray = [NSArray arrayWithArray:temp];
			
			if (cities.count > 0) {
				allCities = [NSMutableDictionary dictionary];
				for(City *city in cities) {
					if (city.city_id == 0) {
						continue;
					}
					NSString *name = city.city_name_en;
					NSString *key = [name substringWithRange:NSMakeRange(0, 1)];
					NSMutableArray *values = [allCities objectForKey:key];
					if(values) {
						[values addObject:city];
					} else {
						values = [NSMutableArray array];
						[values addObject:city];
					}
					[allCities setObject:values forKey:key];
				}
				
				self.tableView.hidden = NO;
				self.searchBar.hidden = NO;
				
				_filteredData = [[NSMutableArray alloc] init];
				
				// 初始化 TableView HeaderView
				[self initHeaderView];
				[_loadingStatusView showWithStatus:Done];
				[self.tableView reloadData];
			} else {
				self.tableView.hidden = YES;
				self.searchBar.hidden = YES;
				[_loadingStatusView showWithStatus:Empty];
			}
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[_loadingStatusView showWithStatus:NetErr];
	}];
}

- (void)requestCity {
	[HttpManager queryCities:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if(rtnCode == 0) {
			NSArray *items = resultDict[@"result"][@"items"];
			NSArray *cities = [City objectArrayWithKeyValuesArray:items];
			NSMutableArray *temp = [NSMutableArray arrayWithArray:hotCities];
			[temp addObjectsFromArray:cities];
			allCityArray = [NSArray arrayWithArray:temp];
			
			if (cities.count > 0) {
				allCities = [NSMutableDictionary dictionary];
				for(City *city in cities) {
					if (city.city_id == 0) {
						continue;
					}
					NSString *name = city.city_name_en;
					NSString *key = [name substringWithRange:NSMakeRange(0, 1)];
					NSMutableArray *values = [allCities objectForKey:key];
					if(values) {
						[values addObject:city];
					} else {
						values = [NSMutableArray array];
						[values addObject:city];
					}
					[allCities setObject:values forKey:key];
				}
				
				self.tableView.hidden = NO;
				self.searchBar.hidden = NO;
				
				_filteredData = [[NSMutableArray alloc] init];
				
				// 初始化 TableView HeaderView
				[self initHeaderView];
				[_loadingStatusView showWithStatus:Done];
				[self.tableView reloadData];
			} else {
				self.tableView.hidden = YES;
				self.searchBar.hidden = YES;
				[_loadingStatusView showWithStatus:Empty];
			}
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		[_loadingStatusView showWithStatus:NetErr];
	}];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!isSearching) {
		NSArray *keys = [self sortKeys];
		return [allCities[keys[section]] count];
	} else {
		return _filteredData.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CityCell *cell = [tableView dequeueReusableCellWithIdentifier:CityCellIdentifier];
	City *city;
	if (!isSearching) {
		NSArray *keys = [self sortKeys];
		NSArray *cities = [allCities objectForKey:keys[indexPath.section]];
		city = cities[indexPath.row];
	} else {
		city = _filteredData[indexPath.row];
	}
	
	if (city) {
		cell.cityLabel.text = city.city_name_en;
		return cell;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.selectedCity) {
		City *city;
		if (!isSearching) {
			NSString *key = [[self sortKeys] objectAtIndex:indexPath.section];
			city = [[allCities objectForKey:key] objectAtIndex:indexPath.row];
		} else {
			city = _filteredData[indexPath.row];
		}
		
		if (city) {
			self.selectedCity(city.city_name_en, city.city_id);
			[self cancel];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *keys = [self sortKeys];
	return keys[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!isSearching) {
		return allCities.count;
	} else {
		return 1;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
	headerSection.backgroundColor = ColorWithRGB(250, 250, 250);
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
	label.text = [[self sortKeys] objectAtIndex:section];
	label.textColor = ColorWithRGB(120, 120, 120);
	label.font = FontNeveLightWithSize(12.0);
	[label sizeToFit];
	[headerSection addSubview:label];
	UIView *lineBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.view.frame), 0.5)];
	lineBottomSeperator.backgroundColor = ColorWithRGB(200, 199, 204);
	[headerSection addSubview:lineBottomSeperator];
	
	UIView *lineTopSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0.5)];
	lineTopSeperator.backgroundColor = ColorWithRGB(200, 199, 204);
	[headerSection addSubview:lineTopSeperator];
	
	return headerSection;
}

/**
 *  为列表右边的字母表添加数据集
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self sortKeys]];
	return array;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.view bringSubviewToFront:self.tableView];
	isSearching = NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	// Tells the table data source to reload when text changes
	[self filterContentForSearchText:searchString];
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText {
	// Update the filtered array based on the search text and scope.
	// Remove all objects from the filtered search array
	[_filteredData removeAllObjects];
	// Filter the array using NSPredicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_name_en contains[cd] %@", searchText];
	[_filteredData removeAllObjects];
	[_filteredData addObjectsFromArray:[allCityArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - SelectCityHeaderViewDelegate

- (void)searchButtonClicked {
	[self.view bringSubviewToFront:self.searchBar];
	[self.searchBar becomeFirstResponder];
	isSearching = YES;
}

- (void)selectedLocateCity {
	if ([self isCityAvailable:_locateCity.city_name_en]) {
		self.selectedCity(_locateCity.city_name_en, _locateCity.city_id);
		[self cancel];
	}
}

- (void)hotCitySelectedAtIndex:(NSInteger)index {
	if (self.selectedCity) {
		City *city = hotCities[index];
		self.selectedCity(city.city_name_en, city.city_id);
		
		[self cancel];
	}
}

#pragma mark - click events

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
