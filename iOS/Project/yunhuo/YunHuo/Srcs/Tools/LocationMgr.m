#import "LocationMgr.h"

@implementation LocationMgr

static LocationMgr* _instance;

+ (LocationMgr *)instance
{
    @synchronized(self) {
        if (!_instance)
            _instance=[[LocationMgr alloc] init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        _mapView = nil;
        _location = nil;
        CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
        self.geoCoder = clGeoCoder;
    }
    return self;
}

#pragma CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    [self stop];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
	_lm.delegate = nil;
    [_lm stopUpdatingLocation];
	
	if ( locations.count > 0 )
	{
		self.location = locations[0];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToLocateUserWithError:)])
    {
        [_delegate didFailToLocateUserWithError:error];
    }
	_lm.delegate = nil;
    [_lm stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationAuthorStatusChanged object:nil];
}

- (void)start
{
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.lm = [[CLLocationManager alloc] init];
        self.lm.delegate = self;
        [self.lm startUpdatingLocation];
//    }
//    else {
//        [self stop];
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
//    }
}

- (void)stop
{
    _mapView.delegate = nil;
	_mapView = nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.location = userLocation.location;
        
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
    {
        [self locationAddressWithLocation:userLocation.location];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) 
    {
        [_delegate didUpdateLocation:userLocation.location];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToLocateUserWithError:)]) 
    {
        [_delegate didFailToLocateUserWithError:error];
    }   
    self.location = nil;

}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    if (_delegate && [_delegate respondsToSelector:@selector(didBegginLoaction)])
    {
        [_delegate didBegginLoaction];
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    
}

//  IOS 5.0 及以上版本使用此方法
- (void)locationAddressWithLocation:(CLLocation *)locationGps
{
    
    [self.geoCoder reverseGeocodeLocation:locationGps completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"reverseGeocodeLocation error!!! : %@",error);
                 if (_delegate && [_delegate respondsToSelector:@selector(didFailToGetAddressWithError:)])
                 {
                     [_delegate didFailToGetAddressWithError:error];
                 }
             });
         }
         else
         {
             NSLog(@"error %@ placemarks count %lu",error.localizedDescription,(unsigned long)placemarks.count);
             if (placemarks.count == 0)
             {
                 [_delegate didFailToGetAddressWithError:nil];
             }
             else
             {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSLog(@"地址: %@", placemark );
                 NSLog(@"地址：%@",placemark.locality);
                 NSLog(@"地址：%@",placemark.thoroughfare);
                 NSLog(@"地址：%@",placemark.subLocality);
                 
                 [self dealPlacemark:placemark];

             }
         }
         
     }];
}

- (void)dealPlacemark:(CLPlacemark*)placemark
{
    NSString *temp = nil;
    if ([placemark.addressDictionary objectForKey:@"FormattedAddressLines"])
    {
        temp = [NSString stringWithString:[[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
    }
    
    //                 if (placemark.administrativeArea.length > 0)
    //                 {
    //                     [temp appendString:placemark.administrativeArea];
    //                 }
    //                 if (placemark.locality.length > 0)
    //                 {
    //                     [temp appendString:placemark.locality];
    //                 }
    //                 if (placemark.subLocality.length > 0)
    //                 {
    //                     [temp appendString:placemark.subLocality];
    //                 }
    //                 if (placemark.thoroughfare.length > 0)
    //                 {
    //                     [temp appendString:placemark.thoroughfare];
    //                 }
    if (temp)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(didGetAddress:)])
        {
            [_delegate didGetAddress:temp];
        }
    }
    else
    {
        [_delegate didFailToGetAddressWithError:nil];
    }
}

- (BOOL)locationServiceEnabled
{
	return  ( [CLLocationManager locationServicesEnabled] &&
            ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized  ||
			  [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ));
}

@end
