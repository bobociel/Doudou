//
//  PostDataService.m
//  lovewith
//
//  Created by imqiuhang on 15/4/20.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "PostDataService.h"
//个人相关
#define APIUSERCENTER                      @"app/v020/u/center/profile/get/"   //获得用户信息
#define APIWEDDINGHOMEUPDATEINFOMATION     @"/app/v020/u/center/home/profile/" //更新用户信息
#define APISENDEMAIL                       @"/app/v020/u/session/notify"    //发送邮件，第一次和商家会话时
#define APIPUTBUDGET                       @"/app/v021/u/budget"            //设置预算

#define APILIKESUPPLIER                    @"/app/v010/su/like"             //喜欢商家
#define APILIKEHOTEL                       @"/app/v010/hotel/like"          //喜欢酒店
#define APILIKEINSPIPATION                 @"/app/v010/follow/add_follow"   //喜欢灵感
#define APILIKEPOST                        @"/app/v020/follow/post_like"    //喜欢作品
//婚礼主页
#define APIWEDDINGHOMEPAGEGETSTORYUpadate     @"/app/v020/card/upload_image" //上传图片故事
#define APIWEDDINGHOMEPAGEGETVIDEOSTORYUpdate @"/app/v020/card/upload_video" //上传视频故事
#define APIWEDDINGHOMEPAGESTORYDELETE         @"/app/v020/card/del_media"    //删除故事
#define APIWEDDINGHOMEPAGESTORYMODIFY		  @"/app/v020/card/edit_media"   //编辑故事
#define APIWEDDINGHOMEPAGESTORYChangeSort     @"/app/v020/card/card_sort"    //排序图片故事
#define APIUPDATEHOMEPAGEBACKGROUD            @"/app/v020/card/background"   //设置请柬背景
#define APIWEDDINGHOMEPAGESTROYCHOODEMUSIC    @"/app/v020/card/set_theme"    //设置请柬主题
#define APIWEDDINGHOMEPAGESETSHOWPHONE        @"/app/v020/card/contact"      //设置请柬联系人开关
#define APIWEDDINGHOMEPAGEPOSTDESK            @"/app/v020/card/seat_chart/"  //上传座位表
#define APIWEDDINGHOMEPAGEDELETEDESK(ID)      [NSString stringWithFormat:@"/app/v020/card/seat_chart/%@",ID] //删除座位表
#define APIWEDDINGHOMEPAGEPOSTSHOWPROCESS     @"/app/v020/card/wedding/process/enable" //关闭打开婚礼流程
#define APIWEDDINGHOMEPAGEPOSTPROCESS(ID)     [NSString stringWithFormat:@"/app/v020/card/wedding/process/%@",ID]       //上传婚礼流程
#define APIWEDDINGHOMEPAGEDELETEPROCESS(ID)   [NSString stringWithFormat:@"/app/v020/card/wedding/process/%@",ID] //删除婚礼流程
//婚礼需求
#define APIDEMANDCREATE             @"/app/v020/reward/new" //创建婚礼需求
#define APIDEMANDDELETE(ID)         [NSString stringWithFormat:@"/app/v021/reward/%@",ID] //删除婚礼需求
//婚礼宝
#define APITICKETGET                      @"/app/v021/u/coupon/obtain"       //婚礼宝,用户获取优惠券
//婚礼计划
#define APIWEDDINGSETTIME                  @"/app/v010/u/wedding/set_time"   //设置婚礼时间
#define APIWEDDINGPLANAdd                  @"/app/v010/matter/add_matter"    //创建婚礼计划
#define APIWEDDINGPLANCHANGESTATUS         @"/app/v010/matter/change_matter" //修改婚礼计划
#define APIWEDDINGPLANDELEGATE             @"/app/v010/matter/delete_matter" //删除婚礼计划
//订单
#define APIWEDDINGRESERVE                  @"app/v020/order/reserve"         //预约订单(v1.0-2.0.5使用)
#define APIORDERREFUND                     @"/app/v020/order/refund"         //退款订单(v1.0-2.0.5使用)
#define APIORDERCANCEL                     @"app/v020/order/cancel"          //取消订单(v1.0.-2.0.5使用)
//支付宝参数
#define APIAPLIPAYPARAMETER                @"/app/v020/order/pay"            //根据订单号获得支付参数
@implementation PostDataService
//个人相关
+ (void)postWeddingHomePageUpadateInfomationWithName:(NSString *)name
										andLoverName:(NSString *)lname
											 androle:(UserGender)role
								 andweddingTimestamp:(int64_t)time
										   anddomain:(NSString *)domain
								   andWeddingAddress:(NSString *)address
									 andWeddingPoint:(NSString *)point
										  andMyAvata:(NSString *)myavataKey
									 andPartnerAvata:(NSString *)partnerAvataKey
										   withBlock:(void (^)(NSDictionary *,NSError *))block {

	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:10];
	parameter[@"token"]=[UserInfoManager instance].tokenId_self;
	if ([name isNotEmptyCtg]) { parameter[@"name"] = name; }
	if ([lname isNotEmptyCtg]) { parameter[@"lover"] = lname; }
	if (role!=UserGenderUnknow) { parameter[@"role"] = role==UserGenderMale?@"m":@"f"; }
	if (time>0) { parameter[@"wedding_timestamp"] = @(time); }
	if ([domain isNotEmptyCtg]) { parameter[@"domain"] = domain; }
	if ([address isNotEmptyCtg]) { parameter[@"wedding_address"] = address; }
	if ([myavataKey isNotEmptyCtg]) { parameter[@"my_avatar"] = myavataKey; }
	if (partnerAvataKey) { parameter[@"lover_avatar"] = partnerAvataKey; }
	if([point isNotEmptyCtg]){
		NSArray *mapPoint = [point componentsSeparatedByString:@","];
		if(mapPoint.count ==2 ){
			parameter[@"wedding_map_point"] = [NSString stringWithFormat:@"%@,%@",mapPoint[1],mapPoint[0]];
		}
	}

	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEUPDATEINFOMATION
								 parameters:[parameter copy]
								  withBlock:block];
}

+ (void)postUserCenterWithBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSDictionary *params = @{@"token":[UserInfoManager instance].tokenId_self};
	[[NetworkManager sharedClient] postPath:APIUSERCENTER parameters:params withBlock:block];
}

+ (void)postSendEmailBlock:(void (^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] postPath:APISENDEMAIL
								 parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
											   @"id" : [UserInfoManager instance].userId_self,
											   @"name" : [UserInfoManager instance].username_self ? : @"",}
								  withBlock:block];
}

//个人相关,BUDGET
+ (void)putBudgetWithInfo:(NSMutableDictionary *)budgets withBlock:(void (^)(NSDictionary *, NSError *))block
{
	budgets[@"token"] = TOKEN;
	[[NetworkManager sharedClient] postPath:APIPUTBUDGET parameters:budgets withBlock:block];
}

//个人相关,LIKE
+ (void)postLikeWithService_id:(NSString *)service_id Block:(void (^)(NSDictionary *restult,NSError *error))block
{
	NSDictionary *params = @{@"token" : [UserInfoManager instance].tokenId_self,
							 @"user_id" : service_id,
							 };
	[[NetworkManager sharedClient] postPath:APILIKESUPPLIER parameters:params withBlock:block];
}

+ (void)postLikeWithHotel_id:(NSNumber *)hotel_id Block:(void (^)(NSDictionary *restult,NSError *error))block
{
	NSDictionary *params = @{@"token" : [UserInfoManager instance].tokenId_self,
							 @"hotel_id" : hotel_id};
	[[NetworkManager sharedClient] postPath:APILIKEHOTEL parameters:params withBlock:block];
}

+ (void)postLikeWithPostID:(NSString *)postID Block:(void (^)(NSDictionary *restult,NSError *error))block
{
	NSDictionary *params = @{@"token" : [UserInfoManager instance].tokenId_self,
							 @"id" : postID};
	[[NetworkManager sharedClient] postPath:APILIKEPOST parameters:params withBlock:block];
}

+ (void)postInspirationLikeWithImageId:(int)imageId withBlock:(void (^)(NSDictionary *, NSError *))block {
	[[NetworkManager sharedClient] postPath:APILIKEINSPIPATION parameters:@{@"token":[UserInfoManager instance].tokenId_self,@"image_id":@(imageId)} withBlock:block];
}

//DEMAND
+ (void)postDemandWithServiceType:(NSString *)serviceType
                   andPriceRange:(NSString *)priceRange
                   andWeddingTime:(NSString *)weddingTime
                   andCity:(NSString *)city
                   andNote:(NSString *)notes
						withBlock:(void (^)(NSDictionary *, NSError *))block {
    NSLog(@"%@",[UserInfoManager instance].tokenId_self);
    [[NetworkManager sharedClient] postPath:APIDEMANDCREATE
                                 parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
                                              @"service" : serviceType,
                                              @"price_range":priceRange,
                                              @"wedding_time" : weddingTime,
                                              @"city" : city,
                                              @"content":notes
                                              }
                                  withBlock:block];
}

+ (void)deleteDemandWithDemandID:(NSString *)demandID callback:(void(^)(NSDictionary *, NSError *))callback
{
	[[NetworkManager sharedClient] deletePath:APIDEMANDDELETE(demandID)
								   parameters:@{@"token":TOKEN}
									withBlock:callback];
}

//婚礼主页
+ (void)postWeddingHomeUpadateStoryWithStory:(WTWeddingStory *)story orStorys:(NSArray *)storys withBlock:(void(^)(NSDictionary *,NSError *error))block
{
	NSString	*urlPath = @"";
	NSMutableDictionary *storyDict ;
	if(storys.count > 0){
		urlPath = APIWEDDINGHOMEPAGEGETSTORYUpadate;
		storyDict = [@{@"data":[storys modelToJSONString]} mutableCopy];
	}
	else{
		urlPath = story.media_type == WTFileTypeImage ? APIWEDDINGHOMEPAGEGETSTORYUpadate : APIWEDDINGHOMEPAGEGETVIDEOSTORYUpdate ;
		if(story.media_type == WTFileTypeImage){
			storyDict = [@{@"data":[@[story] modelToJSONString]} mutableCopy];
		}else{
			storyDict = [story modelToJSONObject];
		}
	}

    storyDict[@"token"] = [UserInfoManager instance].tokenId_self;
    [[NetworkManager sharedClient] postPath:urlPath parameters:storyDict withBlock:block];
}

+ (void)postWeddingHomeModifyStoryWithStory:(WTWeddingStory *)story withBlock:(void(^)(NSDictionary *,NSError *error))block
{
	[[NetworkManager sharedClient] postPath:[NSString stringWithFormat:@"%@/%.f",APIWEDDINGHOMEPAGESTORYMODIFY,story.ID]
								 parameters:@{@"content":story.content,@"token":[UserInfoManager instance].tokenId_self}
								  withBlock: block];
}

+ (void)postUpdateHomepageBackgroudWithImageKey:(NSString *)imageKey withBlock:(void (^)(NSDictionary *, NSError *))block {
	NSMutableDictionary *params = imageKey.length > 0 ? [@{@"token":TOKEN,@"path":imageKey} mutableCopy] : [@{@"token":TOKEN} mutableCopy];

    [[NetworkManager sharedClient] postPath:APIUPDATEHOMEPAGEBACKGROUD
                                 parameters:params
                                  withBlock:block];
}

+ (void)POSTWeddingHomeChooseMusic:(NSString *)theme_type andId:(NSString *)musicId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGESTROYCHOODEMUSIC
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"theme_type":theme_type,
                                              @"id":musicId
                                              }
                                  withBlock:block];
}

+ (void)postWeddingHomeStorySortWithSortArr:(NSArray *)sortIds withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGESTORYChangeSort
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
											  @"post_list":[sortIds modelToJSONString]
                                              }
                                  withBlock:block];
}

+ (void)postWeddingHomeDelegate:(int)storyId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGESTORYDELETE
                                 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
                                              @"id":@(storyId)}
                                  withBlock:block];
}

+ (void)postWeddingHomeShowPhone:(BOOL)show
						 myPhone:(NSString *)myPhone
					  otherPhone:(NSString *)halfPhone
					   withBlock:(void (^)(NSDictionary *, NSError *))block {
	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGESETSHOWPHONE
								 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
											  @"enable_contact":@(show),
											  @"own_phone":myPhone,
											  @"half_phone":halfPhone}
								  withBlock:block];
}

+ (void)postWeddingDesks:(NSArray *)desks show:(BOOL)show callback:(void(^)(NSDictionary *, NSError *))callback;
{
	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGEPOSTDESK
								 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
											  @"data":[desks modelToJSONString],
											  @"enable":@(show)}
								  withBlock:callback];
}

+ (void)deleteWeddingDeskWithID:(NSString *)deskID callback:(void(^)(NSDictionary *, NSError *))callback
{
	[[NetworkManager sharedClient] deletePath:APIWEDDINGHOMEPAGEDELETEDESK(deskID)
								   parameters:@{@"token":TOKEN}
									withBlock:callback];
}

+ (void)postWeddingProcess:(WTWeddingProcess *)process callback:(void(^)(NSDictionary *, NSError *))callback;
{
	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGEPOSTPROCESS(process.ID)
								 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
											  @"time" : @(process.time),
											  @"content" : process.content ?: @""}
								  withBlock:callback];
}

+ (void)postShowWeddingProcess:(BOOL)show callback:(void(^)(NSDictionary *, NSError *))callback;
{
	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGEPOSTSHOWPROCESS
								 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
											  @"enable":@(show)}
								  withBlock:callback];
}

+ (void)deleteWeddingProcessWithID:(NSString *)proID callback:(void(^)(NSDictionary *, NSError *))callback
{
	[[NetworkManager sharedClient] deletePath:APIWEDDINGHOMEPAGEDELETEPROCESS(proID)
								   parameters:@{@"token":TOKEN}
									withBlock:callback];
}

//婚礼宝
+ (void)postGetTicketWithTicketID:(NSString *)ID block:(void (^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] postPath:APITICKETGET parameters:@{@"id":ID,@"token":TOKEN} withBlock:block];
}

//婚礼计划
+ (void)postWeddingPlanInfoWithMatter:(WTMatter *)matter withBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSMutableDictionary *parameters = [@{@"token" : [UserInfoManager instance].tokenId_self,
										@"matter_title" : matter.title,
										@"matter_description":matter.desc,
										@"matter_close_time":@(matter.close_time),
										@"matter_remind_time":@(matter.remind_time)
										}  mutableCopy];

	if(matter.matter_id) { parameters[@"matter_id"] = matter.matter_id ; }
	[[NetworkManager sharedClient] postPath:APIWEDDINGPLANAdd
								 parameters:parameters
								  withBlock:block];
}

+ (void)postWeddingPlanChangeStatusWithMatterId:(NSString *)matterId andStatus:(int)status withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGPLANCHANGESTATUS
                                 parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
                                              @"matter_status" : @(status),
                                              @"matter_id":matterId}
                                  withBlock:block];
}


+ (void)postWeddingPlanDelegateWithMatterId:(NSString *)matterId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGPLANDELEGATE
                                 parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
                                              @"matter_id":matterId}
                                  withBlock:block];
}

+ (void)postSetWeddingTime:(int64_t)weddingTime WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGSETTIME
                                 parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
                                              @"wedding_time":@(weddingTime)}
                                  withBlock:block];
}

//Log
+ (void)postAccessLogWithServiceID:(WTWeddingType)serviceType andCityID:(NSString *)cityID andID:(NSString *)ID andLogType:(WTLogType)logType
{
	if( logType == WTLogTypeNone || logType == WTLogTypeSupplier || logType == WTLogTypePost )
	{
		NSDictionary *params = @{@"uid":[UserInfoManager instance].userId_self ? : @"",
							 @"city_id": cityID ? : @([UserInfoManager instance].curCityId),
							 @"su_id":ID ? : @"",
							 @"service_id":@(serviceType),
							 @"last_page":@(logType)};
		[[NetworkManager sharedClient] postPath:APIACCESSLOG parameters:params
									  withBlock:^(NSDictionary *result, NSError *error) {

									  }];
	}
	else if(logType == WTLogTypeADs)
	{
		[[NetworkManager sharedClient] postPath:APIADSACESSLOG parameters:@{@"ads_id":ID ?: @"" }
									  withBlock:^(NSDictionary *result, NSError *error) {

									  }];
	}
}

/*
//婚礼订单
+ (void)postOrderRefunChild_order_no:(NSString *)child_order_no reason:(NSString *)reason withBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSDictionary *params = @{
							 @"token" : [UserInfoManager instance].tokenId_self,
							 @"child_order_no" : child_order_no,
							 @"refund_reason" : [LWUtil getString:reason andDefaultStr:@""]
							 };
	[[NetworkManager sharedClient] postPath:APIORDERREFUND parameters:params withBlock:block];
}

+ (void)postOrderCancelChild_order_no:(NSString *)child_order_no withBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSDictionary *params = @{
							 @"token" : [UserInfoManager instance].tokenId_self,
							 @"child_order_no" : child_order_no,
							 };
	[[NetworkManager sharedClient] postPath:APIORDERCANCEL parameters:params withBlock:block];
}

+ (void)postOrderCancelOut_trade_no:(NSString *)out_trade_no child_trade_no:(NSString *)child_order_no WithBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSDictionary *params;
	if ([child_order_no isNotEmptyCtg]) {
		params = @{
				   @"token" : [UserInfoManager instance].tokenId_self,
				   @"child_order_no" : child_order_no
				   };
	} else {
		params = @{
				   @"token" : [UserInfoManager instance].tokenId_self,
				   @"out_trade_no" : out_trade_no,
				   };

	}
	[[NetworkManager sharedClient] postPath:APIORDERCANCEL parameters:params withBlock:block];
}

+ (void)postReserveSupplier_id:(NSNumber *)supplier_id
				  order_source:(NSNumber *)order_source
				 weddingCityId:(NSString *)city_id
						  time:(int64_t)time
					 source_id:(NSNumber *)source_id
					 WithBlock:(void (^)(NSDictionary *, NSError *))block
{
	NSNumber *post_id = source_id ? : supplier_id ;
	NSDictionary *dic = @{
						  @"token" : [UserInfoManager instance].tokenId_self,
						  @"supplier_user_id":[LWUtil getString:supplier_id andDefaultStr:@""],
						  @"order_source":order_source,
						  @"wedding_city" : city_id,
						  @"wedding_timestamp":@(time),
						  @"source_id":post_id
						  };
	[[NetworkManager sharedClient] postPath:APIWEDDINGRESERVE parameters:dic withBlock:block];
}

*/

+ (void)postAlipayParamsWithChild_trade_no:(NSString *)child_trade_no withBlock:(void(^)(NSDictionary *,NSError *))block
{

	NSDictionary *params = @{@"token" : [UserInfoManager instance].tokenId_self,
							 @"child_order_no" : child_trade_no};
	[[NetworkManager sharedClient] postPath:APIAPLIPAYPARAMETER
								 parameters:params
								  withBlock:block];
}
@end
