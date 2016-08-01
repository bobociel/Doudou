//
//  PostDataService.h
//  lovewith
//
//  Created by imqiuhang on 15/4/20.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "UserInfoManager.h"
#import "WTUploadManager.h"
#import "AVIMRequestOperationManager.h"
@interface PostDataService : NSObject

//需求
+ (void)postDemandWithServiceType:(NSString *)serviceType andPriceRange:(NSString *)priceRange andWeddingTime:(NSString *)weddingTime andCity:(NSString *)city andNote:(NSString *)notes withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postInspirationLikeWithImageId:(int)imageId withBlock:(void (^)(NSDictionary *, NSError *))block ;

+ (void)postWeddingHomePageUpadateInfomationWithName:(NSString *)name
                                        andLoverName:(NSString *)lname
                                             androle:(UserGender)role
                                 andweddingTimestamp:(int64_t)time
                                           anddomain:(NSString *)domain
                                   andWeddingAddress:(NSString *)address
									andWeddingPoint:(NSString *)point
                                          andMyAvata:(NSString *)myavataKey
                                     andPartnerAvata:(NSString *)partnerAvataKey
                                           withBlock:
(void (^)(NSDictionary *,
          NSError *))block;

+ (void)postUserCenterWithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postSend_smsTellSupplier:(NSString *)Supplier withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postLikeWithService_id:(NSNumber *)service_id Block:(void (^)(NSDictionary *restult,NSError *error))block;
+ (void)postLikeWithHotel_id:(NSNumber *)hotel_id Block:(void (^)(NSDictionary *restult,NSError *error))block;

//婚礼主页

+ (void)postWeddingHomeUpadateStoryWithStory:(WTWeddingStory *)story
									orStorys:(NSArray *)storys
								   withBlock:(void(^)(NSDictionary *,NSError *error))block;
+ (void)postWeddingHomeModifyStoryWithStory:(WTWeddingStory *)story
								  withBlock:(void(^)(NSDictionary *,NSError *error))block;
+ (void)postUpdateHomepageBackgroudWithImageKey:(NSString *)imageKey
									  withBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)POSTWeddingHomeChooseMusic:(NSString *)theme_type andId:(int)musicId
						 withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postWeddingHomeStorySortWithSortArr:(NSArray *)sortIds
								  withBlock:(void (^)(NSDictionary *, NSError *))block ;
+ (void)postWeddingHomeDelegate:(int)storyId
					  withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postOrderRefunChild_order_no:(NSString *)child_order_no
							  reason:(NSString *)reason
						   withBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postOrderCancelChild_order_no:(NSString *)child_order_no
							withBlock:(void (^)(NSDictionary *, NSError *))block;

//婚礼计划 如果是新建则MatterId不传
+ (void)postWeddingPlanInfoWithMatterId:(int)matterId
                               andTitle:(NSString *)title
                         andDescription:(NSString *)description
                           andCloseTime:(int64_t)closeTime
                          andRemindTime:(int64_t)remindTime
                              withBlock:(void (^)(NSDictionary *result,
                                                  NSError *error))block;

+ (void)postWeddingPlanChangeStatusWithMatterId:(int)matterId
                                      andStatus:(int)status
                                      withBlock:(void (^)(NSDictionary *result,
                                                          NSError *error))block;

+ (void)postWeddingPlanDelegateWithMatterId:(int)matterId
                                  withBlock:(void (^)(NSDictionary *result,
                                                      NSError *error))block;


+ (void)postSetWeddingTime:(int64_t)weddingTime WithBlock:(void (^)(NSDictionary *result,
                                                                    NSError *error))block;

+ (void)postOrderCancelOut_trade_no:(NSString *)out_trade_no
					 child_trade_no:(NSString *)child_order_no
						  WithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postReserveSupplier_id:(NSNumber *)supplier_id
				  order_source:(NSNumber *)order_source
				 weddingCityId:(NSString *)city_id
						  time:(int64_t)time type:(NSInteger)type
					 source_id:(NSNumber *)source_id
					 WithBlock:(void (^)(NSDictionary *, NSError *))block;
+ (void)postAlipayParamsWithChild_trade_no:(NSString *)child_trade_no withBlock:(void(^)(NSDictionary *,NSError *))block;

+ (void)postChatOnlineStatus:(NSArray *)peers  WithBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postSendOnlineStatusMsg:(NSString*)conversationId unread:(int)unread uid:(NSString*)uid uname:(NSString*)uname suid:(NSString*)suid suname:(NSString*)suname WithBlock:(void (^)(NSDictionary *, NSError *))block;
@end
