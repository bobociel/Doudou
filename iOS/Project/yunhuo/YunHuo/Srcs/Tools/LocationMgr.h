#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define kLocationAuthorStatusChanged		@"kLocationAuthorStatusChanged"

@protocol LocationMgrDelegate <NSObject>
@optional
- (void)didUpdateLocation:(CLLocation*)location;
- (void)didFailToLocateUserWithError:(NSError *)error;
- (void)didBegginLoaction;
- (void)didGetAddress:(NSString*)address;
- (void)didFailToGetAddressWithError:(NSError *)error;

@end

@interface LocationMgr : NSObject<MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKMapView   *_mapView;
}

@property (nonatomic, weak) id<LocationMgrDelegate> delegate;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) CLGeocoder *geoCoder;
@property (nonatomic, retain) CLLocationManager *lm;

+ (LocationMgr*)instance;

- (void)start;
- (void)stop;
- (BOOL)locationServiceEnabled;

@end
