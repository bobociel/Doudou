//
//  RegionViewController.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "RegionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MJExtension.h>
#import "AppConfigure.h"
#import "BATableView.h"
#import "ListingLoadingStatusView.h"
#import "HttpManager.h"
#import "Nationality.h"

@interface RegionViewController () <BATableViewDelegate, CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	CLGeocoder *_geocoder;
	BATableView *_baTable;
	NSMutableDictionary *_dic;
    NSArray *_data;
    ListingLoadingStatusView *_statusView;
}

@end

static NSString *RegionCellIdentifier = @"RegionCell";
static NSString *LocationCellIdentifier = @"LocationCell";

@implementation RegionViewController {
	NSString *locationText;
	BOOL isLocatingFinished;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Region";
	
	_baTable = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	_baTable.delegate = self;
	[_baTable.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:RegionCellIdentifier];
	[_baTable.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LocationCellIdentifier];
	_baTable.tableView.tableFooterView = [[UIView alloc] init];
	_baTable.tableView.rowHeight = 45;
	[self.view addSubview:_baTable];
	
	_dic = [NSMutableDictionary dictionary];
	
	if (self.regionType == RegionTypeCountry || self.regionType == RegionFilter) {
        _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        __weak RegionViewController *weakSelf = self;
        _statusView.refresh = ^{
            [weakSelf queryNations];
        };
        [self.view addSubview:_statusView];
        [self queryNations];
        
		locationText = @"Locating...";
		isLocatingFinished = NO;
		[self locating];
	} else if (self.regionType == RegionTypeProvince) {
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"province_and_city" ofType:@".txt"];
		NSData *tempData = [NSData dataWithContentsOfFile:filePath];
        NSError *err;
		self.dataSource = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:&err];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)finishingRegionSelected:(NSString *)region {
	[self.navigationController popViewControllerAnimated:YES];
	if (self.regionSelected) {
		self.regionSelected(region);
	}
}

- (void)locating {
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
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *)sortedKeys {
	NSArray *keys = [_dic allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
	}];
	return sortedArray;
}

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[manager stopUpdatingLocation];
	// 保存经纬度
	[AppConfigure setObject:[NSString stringWithFormat:@"%lf", location.coordinate.latitude] ForKey:REGISTER_USER_LATITUDE];
	[AppConfigure setObject:[NSString stringWithFormat:@"%lf", location.coordinate.longitude] ForKey:REGISTER_USER_LONGITUDE];
    [self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't get your location" message:@"Please open app location service in settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
	}
}

- (void)getCityInfoByLocation:(CLLocation *)location {
	// 反向地理编码
	[_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (!error && [placemarks count] > 0) {
			NSDictionary *result = [[placemarks objectAtIndex:0] addressDictionary];
			NSString *cityName = result[@"City"];
			NSString *provinceName = result[@"State"];
			NSString *countryName = result[@"Country"];
            if(!IsStringEmpty(provinceName) && !IsStringEmpty(cityName) && [provinceName isEqualToString:cityName]) {
                cityName = @"";
            }
			locationText = [NSString stringWithFormat:@"%@ %@ %@", countryName, provinceName, cityName];
			isLocatingFinished = YES;
			[_baTable.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		} else {
			NSLog(@"ERROR: %@", error);
		}
	}];
}

#pragma mark - UITableViewDataSource

/**
 *  列表右侧字母表
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
	NSMutableArray *sectionIndexTitles = [NSMutableArray array];
	if (self.regionType == RegionTypeCountry || self.regionType == RegionFilter) {
		[sectionIndexTitles addObject:@"#"];
        if(self.regionType == RegionFilter) {
            [sectionIndexTitles addObject:@"#"];   
        }
		NSArray *letters = [self sortedKeys];
//		NSLog(@"letters.count = %ld", letters.count);
		[sectionIndexTitles addObjectsFromArray:letters];
	}
	
	return sectionIndexTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.regionType == RegionTypeCountry) {
		return [_dic allKeys].count + 1;
    } else if(self.regionType == RegionFilter) {
		return [_dic allKeys].count + 2;
    } else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.regionType == RegionTypeCountry) {
		if (section == 0) {
			return 1;
		} else {
			NSString *key = [self sortedKeys][section - 1];
			NSArray *data = _dic[key];
			return data.count;
		}
    } else if(self.regionType == RegionFilter) {
        if (section == 0 || section == 1) {
            return 1;
        } else {
            NSString *key = [self sortedKeys][section - 2];
            NSArray *data = _dic[key];
            return data.count;
        }
    } else {
		return self.dataSource.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (self.regionType == RegionTypeCountry) {
		if (indexPath.section == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.text = locationText;
			cell.imageView.image = [UIImage imageNamed:@"location_icon"];
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier forIndexPath:indexPath];
			NSString *key = [self sortedKeys][indexPath.section - 1];
			Nationality *nation =  _dic[key][indexPath.row];
			cell.textLabel.text = nation.country_name_en;
			if ([nation.country_name_en isEqualToString:@"China"]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
    } else if(self.regionType == RegionFilter) {
        if (indexPath.section == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = locationText;
            cell.imageView.image = [UIImage imageNamed:@"location_icon"];
        } else if(indexPath.section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"All";
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier forIndexPath:indexPath];
            NSString *key = [self sortedKeys][indexPath.section - 2];
            Nationality *nation =  _dic[key][indexPath.row];
            cell.textLabel.text = nation.country_name_en;
            if ([nation.country_name_en isEqualToString:@"China"]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier forIndexPath:indexPath];
		
		if (self.regionType == RegionTypeProvince) {
			cell.textLabel.text = self.dataSource[indexPath.row][@"province_name"];
		} else {
			cell.textLabel.text = self.dataSource[indexPath.row];
		}
		
		if ((self.regionType == RegionTypeCountry && (indexPath.section == 1 && indexPath.row == 0)) || self.regionType == RegionTypeProvince) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.regionType == RegionTypeCountry) {
		if (section == 0) {
			return @"Searched location";
		} else {
			NSString *key = [_dic allKeys][section - 1];
			return key;
		}
    } else if(self.regionType == RegionFilter) {
        if (section == 0) {
            return @"Searched location";
        } else if(section == 1) {
            return @"";
        } else {
            NSString *key = [_dic allKeys][section - 1];
            return key;
        }
    } else {
		return @"All";
	}
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	__weak typeof(self) weakSelf = self;
	
	switch (self.regionType) {
		case RegionTypeCountry: {
			if (indexPath.section == 0 && indexPath.row == 0) {// Location
				if (isLocatingFinished) {
					NSArray *places = [locationText componentsSeparatedByString:@" "];
                    NSString *province = places[1];
                    NSString *city = places[2];
                    NSString *region;
                    if(IsStringEmpty(city)) {
                        //直辖市时，只需显示省份
                        region = province;
                    } else {
                        region = [NSString stringWithFormat:@"%@,%@", places[2], places[1]];
                    }
					[self finishingRegionSelected:region];
				}
			} else {
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				NSString *cellText = cell.textLabel.text;
				if ([cellText isEqualToString:@"China"]) {
					RegionViewController *regionViewController = [[RegionViewController alloc] init];
					regionViewController.regionType = RegionTypeProvince;
					regionViewController.provinceSelected = ^(NSString *province, NSString *city) {
						//					NSLog(@"country pop");
                        NSString *region;
                        if(IsStringEmpty(city)) {
                            region = [NSString stringWithFormat:@"%@",province];
                        } else {
                            region = [NSString stringWithFormat:@"%@,%@", city, province];
                        }
                        [weakSelf finishingRegionSelected:region];
					};
					[self.navigationController pushViewController:regionViewController animated:YES];
				} else {// Other Counrty or Region
					NSString *key = [self sortedKeys][indexPath.section - 1];
					Nationality *nation =  _dic[key][indexPath.row];
					[self finishingRegionSelected:nation.country_name_en];
				}
			}
		}
			break;
        case RegionFilter: {
            if (indexPath.section == 0 && indexPath.row == 0) {// Location
                if (isLocatingFinished) {
                    NSArray *places = [locationText componentsSeparatedByString:@" "];
                    NSString *region = [NSString stringWithFormat:@"%@,%@", places[2], places[1]];
                    [self finishingRegionSelected:region];
                }
            } else if(indexPath.section == 1 && indexPath.row == 0) {
                if(self.allRegionFilterSelected) {
                    self.allRegionFilterSelected();
                }
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                NSString *cellText = cell.textLabel.text;
                if ([cellText isEqualToString:@"China"]) {
                    RegionViewController *regionViewController = [[RegionViewController alloc] init];
                    regionViewController.regionType = RegionTypeProvince;
                    regionViewController.provinceSelected = ^(NSString *province, NSString *city) {
                        //					NSLog(@"country pop");
                        NSString *region;
                        if(IsStringEmpty(city)) {
                            region = [NSString stringWithFormat:@"%@",province];
                        } else {
                            region = [NSString stringWithFormat:@"%@,%@", city, province];
                        }
                        [weakSelf finishingRegionSelected:region];
                    };
                    [self.navigationController pushViewController:regionViewController animated:YES];
                } else {// Other Counrty or Region
                    NSString *key = [self sortedKeys][indexPath.section - 2];
                    Nationality *nation =  _dic[key][indexPath.row];
                    [self finishingRegionSelected:nation.country_name_en];
                }
            }
        }
            break;
		case RegionTypeProvince: {
            NSArray *array = self.dataSource[indexPath.row][@"cities"];
            if(array.count == 0) {
                //直辖市直接返回
                [self.navigationController popViewControllerAnimated:NO];
                self.provinceSelected(self.dataSource[indexPath.row][@"province_name"], @"");
                return;
            }
			RegionViewController *regionViewController = [[RegionViewController alloc] init];
			regionViewController.regionType = RegionTypeCity;
            regionViewController.dataSource = array;
			regionViewController.citySelected = ^(NSString *city) {
				[weakSelf.navigationController popViewControllerAnimated:NO];
				if (weakSelf.provinceSelected) {
					weakSelf.provinceSelected(weakSelf.dataSource[indexPath.row][@"province_name"], city);
				}
			};
			[self.navigationController pushViewController:regionViewController animated:YES];
		}
			break;
		case RegionTypeCity: {
			//			NSLog(@"city pop");
			[self.navigationController popViewControllerAnimated:NO];
			if (self.citySelected) {
				self.citySelected(self.dataSource[indexPath.row]);
			}
		}
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *headerTitle;
	
	if (self.regionType == RegionTypeCountry) {
		if (section == 0) {
			headerTitle = @"Searched location";
		} else {
			headerTitle = [self sortedKeys][section - 1];
		}
    } else if(self.regionType == RegionFilter) {
        if (section == 0) {
            headerTitle = @"Searched location";
        } else if(section == 1) {
            headerTitle = @"";
        } else {
            headerTitle = [self sortedKeys][section - 2];
        }
    } else {
		headerTitle = @"All";
	}
	
	//创建section的header view
	UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
	headerSection.backgroundColor = ColorWithRGB(250, 250, 250);
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
	label.text = headerTitle;
	label.textColor = [UIColor colorWithRed:120.0 / 255 green:120.0 / 255 blue:120.0 / 255 alpha:1.0];
	label.font = [UIFont systemFontOfSize:12];
	[label sizeToFit];
	[headerSection addSubview:label];
	UIView *lineBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.view.frame), 0.5)];
	lineBottomSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
	[headerSection addSubview:lineBottomSeperator];
	
	UIView *lineTopSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0.5)];
	lineTopSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
	[headerSection addSubview:lineTopSeperator];
	
	return headerSection;
}

#pragma mark - net work
- (void) queryNations {
    [_statusView showWithStatus:Loading];
    [HttpManager queryNations:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_statusView showWithStatus:Done];
            NSArray *array = responseObject[@"result"][@"items"];
            _data = [Nationality objectArrayWithKeyValuesArray:array];
            for(Nationality *nation in _data) {
                NSString *nationName = nation.country_name_en;
                //取出首字符当作key，将国籍放到对应的array里
                NSString *character = [nationName substringWithRange:NSMakeRange(0,1)];
                if([[_dic allKeys] containsObject:character]) {
                    NSMutableArray *array = _dic[character];
                    [array addObject:nation];
                } else {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:nation];
                    [_dic setObject:array forKey:character];
                }
            }
            
            [_baTable reloadData];
        } else {
            [self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_statusView showWithStatus:NetErr];
    }];
}

@end
