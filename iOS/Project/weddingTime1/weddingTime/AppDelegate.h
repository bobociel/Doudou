//
//  AppDelegate.h
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMapKit.h>
#import "LocationManager.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)BMKMapManager *bmkMapManager;
@property(strong,nonatomic)LocationManager *locayionManager;
@property(nonatomic)CLLocationManager *locationManager;
@end

