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
#define NavigationBarHeight 64.0
#define TableViewY 42.0
@interface WTLocationViewController ()
<
    UITableViewDataSource,UITableViewDelegate,
    UITextFieldDelegate,MKMapViewDelegate,
    BMKMapViewDelegate,BMKPoiSearchDelegate
>
@property (weak, nonatomic  ) IBOutlet UITextField              *addressTextField;
//@property (weak, nonatomic  ) IBOutlet MKMapView            *mapView;
//@property (nonatomic, strong) MKPointAnnotation                *pointAnno;
@property (strong, nonatomic  )  BMKMapView                     *mapView;
@property (weak, nonatomic  ) IBOutlet UITableView            *tableView;
@property (nonatomic, strong) BMKPoiSearch                      *poiSearch;
@property (nonatomic, strong) BMKCitySearchOption           *searchOption;
@property (nonatomic, strong) BMKPoiInfo                            *poiInfo;
@property (nonatomic, strong) BMKPointAnnotation             *pointAnno;
@property (nonatomic, strong) NSMutableArray                    *poiInfoArry;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (nonatomic, assign) BOOL canSearch;
@property (nonatomic, copy) NSString *searchKey;
@end

@implementation WTLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.tableView.tableFooterView = [[UIView alloc] init];
    self.poiInfoArry = [NSMutableArray array];

	self.canSearch = YES;
    self.poiSearch = [[BMKPoiSearch alloc] init];
	self.poiSearch.delegate = self;
    self.searchOption = [[BMKCitySearchOption alloc] init];

    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(20, 50, screenWidth - 40, screenHeight - 64 - 50 - 60)];
    [self.view insertSubview:self.mapView belowSubview:self.tableView];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.addressTextField.text = self.address;
	self.addressTextField.delegate = self;
    [self.addressTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];

    self.pointAnno = [[BMKPointAnnotation alloc] init];
    if([self.weddingMapPoint isNotEmptyCtg]){
        NSArray *array = [self.weddingMapPoint componentsSeparatedByString:@","];
        self.pointAnno.coordinate = CLLocationCoordinate2DMake([array[0] floatValue], [array[1] floatValue]);
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(self.pointAnno.coordinate, 500, 500);
        [self.mapView setRegion:region animated:YES];
    }
    [self.mapView addAnnotation:self.pointAnno];
}

- (IBAction)choosedLocation:(UIButton *)sender
{
    if(_poiInfo != nil){
        self.locationBlock([NSString stringWithFormat:@"%@%@",_poiInfo.city,self.addressTextField.text],[NSString stringWithFormat:@"%f,%f",_poiInfo.pt.latitude,_poiInfo.pt.longitude]);
    }else{
        self.locationBlock(self.addressTextField.text,self.weddingMapPoint);
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchLocation
{
    self.poiInfoArry = [NSMutableArray array];
    [self.tableView reloadData];
    self.tableViewHeight.constant = 0;

	self.searchOption.city = [UserInfoManager instance].city_name.length ==0 ? @"杭州":[UserInfoManager instance].city_name ;
    self.searchOption.keyword = self.addressTextField.text;
    [self.poiSearch poiSearchInCity:self.searchOption];
    [self showLoadingViewTitle:@"开始检索"] ;
}

#pragma mark - TextField
- (void)textFieldChanged:(UITextField *)textField
{
    if(textField.text.length > 0 && self.canSearch){
        _searchKey = textField.text;
        [self searchLocation];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(range.length == 0){
        if(currentString.length>0){
            self.canSearch = YES;
        }
    }
    else{
        self.canSearch = NO;
        self.tableViewHeight.constant = 0;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length >0){
        [self.addressTextField resignFirstResponder];
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
    WTAddressCell *cell  = [WTAddressCell addressCellWithTableView:tableView];
    BMKPoiInfo *info = self.poiInfoArry[indexPath.row];
    cell.addressLabel.text = info.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableViewHeight.constant = 0;
    [self.view endEditing:YES];

    if(self.poiInfoArry.count > indexPath.row){
        self.poiInfo = self.poiInfoArry[indexPath.row];
    }

	self.pointAnno.coordinate = self.poiInfo.pt;
	self.pointAnno.title = self.poiInfo.name;
	self.addressTextField.text = self.poiInfo.name;
    BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(self.poiInfo.pt, 500, 500);
    [self.mapView setRegion:region animated:YES];
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 500, 500);
    [mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if(error.code != 0){
        [WTProgressHUD ShowTextHUD:@"定位出错，请检查网络" showInView:self.view];
    }
}
*/
#pragma mark - POISearch
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    [self hideLoadingView];
    if(errorCode == BMK_SEARCH_NO_ERROR){
        if(poiResult.poiInfoList.count > 0){
            [self.poiInfoArry addObjectsFromArray:poiResult.poiInfoList];
            self.tableViewHeight.constant = screenHeight - TableViewY -NavigationBarHeight;
            [self.tableView reloadData];
        }
    }else{
        [WTProgressHUD ShowTextHUD:@"检索失败" showInView:self.view];
    }
}

- (void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{

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
