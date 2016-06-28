//
//  GetListService.h
//  lovewith
//
//  Created by imqiuhang on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "NetworkManager.h"
#import "FindItemModel.h"
#import "WTFilterHotelViewController.h"
@interface GetService : NSObject

+ (void)getQiniuTokenWithBucket:(NSString *)bucket
                      WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)getInspiretionDefaultTagWithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getDemandListWithPage:(NSUInteger)page block:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)getDemandDetailWithRewardId:(NSString *)rewardId
						  WithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)getDemandRibedWithRewardId:(NSString *)rewardId
						  WithPage:(NSInteger)page
						 WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+(void)getRewardSelectWithRewardId:(NSString *)rewardId
					WithSupplierId:(int)supplierId
						 WithBlock:(void(^)(NSDictionary *result, NSError *error))block;

+(void)getPriceRangeWithServiceId:(NSString *)serviceId
						WithBlock:(void(^)(NSDictionary *result, NSError *error))block;

+ (NSURLSessionDataTask *)getSearchInspiretionTagWithPage:(int)page
													 andtag:(NSString *)qTag WithBlock:(void (^)(NSDictionary *result, NSError *error))block ;

+ (NSURLSessionDataTask *)getSearchInspiretionColorWithPage:(int)page
													 andColor:(NSString *)qColor WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

//搜索
+ (NSURLSessionDataTask *)getSearchHotelWithPage:(NSInteger)page
											  andQ:(NSString *)qStr
										 WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (NSURLSessionDataTask *)getSearchSupplierWithPage:(NSInteger)page
												 andQ:(NSString *)qStr
											WithBlock:(void (^)(NSDictionary *result,NSError *error))block ;

+ (void)getLikeListWithTypeId:(int)typeId
                      andPage:(NSUInteger)page
                    WithBlock:(void (^)(NSDictionary *, NSError *))block;


+ (void)getSupplierDetailWithId:(NSString *)supplierId
					  WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getFindListWithCount:(NSUInteger)count
					  CityId:(NSString *)city
				WithifUpDrag:(BOOL)ifUpDrag
					   model:(FindItemModel *)model
				   WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getHotelDetailWithId:(NSString *)hotelId
				   WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getSupplierListWithSupplierType:(NSInteger)supplierType
								   page:(NSInteger)page
								subpage:(NSInteger)subpage
								 cityID:(NSNumber *)cityID
								  synID:(NSString *)synID
								  Block:(void (^)(NSDictionary *,NSError *))block;
+ (void)getPostListWithSupplierType:(NSInteger)supplierType
							   page:(NSInteger)page
							subpage:(NSInteger)subpage
							 cityID:(NSNumber *)cityID
							  synID:(NSString *)synID
							  price:(NSString *)price
							  Block:(void (^)(NSDictionary *,NSError *))block;

+ (void)getHotelListWithPage:(NSInteger)page
         andHotelListFilters:(WTHotelFilters *)hotelFilters
                   WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getCityListWithBlock:(void (^)(NSDictionary *,NSError *))block;

+ (void)getAllCityWithBlock:(void (^)(NSDictionary *,NSError *))block;

+ (void)getWorkDetailWithPostId:(NSString *)post_id
						  Block:(void (^)(NSDictionary *,NSError *))block;
+ (void)getBanquetWithballroomId:(NSString *)ballroom_id
						   Block:(void (^)(NSDictionary *,NSError *))block;
+ (void)getMealDetailWithMealId:(NSString *)meal_id
						  Block:(void (^)(NSDictionary *,NSError *))block;

+ (void)getChatListMsg:(NSString *)channels
             withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)getOrderListWithBlcok:(void (^)(NSDictionary *,NSError *))block;
+ (void)getOrderDetailWithOrder_id:(NSString *)order_id
							 Blcok:(void (^)(NSDictionary *,NSError *))block;
//关于个人
+ (void)getCityidWithLon:(float)lon andLat:(float)lat WithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getBudgetBlock:(void (^)(NSDictionary *, NSError *))block;
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

+ (void)getCardListWithPage:(NSUInteger)page callback:(void(^)(NSDictionary *result,NSError *eror))callback;

+ (void)getCardDetailWithCardID:(NSString *)cardId callback:(void(^)(NSDictionary *result,NSError *eror))callback;

+ (void)getShowPhoneWithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getDeskListWithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)getProcessListWithBlock:(void (^)(NSDictionary *, NSError *))block;
//婚礼宝
+ (void)getTicketListWithSID:(NSString *)ID block:(void(^)(NSDictionary *,NSError *))block;
+ (void)getUserTicketListWithPage:(NSInteger)page flag:(NSString *)flag block:(void(^)(NSDictionary *,NSError *))block;
+ (void)getUserWithdrewTicketListBlock:(void(^)(NSDictionary *,NSError *))block;
+ (void)getTicketDetailWithTicketID:(NSString *)ID block:(void(^)(NSDictionary *,NSError *))block;
//新娘商店
+ (void)getShopListWithType:(WTWeddingType)type
					andPage:(NSInteger)page
				 andSubpage:(NSInteger)subpage
				  andCityID:(NSString *)ID
					  block:(void(^)(NSDictionary *,NSError *))block;
+ (void)getShopDetailWithID:(NSString *)ID Block:(void(^)(NSDictionary *,NSError *))block;
//获取热门词
+(void)getHotVipWithCityid:(NSInteger)cityid withBlock:(void(^)(NSDictionary *,NSError *))block;

//婚礼计划
+ (void)getWeddingPlanListWithStatus:(NSUInteger)status
                             andPage:(NSUInteger)page
                           WithBlock:(void (^)(NSDictionary *result,
                                               NSError *error))block;
+ (void)getWeddingDetailWithId:(NSString *)status
                     WithBlock:(void (^)(NSDictionary *, NSError *))block;
//开屏广告
+ (void)getWeddingAdviertisementWithBlock:(void (^)(NSDictionary *result,NSError *error))block;
//最新版本信息
+ (void)getWeddingTimeVersionInfoWithBlock:(void (^)(NSDictionary *result,NSError *error))result;

@end
