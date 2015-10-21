//
//  SwitchCityViewController.m
//  nihao
//
//  Created by 刘志 on 15/5/29.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "SwitchCityViewController.h"
#import "BaseFunction.h"
#import "BATableView.h"
#import "CityCell.h"
#import "HttpManager.h"
#import <MJExtension/MJExtension.h>
#import "City.h"
#import "ListingLoadingStatusView.h"
#import <CoreLocation/CoreLocation.h>
#import "AppConfigure.h"

@interface SwitchCityViewController () <BATableViewDelegate,CLLocationManagerDelegate,UISearchDisplayDelegate> {
    BATableView *_table;
    NSMutableDictionary *_data;
    ListingLoadingStatusView *_loadingStatusView;
    UIButton *_currentCityButton;
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    
    //定位城市
    City *_locateCity;
    
    //筛选本地城市
    NSMutableArray *_filterArray;
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
}

@end

@implementation SwitchCityViewController

static NSString *const identifier = @"citycellidentifier";
static NSString *const LOCATE_FAIL = @"Locate Fail";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    self.title = @"Current City";
    [self initSearchView];
    [self initTable];
    [self loadData];
    [self requestLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  加载城市数据
 */
- (void) loadData {
    [_loadingStatusView showWithStatus:Loading];
    [HttpManager queryCities:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_loadingStatusView showWithStatus:Done];
            NSDictionary *items = responseObject[@"result"][@"items"];
            NSArray *cities = [City objectArrayWithKeyValuesArray:items];
            _data = [NSMutableDictionary dictionary];
            for(City *city in cities) {
                NSString *name = city.city_name_en;
                NSString *key = [name substringWithRange:NSMakeRange(0,1)];
                NSMutableArray *values = [_data objectForKey:key];
                if(values) {
                    [values addObject:city];
                } else {
                    values = [NSMutableArray array];
                    [values addObject:city];
                }
                [_data setObject:values forKey:key];
            }
            [_table reloadData];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingStatusView showWithStatus:NetErr];
    }];
}

/**
 *  初始化城市列表
 */
- (void) initTable {
    _table = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    _table.tableView.tableHeaderView = [self createHeader];
    _table.tableView.tableFooterView = [[UIView alloc] init];
    [_table.tableView registerNib:[UINib nibWithNibName:@"CityCell" bundle:nil] forCellReuseIdentifier:identifier];
    _table.delegate = self;
    [self.view addSubview:_table];
    
    //初始化加载状态view
    _loadingStatusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak SwitchCityViewController *weakSelf = self;
    _loadingStatusView.backgroundColor = [UIColor clearColor];
    _loadingStatusView.refresh = ^() {
        [weakSelf loadData];
    };
    [self.view addSubview:_loadingStatusView];
}

/**
 *  初始化uitableview的header
 *
 *  @return
 */
- (UIView *) createHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headerView.backgroundColor = ColorWithRGB(250, 250, 250);
    //搜索框
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(14, 6, SCREEN_WIDTH - 28, 33)];
    searchView.backgroundColor = [UIColor whiteColor];
    [BaseFunction setBorderWidth:1.0 color:ColorWithRGB(230, 230, 230) view:searchView];
    [headerView addSubview:searchView];
    //搜索图标
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:ImageNamed(@"common_icon_search_gray")];
    searchImage.frame = CGRectMake(20, 8, 16, 16);
    [searchView addSubview:searchImage];
    //搜索编辑框
    UIButton *searchField = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchImage.frame) + 8, 0, CGRectGetWidth(searchView.frame) - CGRectGetMaxX(searchImage.frame) - 8, CGRectGetHeight(searchView.frame))];
    searchField.titleLabel.font = FontNeveLightWithSize(14.0);
    [searchField setTitle:@"search" forState:UIControlStateNormal];
    [searchField setTitleColor:HintTextColor forState:UIControlStateNormal];
    searchField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [searchField addTarget:self action:@selector(popSearchDisplayController) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:searchField];
    
    //定位view
    UIView *locateView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame) + 6, SCREEN_WIDTH, CGRectGetHeight(headerView.frame) - CGRectGetMaxY(searchView.frame) - 6)];
    locateView.backgroundColor = [UIColor whiteColor];
    //当前定位城市
    UILabel *currentCityLabel = [[UILabel alloc] init];
    currentCityLabel.font = FontNeveLightWithSize(14.0);
    currentCityLabel.textColor = ColorWithRGB(87, 87, 87);
    currentCityLabel.text = @"Current Positioning City";
    [currentCityLabel sizeToFit];
    currentCityLabel.frame = CGRectMake(24, (CGRectGetHeight(locateView.frame) - CGRectGetHeight(currentCityLabel.frame)) / 2, CGRectGetWidth(currentCityLabel.frame), CGRectGetHeight(currentCityLabel.frame));
    [locateView addSubview:currentCityLabel];
    //当前定位城市按钮
    _currentCityButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80 - 16, (CGRectGetHeight(locateView.frame) - 30) / 2, 80, 30)];
    _currentCityButton.backgroundColor = BUTTON_ENABLED_COLOR;
    //[_currentCityButton setTitle:@"Hangzhou" forState:UIControlStateNormal];
    //[_currentCityButton setTitle:@"Hangzhou" forState:UIControlStateHighlighted];

    _currentCityButton.titleLabel.font = FontNeveLightWithSize(14.0);
    [_currentCityButton setTitle:@"Locating..." forState:UIControlStateNormal];
    [_currentCityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_currentCityButton addTarget:self action:@selector(locateCityClicked) forControlEvents:UIControlEventTouchUpInside];
    [locateView addSubview:_currentCityButton];
    [headerView addSubview:locateView];
    return headerView;
}

/**
 *  显示搜索城市的SearchDisplayController
 */
- (void) popSearchDisplayController {
    [self.view bringSubviewToFront:_searchBar];
    [_searchBar becomeFirstResponder];
}

- (void) initSearchView {
    _filterArray = [NSMutableArray array];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsTableView.delegate = self;
    _searchDisplayController.searchResultsTableView.dataSource = self;
    _searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    [_searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CityCell" bundle:nil] forCellReuseIdentifier:identifier];
    [self.view addSubview:_searchBar];
}

/**
 *  定位城市被选中，需要判断当前定位的城市是否已经开通
 */
- (void) locateCityClicked {
    if([LOCATE_FAIL isEqualToString:_currentCityButton.titleLabel.text]) {
        [_locationManager startUpdatingLocation];
    }
    if(IsStringEmpty(_locateCity.city_name_en)) {
        return;
    }
    if([self isCityAvailable:_locateCity.city_name_en]) {
        self.switchCity(_locateCity);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"current city isn't in service" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

/**
 *  请求定位
 */
- (void) requestLocation {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
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

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [manager stopUpdatingLocation];
    [self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    [_currentCityButton setTitle:LOCATE_FAIL forState:UIControlStateNormal];
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
            NSString *city = dict[@"City"];
            [_currentCityButton setTitle:city forState:UIControlStateNormal];
            [_currentCityButton setTitle:city forState:UIControlStateSelected];
            _locateCity.city_name_en = city;
        } else {
            //若无法反向地理编码，使用上一次定位城市；若上一次定位城市为nil，则使用默认城市
            [_currentCityButton setTitle:@"Locate Fail" forState:UIControlStateNormal];
        }}];
}

/**
 *  根据城市的英文名来判断当前城市是否已经开通服务；
 *
 *  @param cityNameEn 当前定位的城市英文名
 *
 *  @return
 */
- (BOOL) isCityAvailable : (NSString *) cityNameEn {
    NSArray *cities = [City getCityListFromUserDefault];
    BOOL available = NO;
    for(City *city in cities) {
        NSString *cityName = city.city_name_en;
        //去除字符串中间的空格并转为小写字母后与默认城市比较
        cityName = [[cityName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
//		if (cityNameEn.length == cityName.length) {
//			NSRange searchRange = [cityName rangeOfString:[cityNameEn lowercaseString]];
//			if(searchRange.location == 0) {
//				available = YES;
//				_locateCity = city;
//				break;
//			}
//		}
		
		if ([cityNameEn compare:cityName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			available = YES;
			_locateCity = city;
			break;
		}
    }
    return available;
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
    NSArray *keys = [_data allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

#pragma mark - uitableview datasource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *keys = [self sortedKeys];
        return [_data[keys[section]] count];
    } else {
        return _filterArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(tableView == _table.tableView) {
        NSArray *keys = [self sortedKeys];
        NSArray *cities = [_data objectForKey:keys[indexPath.section]];
        cell.cityLabel.text = ((City *)cities[indexPath.row]).city_name_en;
    } else {
        cell.cityLabel.text = ((City *)_filterArray[indexPath.row]).city_name_en;
    }
    return cell;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [(NSArray *)[self sortedKeys] objectAtIndex:indexPath.section];
    City *city;
    if(tableView == _table.tableView) {
        city = [[_data objectForKey:key] objectAtIndex:indexPath.row];
    } else {
        city = _filterArray[indexPath.row];
    }
    self.switchCity(city);
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *keys = [self sortedKeys];
        return keys[section];
    } else {
        return nil;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == _table.tableView) {
        return _data.count;
    } else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == _searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        headerSection.backgroundColor = ColorWithRGB(250, 250, 250);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
        label.text = [(NSArray *)[self sortedKeys] objectAtIndex:section];
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
}

/**
 *  为列表右边的字母表添加数据集
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self sortedKeys]];
    return array;
}

#pragma mark - UISearchDisplayDelegate
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.view bringSubviewToFront:_table];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSArray *citiesArray = [self filterFriendsByKeyword:searchString];
    if(_filterArray.count > 0) {
        [_filterArray removeAllObjects];
    }
    [_filterArray addObjectsFromArray:citiesArray];
    [_searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

/**
 *  根据关键字筛选城市
 *
 *  @return friends对象的数列
 */
- (NSArray *) filterFriendsByKeyword : (NSString *) keyword {
    NSMutableArray *citiesArray = [NSMutableArray array];
    for(NSString *key in [_data allKeys]) {
        NSArray *array = _data[key];
        [citiesArray addObjectsFromArray:array];
    }
    
    //模糊查询
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_name_en contains[c] %@",keyword];
    NSArray *tempArray = [citiesArray filteredArrayUsingPredicate:predicate];
    return tempArray;
}

@end
