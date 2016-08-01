//
//  WDLocationViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/5.
//  Copyright © 2015年 lovewith.me. All rights reserved.
//
#import "WTLocationViewController.h"
#import "WTAddressCell.h"
#import "WTProgressHUD.h"
#define kMapViewX     20.0
#define kMapViewY     50.0
#define TableViewY    42.0
@interface WTLocationViewController ()
<
    UITableViewDataSource,UITableViewDelegate,
    UITextFieldDelegate,MKMapViewDelegate,
    BMKMapViewDelegate,BMKPoiSearchDelegate,
    BMKGeoCodeSearchDelegate
>
//@property (weak, nonatomic  ) IBOutlet MKMapView            *mapView;
//@property (nonatomic, strong) MKPointAnnotation             *pointAnno;
@property (strong, nonatomic) BMKMapView             *mapView;
@property (nonatomic, strong) BMKPointAnnotation     *pointAnno;
@property (strong, nonatomic) IBOutlet UITextField   *addressTextField;
@property (weak, nonatomic) IBOutlet UIView          *pinBgView;
@property (strong, nonatomic) IBOutlet UITableView   *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint  *tableViewHeight;

@property (nonatomic, strong) BMKPoiSearch           *poiSearch;
@property (nonatomic, strong) BMKCitySearchOption    *searchOption;
@property (nonatomic, strong) BMKPoiInfo             *poiInfo;

@property (nonatomic, strong) BMKGeoCodeSearch       *geoSearch;
@property (nonatomic, strong) BMKGeoCodeSearchOption *geoSearchOption;
@property (nonatomic, strong) BMKReverseGeoCodeOption *reGeoSearchOption;
@property (nonatomic, strong) BMKGeoCodeResult       *geoResult;

@property (nonatomic, strong) NSMutableArray         *poiInfoArry;
@property (nonatomic, copy) NSString *searchKey;
@property (nonatomic, assign) BOOL canReverseGeoSearch ;
@end

@implementation WTLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.tableView.tableFooterView = [[UIView alloc] init];
    self.poiInfoArry = [NSMutableArray array];

	self.canReverseGeoSearch = YES;

    self.poiSearch = [[BMKPoiSearch alloc] init];
	self.poiSearch.delegate = self;
    self.searchOption = [[BMKCitySearchOption alloc] init];

	self.geoSearch = [[BMKGeoCodeSearch alloc] init];
	self.geoSearch.delegate = self;
	self.geoSearchOption = [[BMKGeoCodeSearchOption alloc] init];
	self.reGeoSearchOption = [[BMKReverseGeoCodeOption alloc] init];

	self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(kMapViewX, kMapViewY, screenWidth - 2 * kMapViewX, screenHeight - kNavBarHeight - 50 - 60)];
	[self.view insertSubview:self.mapView belowSubview:self.pinBgView];
	self.mapView.showsUserLocation = YES;
    self.addressTextField.text = self.address;

    self.pointAnno = [[BMKPointAnnotation alloc] init];
    if([self.weddingMapPoint isNotEmptyCtg]){
        NSArray *array = [self.weddingMapPoint componentsSeparatedByString:@","];
        self.pointAnno.coordinate = CLLocationCoordinate2DMake([array[0] floatValue], [array[1] floatValue]);
        BMKCoordinateRegion region = BMKCoordinateRegionMake(self.pointAnno.coordinate, BMKCoordinateSpanMake(0.01, 0.01));
        [self.mapView setRegion:region animated:YES];
    }
    else
    {
        _mapView.region = BMKCoordinateRegionMake(_mapView.region.center, BMKCoordinateSpanMake(0.01, 0.01));
    }
//    [self.mapView addAnnotation:self.pointAnno];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.mapView.delegate = nil;
}

- (IBAction)choosedLocation:(UIButton *)sender
{
    if(_poiInfo ){
        self.locationBlock([NSString stringWithFormat:@"%@%@",_poiInfo.city,self.addressTextField.text],
						   [NSString stringWithFormat:@"%f,%f",_poiInfo.pt.latitude,_poiInfo.pt.longitude]);
    }
	else if (_geoResult){
		self.locationBlock([NSString stringWithFormat:@"%@",self.addressTextField.text],
						   [NSString stringWithFormat:@"%f,%f",_geoResult.location.latitude,_geoResult.location.longitude]);
	}
	else{
        self.locationBlock(self.addressTextField.text,self.weddingMapPoint);
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchLocation
{
    self.poiInfoArry = [NSMutableArray array];
	self.tableViewHeight.constant = 0;
	[self.tableView reloadData];

	NSString *searchCity = [UserInfoManager instance].city_name.length == 0 ? @"杭州":[UserInfoManager instance].city_name;
	self.searchOption.city = searchCity;
    self.searchOption.keyword = self.addressTextField.text;
    [self.poiSearch poiSearchInCity:self.searchOption];

	self.geoSearchOption.city = searchCity;
	self.geoSearchOption.address = self.addressTextField.text;
	[self.geoSearch geoCode:_geoSearchOption];

    [self showLoadingViewTitle:@"开始检索"] ;
}

- (void)startLocation
{
    __block BOOL isRevSearch = self.canReverseGeoSearch;
	[BMKMapView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.canReverseGeoSearch = NO;
		BMKCoordinateRegion region = BMKCoordinateRegionMake(self.pointAnno.coordinate, _mapView.region.span);
		[self.mapView setRegion:region animated:YES];
	} completion:^(BOOL finished) {
		self.canReverseGeoSearch = isRevSearch;
	}];
}

#pragma mark - TextField
- (IBAction)textFieldChanges:(UITextField *)textField
{
	_searchKey = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length >0){
        [self.addressTextField resignFirstResponder];
		[self searchLocation];
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.tableViewHeight.constant = 0;
    [self.poiInfoArry removeAllObjects];
    [self.tableView reloadData];
    return YES;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiInfoArry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < self.poiInfoArry.count)
	{
		WTAddressCell *cell  = [WTAddressCell addressCellWithTableView:tableView];
		if([self.poiInfoArry[indexPath.row] isKindOfClass:[BMKPoiInfo class]])
		{
			BMKPoiInfo *info = self.poiInfoArry[indexPath.row];
			cell.addressName = info.name;
		}
		else if ([self.poiInfoArry[indexPath.row] isKindOfClass:[BMKGeoCodeResult class]])
		{
			BMKGeoCodeResult *geoResult = self.poiInfoArry[indexPath.row];
			cell.addressName = geoResult.address;
		}
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < self.poiInfoArry.count)
	{
		self.canReverseGeoSearch = NO;
		self.tableViewHeight.constant = 0;
		[self.view endEditing:YES];
		if([self.poiInfoArry[indexPath.row] isKindOfClass:[BMKPoiInfo class]])
		{
			self.poiInfo = self.poiInfoArry[indexPath.row];
			self.pointAnno.coordinate = self.poiInfo.pt;
			self.pointAnno.title = self.poiInfo.name;
			[self startLocation];
            self.addressTextField.text = self.poiInfo.name;
		}
		else if ([self.poiInfoArry[indexPath.row] isKindOfClass:[BMKGeoCodeResult class]])
		{
			self.geoResult = self.poiInfoArry[indexPath.row];
			self.pointAnno.coordinate = self.geoResult.location;
			self.pointAnno.title = self.geoResult.address;
			[self startLocation];
            self.addressTextField.text = self.geoResult.address;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark - MapView
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    return nil;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocation *beforeLocation = [[CLLocation alloc] initWithLatitude:_pointAnno.coordinate.latitude longitude:_pointAnno.coordinate.longitude];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    double distance = [beforeLocation distanceFromLocation:currentLocation];
    if(self.canReverseGeoSearch && ABS(distance) > 10){
        self.poiInfoArry = [NSMutableArray array];
        self.tableViewHeight.constant = 0;
        [self.tableView reloadData];
        
        self.pointAnno.coordinate = mapView.centerCoordinate;
        self.pointAnno.title = nil;
        
        self.reGeoSearchOption.reverseGeoPoint = mapView.centerCoordinate;
        [self.geoSearch reverseGeoCode:_reGeoSearchOption];
        [self showLoadingViewTitle:@"开始检索"] ;
    }
    else
    {
        self.canReverseGeoSearch = YES;
        [self startLocation];
    }
}
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isEqual:self.pointAnno] && self.pointAnno){
        MKPinAnnotationView *anno = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"anno"];
        if(!anno){
            anno = [[MKPinAnnotationView alloc] init];
        }
        anno.pinColor = MKPinAnnotationColorGreen;
        anno.canShowCallout = YES;
        anno.animatesDrop = YES;
//        anno.title = self.addressTextField.text;
    }
    return nil;
}
*/

#pragma mark - BMKPoiSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    [self hideLoadingView];
    if(errorCode == BMK_SEARCH_NO_ERROR)
	{
        if(poiResult.poiInfoList.count > 0)
		{
            [self.poiInfoArry addObjectsFromArray:[poiResult.poiInfoList mutableCopy]];
        }
    }

	if(_poiInfoArry.count > 0)
	{
		self.tableViewHeight.constant = screenHeight - TableViewY -kNavBarHeight;
		[self.tableView reloadData];
		self.tableView.alpha = 0;
		[UIView animateWithDuration:0.2 animations:^{
			self.tableView.alpha = 1;
		}completion:nil];
	}
	else
	{
		[WTProgressHUD ShowTextHUD:@"无结果" showInView:self.view];
	}
}

- (void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
	
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	[self hideLoadingView];
	if(error == BMK_SEARCH_NO_ERROR)
	{
		if(result)
		{
			[self.poiInfoArry addObject:result];
		}
	}
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	[self hideLoadingView];
	if(error == BMK_SEARCH_NO_ERROR)
	{
		if(result.poiList.count > 0)
		{
			[self.poiInfoArry addObjectsFromArray:[result.poiList mutableCopy]];
		}
	}

	if(_poiInfoArry.count > 0)
	{
		self.tableViewHeight.constant = screenHeight - TableViewY -kNavBarHeight;
		[self.tableView reloadData];
		self.tableView.alpha = 0;
		[UIView animateWithDuration:0.2 animations:^{
			self.tableView.alpha = 1;
		}completion:nil];
	}
	else
	{
		[WTProgressHUD ShowTextHUD:@"无结果" showInView:self.view];
	}
}

#pragma mark - EndEdit
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
