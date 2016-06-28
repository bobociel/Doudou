//
//  YHKaoQinMapViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHKaoQinMapViewController.h"
#import "LocationMgr.h"

@interface YHKaoQinMapViewController ()

@end

@implementation YHKaoQinMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.mapView.showsUserLocation = YES;
//	self.mapView.centerCoordinate = [LocationMgr instance].location.coordinate
	[self.mapView setRegion:MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005))];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
