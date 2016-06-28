//
//  WDLocationViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/5.
//  Copyright © 2015年 lovewith.me. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "BaseViewController.h"
typedef void(^LocationBlock)(NSString *weddingAddress,NSString *weddingMapPoint);

@interface WTLocationViewController : BaseViewController
@property (nonatomic, copy) LocationBlock locationBlock;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *weddingMapPoint;
-(void)setLocationBlock:(LocationBlock)locationBlock;
@end
