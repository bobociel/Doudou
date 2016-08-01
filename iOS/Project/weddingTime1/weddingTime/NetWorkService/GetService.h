//
//  GetListService.h
//  lovewith
//
//  Created by imqiuhang on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "NetworkManager.h"
#import "FindItemModel.h"
@class HotelOrSupplierListFilters;
@interface GetService : NSObject

+ (void)getQiniuTokenWithBucket:(NSString *)bucket
                      WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)getInspiretionDefaultTagWithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getDemandListWithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)getDemandDetailWithRewardId:(int)rewardId
						  WithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)getDemandRibedWithRewardId:(int)rewardId
						  WithPage:(int)page
						 WithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+(void)getRewardSelectWithRewardId:(int)rewardId
					WithSupplierId:(int)supplierId
						 WithBlock:(void(^)(NSDictionary *result, NSError *error))block;
+(void)getRewardCloseWithRewardId:(int)rewardId
						WithBlock:(void(^)(NSDictionary *result, NSError *error))block;
+(void)getPriceRangeWithServiceId:(NSString *)serviceId
						WithBlock:(void(^)(NSDictionary *result, NSError *error))block;

+ (AFHTTPRequestOperation *)getSearchInspiretionTagWithPage:(int)page
													 andtag:(NSString *)qTag WithBlock:(void (^)(NSDictionary *result, NSError *error))block ;

+ (AFHTTPRequestOperation *)getSearchInspiretionColorWithPage:(int)page
													 andColor:(NSString *)qColor WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

//搜索
+ (AFHTTPRequestOperation *)getSearchHotelWithPage:(int)page
											  andQ:(NSString *)qStr
										 WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (AFHTTPRequestOperation *)getSearchSupplierWithPage:(int)page
												 andQ:(NSString *)qStr
											WithBlock:(void (^)(NSDictionary *result,NSError *error))block ;

+ (void)getLikeListWithTypeId:(int)typeId
                      andPage:(int)page
                    WithBlock:(void (^)(NSDictionary *, NSError *))block;


+ (void)getSupplierDetailWithId:(NSNumber *)supplierId
					  WithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getFindListWithCount:(NSUInteger)count
					  CityId:(NSString *)city
				WithifUpDrag:(BOOL)ifUpDrag
					   model:(FindItemModel *)model
				   WithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getHotelDetailWithId:(NSNumber *)hotelId
				   WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getSupplierListWithSupplier_id:(int)supplier_id page_no:(int)page
							   city_id:(NSNumber *)city_id
								syn_id:(NSString *)syn_id
								 Block:(void (^)(NSDictionary *,NSError *))block;

+ (void)getHotelListWithPage:(int)page
         andHotelListFilters:(HotelOrSupplierListFilters *)hotelListFilters
                   WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getCityListWithBlock:(void (^)(NSDictionary *,NSError *))block
;
+ (void)getWorkDetailWithPostId:(NSNumber *)post_id
						  Block:(void (^)(NSDictionary *,NSError *))block;
+ (void)getBanquetWithballroomId:(NSNumber *)ballroom_id
						   Block:(void (^)(NSDictionary *,NSError *))block;
+ (void)getMealDetailWithMealId:(NSNumber *)meal_id
						  Block:(void (^)(NSDictionary *,NSError *))block;

+ (void)getChatListMsg:(NSString *)channels
             withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getOrderListWithBlcok:(void (^)(NSDictionary *,NSError *))block;
+ (void)getOrderDetailWithOrder_id:(NSString *)order_id
							 Blcok:(void (^)(NSDictionary *,NSError *))block;

//婚礼主页
+ (void)getHomePageThemeWithBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)getHomepageThemeChoosedWithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getHomePageStoryWithPage:(NSInteger)page
                    andMediaType:(NSString *)mediaType
                       WithBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)getHomePageInviteListWithPage:(int)page
								 type:(NSInteger)type
							WithBlock:(void (^)(NSDictionary *, NSError *))block ;

+ (void)getBlessListWithPage:(NSInteger)page
				   WithBlock:(void(^)(NSDictionary *, NSError *))block;

+ (void)deleteBlessWith:(NSString *)blessID
			  withBlock:(void(^)(NSDictionary *result,NSError *error))block;
+ (void)getBlessCountWithBlock:(void(^)(NSDictionary *result,NSError *error))block;

+ (void)getCityidWithLon:(float)lon
				  andLat:(float)lat
			   WithBlock:(void (^)(NSDictionary *, NSError *))block;

//获取热门词
+(void)getHotVipWithCityid:(int)cityid
				 withBlock:(void(^)(NSDictionary *,NSError *))block;

//婚礼计划
+ (void)getWeddingPlanListWithStatus:(int)status
                             andPage:(int)page
                           WithBlock:(void (^)(NSDictionary *result,
                                               NSError *error))block;
+ (void)getWeddingDetailWithId:(int)status
                     WithBlock:(void (^)(NSDictionary *, NSError *))block;

//最新版本信息
+ (void)getWeddingTimeVersionInfoWithBlock:(void (^)(NSDictionary *result,NSError *error))result;
@end
