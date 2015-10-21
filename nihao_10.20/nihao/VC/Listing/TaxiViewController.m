//
//  TaxiViewController.m
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TaxiViewController.h"
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>
#import "MerchantPoint.h"
#import <math.h>

@interface TaxiViewController ()//  <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation TaxiViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Taxi printout";
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.addressLabel.text = self.merchantAddress;
	
	[self setUpAnnotation];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setUpAnnotation {
	double aMapLat = 0;
	double aMapLon = 0;
	[self bdLat:self.latitude Lon:self.longitude toAMapLat:&aMapLat aMaplng:&aMapLon];
//	NSLog(@"aMapLat = %lf, aMapLon = %lf", aMapLat, aMapLon);
	
	//创建 CLLocation 设置经纬度
	CLLocation *location = [[CLLocation alloc]initWithLatitude:aMapLat longitude:aMapLon];
	CLLocationCoordinate2D coord = [location coordinate];
	MerchantPoint *merchantPoint = [[MerchantPoint alloc] initWithCoordinate:coord andTitle:self.merchantTitle];
	
	//添加标注
	[self.mapView addAnnotation:merchantPoint];
	//放大到标注的位置
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
	[self.mapView setRegion:region animated:YES];
}

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

- (void)bdLat:(double)bd_lat Lon:(double)bd_lon toAMapLat:(double *)gg_lat aMaplng:(double *)gg_lon {
	double x = bd_lon - 0.0065, y = bd_lat - 0.006;
	double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
	double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
	*gg_lon = z * cos(theta);
	*gg_lat = z * sin(theta);
}

#pragma mark - MKMapViewDelegate

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//	static NSString *MerchantMarkID = @"MerchantPointMarkID";
//	if ([annotation isKindOfClass:[MerchantPoint class]]) {
//		MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MerchantMarkID];
//		if (annotationView == nil) {
//			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MerchantMarkID];
//			annotationView.image = [UIImage imageNamed:@"blood_orange.png"];
//		}
//		else
//			annotationView.annotation = annotation;
//		return annotationView;
//	}
//	return nil;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
