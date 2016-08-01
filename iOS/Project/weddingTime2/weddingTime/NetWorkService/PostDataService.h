//
//  PostDataService.h
//  lovewith
//
//  Created by imqiuhang on 15/4/20.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTMatter.h"
#import "WTWeddingBless.h"
#import "NetworkManager.h"
#import "UserInfoManager.h"
#import "WTUploadManager.h"
@interface PostDataService : NSObject
//个人相关,个人信息
+ (void)postWeddingHomePageUpadateInfomationWithName:(NSString *)name
										andLoverName:(NSString *)lname
											 androle:(UserGender)role
								 andweddingTimestamp:(int64_t)time
										   anddomain:(NSString *)domain
								   andWeddingAddress:(NSString *)address
									 andWeddingPoint:(NSString *)point
										  andMyAvata:(NSString *)myavataKey
									 andPartnerAvata:(NSString *)partnerAvataKey
										   withBlock:(void (^)(NSDictionary *,NSError *))block;
+ (void)postUserCenterWithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postSendEmailBlock:(void (^)(NSDictionary *, NSError *))block;

//个人相关,预算
+ (void)putBudgetWithInfo:(NSMutableDictionary *)budgets withBlock:(void (^)(NSDictionary *, NSError *))block;

//个人相关,喜欢
+ (void)postInspirationLikeWithImageId:(int)imageId withBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)postLikeWithService_id:(NSString *)service_id Block:(void (^)(NSDictionary *restult,NSError *error))block;
+ (void)postLikeWithHotel_id:(NSString *)hotel_id Block:(void (^)(NSDictionary *restult,NSError *error))block;
+ (void)postLikeWithPostID:(NSString *)postID Block:(void (^)(NSDictionary *restult,NSError *error))block;

//需求
+ (void)postDemandWithServiceType:(NSString *)serviceType
					andPriceRange:(NSString *)priceRange
				   andWeddingTime:(NSString *)weddingTime
						  andCity:(NSString *)city
						  andNote:(NSString *)notes
						withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)deleteDemandWithDemandID:(NSString *)demandID callback:(void(^)(NSDictionary *, NSError *))callback;

//婚礼主页
+ (void)postWeddingHomeUpadateStoryWithStory:(WTWeddingStory *)story
									orStorys:(NSArray *)storys
								   withBlock:(void(^)(NSDictionary *,NSError *error))block;
+ (void)postWeddingHomeModifyStoryWithStory:(WTWeddingStory *)story
								  withBlock:(void(^)(NSDictionary *,NSError *error))block;
+ (void)postUpdateHomepageBackgroudWithImageKey:(NSString *)imageKey
									  withBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)POSTWeddingHomeChooseMusic:(NSString *)theme_type andId:(NSString *)musicId
						 withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postWeddingHomeStorySortWithSortArr:(NSArray *)sortIds
								  withBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)postWeddingHomeDelegate:(int)storyId
					  withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postWeddingHomeShowPhone:(BOOL)show
						 myPhone:(NSString *)myPhone
					  otherPhone:(NSString *)halfPhone
					   withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postWeddingDesks:(NSArray *)desks show:(BOOL)show callback:(void(^)(NSDictionary *, NSError *))callback;

+ (void)deleteWeddingDeskWithID:(NSString *)deskID callback:(void(^)(NSDictionary *, NSError *))callback;

+ (void)postWeddingProcess:(WTWeddingProcess *)process callback:(void(^)(NSDictionary *, NSError *))callback;

+ (void)postShowWeddingProcess:(BOOL)show callback:(void(^)(NSDictionary *, NSError *))callback;

+ (void)deleteWeddingProcessWithID:(NSString *)proID callback:(void(^)(NSDictionary *, NSError *))callback;

//婚礼宝
+ (void)postGetTicketWithTicketID:(NSString *)ID block:(void (^)(NSDictionary *, NSError *))block;

//婚礼计划
+ (void)postWeddingPlanInfoWithMatter:(WTMatter *)matter withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postWeddingPlanChangeStatusWithMatterId:(NSString *)matterId
                                      andStatus:(int)status
                                      withBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)postWeddingPlanDelegateWithMatterId:(NSString *)matterId withBlock:(void (^)(NSDictionary *,NSError *))block;

+ (void)postSetWeddingTime:(int64_t)weddingTime WithBlock:(void (^)(NSDictionary *,NSError *))block;

//商家统计，广告统计
+ (void)postAccessLogWithServiceID:(WTWeddingType)serviceType andCityID:(NSString *)cityID andID:(NSString *)suID andLogType:(WTLogType)logType;


//婚礼订单
/*
+ (void)postOrderRefunChild_order_no:(NSString *)child_order_no
							  reason:(NSString *)reason
						   withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postOrderCancelChild_order_no:(NSString *)child_order_no
							withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postOrderCancelOut_trade_no:(NSString *)out_trade_no
					 child_trade_no:(NSString *)child_order_no
						  WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postReserveSupplier_id:(NSString *)supplier_id
				  order_source:(NSNumber *)order_source
				 weddingCityId:(NSString *)city_id
						  time:(int64_t)time
					 source_id:(NSString *)source_id
					 WithBlock:(void (^)(NSDictionary *, NSError *))block;
*/

+ (void)postAlipayParamsWithChild_trade_no:(NSString *)child_trade_no withBlock:(void(^)(NSDictionary *,NSError *))block;
@end
