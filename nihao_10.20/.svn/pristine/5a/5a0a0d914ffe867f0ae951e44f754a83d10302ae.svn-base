//
//  MyMerchantListFilter.m
//  nihao
//
//  Created by HelloWorld on 6/2/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MyMerchantListFilter.h"
#import "City.h"
#import "AppConfigure.h"
#import "Constants.h"

@implementation MyMerchantListFilter

- (instancetype)initWithFilter:(MyMerchantListFilter *)filter {
    if (self = [self init]) {
        self.latitude = filter.latitude;
        self.longitude = filter.longitude;
        self.distance = filter.distance;
        self.oneLevelMhcID = filter.oneLevelMhcID;
        self.twoLevelMhcID = filter.twoLevelMhcID;
        self.threeLevelMhcID = filter.threeLevelMhcID;
        self.mhiCityName = filter.mhiCityName;
        self.mhiDistrictName = filter.mhiDistrictName;
        self.mhiBidId = filter.mhiBidId;
        self.keyWord = filter.keyWord;
    }
    
    return self;
}

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude oneLevelMhcID:(NSInteger)oneLevelMhcID {
    if (self = [self init]) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.oneLevelMhcID = oneLevelMhcID;
    }
    
    return self;
}

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude distance:(long)distance oneLevelMhcID:(NSInteger)oneLevelMhcID {
    if (self = [self init]) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.distance = distance;
        self.oneLevelMhcID = oneLevelMhcID;
    }
    
    return self;
}

- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID {
    if (self = [self init]) {
        self.oneLevelMhcID = oneLevelMhcID;
    }
    
    return self;
}

- (instancetype)initWithTwoLevelMhcID:(NSInteger)twoLevelMhcID {
    if (self = [self init]) {
        self.twoLevelMhcID = twoLevelMhcID;
    }
    
    return self;
}

- (instancetype)initWithThreeLevelMhcID:(NSInteger)threeLevelMhcID {
    if (self = [self init]) {
        self.threeLevelMhcID = threeLevelMhcID;
    }
    
    return self;
}

- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhiCityName:(NSString *)mhiCityName {
    if (self = [self init]) {
        self.oneLevelMhcID = oneLevelMhcID;
        self.mhiCityName = mhiCityName;
    }
    
    return self;
}

- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhidistrictName:(NSString *)mhiDistrictName {
    if (self = [self init]) {
        self.oneLevelMhcID = oneLevelMhcID;
        self.mhiDistrictName = mhiDistrictName;
    }
    
    return self;
}

- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhiBidId:(NSInteger)mhiBidId {
    if (self = [self init]) {
        self.oneLevelMhcID = oneLevelMhcID;
        self.mhiBidId = mhiBidId;
    }
    
    return self;
}

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude distance:(long)distance
                   oneLevelMhcID:(NSInteger)oneLevelMhcID twoLevelMhcID:(NSInteger)twoLevelMhcID threeLevelMhcID:(NSInteger)threeLevelMhcID
                     mhiCityName:(NSString *)mhiCityName mhiDistrictName:(NSString *)mhiDistrictName mhiBidId:(NSInteger)mhiBidId
                         keyWord:(NSString *)keyWord {
    if (self = [self init]) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.distance = distance;
        self.oneLevelMhcID = oneLevelMhcID;
        self.twoLevelMhcID = twoLevelMhcID;
        self.threeLevelMhcID = threeLevelMhcID;
        self.mhiCityName = mhiCityName;
        self.mhiDistrictName = mhiDistrictName;
        self.mhiBidId = mhiBidId;
        self.keyWord = keyWord;
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.latitude = 0;
        self.longitude = 0;
        self.distance = 0;
        self.oneLevelMhcID = 0;
        self.twoLevelMhcID = 0;
        self.threeLevelMhcID = 0;
        self.mhiCityName = @"";
        self.mhiDistrictName = @"";
        self.keyWord = @"";
        self.page = 1;
        self.rows = DEFAULT_REQUEST_DATA_ROWS_INT;
    }
    
    return self;
}

- (void)setPage:(NSInteger)page andRows:(NSInteger)rows {
    self.page = page;
    self.rows = rows;
}

//http://localhost:8080/nihaoclient/merchantsInfo/getMerchantsInfoByConditions.shtml?
//ci_gpslat=120.4154565
//&ci_gpslong=30.17175154
//&distance=999999999
//&one_level_mhc_id=49
//&two_level_mhc_id=62
//&three_level_mhc_id=63
//&mhi_city=长治市
//&mhi_district=邯郸县
// mhi_bid_id
//&keyword=bas

- (NSDictionary *)getNotNULLParameters {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (self.latitude != 0 && self.longitude != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%lf", self.latitude] forKey:@"ci_gpslat"];
        [parameters setObject:[NSString stringWithFormat:@"%lf", self.longitude] forKey:@"ci_gpslong"];
    } else {
        [parameters setObject:[City getCityFromUserDefault:CURRENT_CITY].city_name forKey:@"mhi_city"];
    }
    if (self.distance != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", self.distance] forKey:@"distance"];
    }
    if (self.oneLevelMhcID != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", self.oneLevelMhcID] forKey:@"one_level_mhc_id"];
    }
    if (self.twoLevelMhcID != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", self.twoLevelMhcID] forKey:@"two_level_mhc_id"];
    }
    if (self.threeLevelMhcID != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", self.threeLevelMhcID] forKey:@"three_level_mhc_id"];
    }
    if (IsStringNotEmpty(self.mhiCityName)) {
        [parameters setObject:[NSString stringWithFormat:@"%@", self.mhiCityName] forKey:@"mhi_city"];
    }
    if (IsStringNotEmpty(self.mhiDistrictName)) {
        [parameters setObject:[NSString stringWithFormat:@"%@", self.mhiDistrictName] forKey:@"mhi_district"];
    }
    if (self.mhiBidId != 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", self.mhiBidId] forKey:@"mhi_bid_id"];
    }
    if (IsStringNotEmpty(self.keyWord)) {
        [parameters setObject:[NSString stringWithFormat:@"%@", self.keyWord] forKey:@"keyword"];
    }
    [parameters setObject:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%ld",self.rows] forKey:@"rows"];
    return parameters;
}

@end
