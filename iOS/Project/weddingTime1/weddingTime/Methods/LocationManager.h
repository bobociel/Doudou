//
//  LocationManager.h
//  lovewith
//
//  Created by imqiuhang on 15/4/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@protocol LocationManagerDelegate <NSObject>

- (void)didLocationSucceed:(BMKReverseGeoCodeResult *)result;
- (void)didiFalidLocation;
@end

@interface LocationManager : NSObject<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic,weak)id<LocationManagerDelegate>delegate;
- (void)beginSearch;
- (void)stopLocating;

@end

