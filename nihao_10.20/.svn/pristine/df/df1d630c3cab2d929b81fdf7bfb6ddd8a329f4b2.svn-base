//
//  MyMerchantListFilter.h
//  nihao
//
//  Created by HelloWorld on 6/2/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMerchantListFilter : NSObject

//ci_gpslat 纬度
//ci_gpslong经度
//distance距离
//one_level_mhc_id 一级菜单ID
//two_level_mhc_id 二级菜单ID
//three_level_mhc_id 三级菜单ID
//mhi_city 城市名称
//mhi_district地区名称
//mhi_bid_id 商圈的ID
//keyword 搜索的关键字

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) long distance;
@property (nonatomic, assign) NSInteger oneLevelMhcID;
@property (nonatomic, assign) NSInteger twoLevelMhcID;
@property (nonatomic, assign) NSInteger threeLevelMhcID;
@property (nonatomic, copy) NSString *mhiCityName;
@property (nonatomic, copy) NSString *mhiDistrictName;
@property (nonatomic, assign) NSInteger mhiBidId;
@property (nonatomic, copy) NSString *keyWord;
@property (nonatomic, assign) NSInteger page;// 页码
@property (nonatomic, assign) NSInteger rows;// 每页数据条数

- (instancetype)initWithFilter:(MyMerchantListFilter *)filter;

/* 根据经纬度、一级菜单ID初始化过滤器 */
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude oneLevelMhcID:(NSInteger)oneLevelMhcID;

/* 根据经纬度、距离、一级菜单ID初始化过滤器 */
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude distance:(long)distance oneLevelMhcID:(NSInteger)oneLevelMhcID;

/* 根据一级菜单ID初始化过滤器 */
- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID;

/* 根据二级菜单ID初始化过滤器 */
- (instancetype)initWithTwoLevelMhcID:(NSInteger)twoLevelMhcID;

/* 根据三级菜单ID初始化过滤器 */
- (instancetype)initWithThreeLevelMhcID:(NSInteger)threeLevelMhcID;

/* 根据一级菜单ID、一级城市名称初始化过滤器 */
- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhiCityName:(NSString *)mhiCityName;

/* 根据一级菜单ID、地区名称初始化过滤器 */
- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhidistrictName:(NSString *)mhiDistrictName;

/* 根据一级菜单ID、商圈的ID初始化过滤器 */
- (instancetype)initWithOneLevelMhcID:(NSInteger)oneLevelMhcID mhiBidId:(NSInteger)mhiBidId;

/* 根据传入的所有条件初始化过滤器 */
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude distance:(long)distance oneLevelMhcID:(NSInteger)oneLevelMhcID twoLevelMhcID:(NSInteger)twoLevelMhcID threeLevelMhcID:(NSInteger)threeLevelMhcID mhiCityName:(NSString *)mhiCityName mhiDistrictName:(NSString *)mhiDistrictName mhiBidId:(NSInteger)mhiBidId keyWord:(NSString *)keyWord;

- (NSDictionary *)getNotNULLParameters;

- (void)setPage:(NSInteger)page andRows:(NSInteger)rows;

@end
