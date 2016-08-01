//
//  LocationManager.m
//  lovewith
//
//  Created by imqiuhang on 15/4/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "LocationManager.h"
@implementation LocationManager
{
    BMKLocationService *locService;
    BMKGeoCodeSearch   *geocodesearch;
}


- (id)init {
    if (self==[super init]) {
    }
    return self;
}

- (void)beginSearch {
    locService = [[BMKLocationService alloc] init];
    geocodesearch = [[BMKGeoCodeSearch alloc]init];
    [self getLocation];
}



- (void)getLocation {
    locService.delegate = self;
    [locService startUserLocationService];    
}


- (void)getCityWithLocation:(CLLocation *)location {
    geocodesearch.delegate = self;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = location.coordinate;
    BOOL flag = [geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    
    if(flag) {
        MSLog(@"反geo检索发送成功");
    }else {
        if ([self.delegate respondsToSelector:@selector(didiFalidLocation)]) {
            [self.delegate didiFalidLocation];
        }
        [self stopLocating];
    }
    
}


#pragma mark -
#pragma mark BMapDelegate

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    if (userLocation.location!=nil) {
        [self getCityWithLocation:userLocation.location];
        
    }else {
        if ([self.delegate respondsToSelector:@selector(didiFalidLocation)]) {
            [self.delegate didiFalidLocation];
            MSLog(@"定位失败:没有返回位置经纬度");
            [self stopLocating];
        }
    }
}

- (void)stopLocating {
    [locService stopUserLocationService];
    locService.delegate=nil;
    geocodesearch.delegate=nil;
    locService=nil;
    geocodesearch=nil;
    
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error!=BMK_SEARCH_NO_ERROR) {
        if ([self.delegate respondsToSelector:@selector(didiFalidLocation)]) {
            [self.delegate didiFalidLocation];
            MSLog(@"反geo检索发送成功,但获取数据失败：\n%u",error);
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(didLocationSucceed:)]) {
            [self.delegate didLocationSucceed:result];
            MSLog(@"获取位置成功:\n,%@",result);
        }
    }
    [self stopLocating];
}


@end
