//
//  PostDataService.m
//  lovewith
//
//  Created by imqiuhang on 15/4/20.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "PostDataService.h"
#define APIDEMAND @"app/v020/reward/new"
#define APIINSPIPATIONLIKE                 @"/app/v010/follow/add_follow"

#define APIWEDDINGHOMEUPDATEINFOMATION @"/app/v020/u/center/home/profile/"//   更新婚礼主页资料

#define APIsend_sms @"/app/v010/u/send_sms"

//个人中心
#define APIUSERCENTER @"app/v020/u/center/profile/get/"

#define APILIKECANCEL                      @"/app/v010/su/like"// todo
#define APILIKECANCELHOTEL                 @"/app/v010/hotel/like"


//婚礼主页
//@"/app/v010/u/update_story"
#define APIWEDDINGHOMEPAGEGETSTORYUpadate   @"/app/v020/card/upload_image" 
#define APIWEDDINGHOMEPAGEGETVIDEOSTORYUpdate @"/app/v020/card/upload_video"
#define APIWEDDINGHOMEPAGESTORYDELETE      @"/app/v020/card/del_media"
#define APIWEDDINGHOMEPAGESTORYMODIFY		@"/app/v020/card/edit_media"
#define APIWEDDINGHOMEPAGESTORYChangeSort  @"/app/v020/card/card_sort"
#define APIUPDATEHOMEPAGEBACKGROUD         @"/app/v020/card/background"
#define APIWEDDINGHOMEPAGESTROYCHOODEMUSIC @"/app/v020/card/set_theme"
#define APIORDERREFUND                     @"/app/v020/order/refund"
#define APIORDERCANCEL                     @"app/v020/order/cancel"

//PLAN
#define APIWEDDINGPLANAdd                  @"/app/v010/matter/add_matter"
#define APIWEDDINGPLANCHANGESTATUS         @"/app/v010/matter/change_matter"
#define APIWEDDINGPLANDELEGATE             @"/app/v010/matter/delete_matter"
#define APIWEDDINGSETTIME                  @"/app/v010/u/wedding/set_time"
#define APIWEDDINGRESERVE                  @"app/v020/order/reserve"
//支付宝参数
#define APIAPLIPAYPARAMETER                @"/app/v020/order/pay"

//
#define APICHATONLINEGET                  @"/1.1/rtm/online"
#define APIPOSTMSG                        @"/1.1/rtm/messages"

@implementation PostDataService
+ (void)postDemandWithServiceType:(NSString *)serviceType
                   andPriceRange:(NSString *)priceRange
                   andWeddingTime:(NSString *)weddingTime
                   andCity:(NSString *)city
                   andNote:(NSString *)notes
                             withBlock:
(void (^)(NSDictionary *, NSError *))block {
    NSLog(@"%@",[UserInfoManager instance].tokenId_self);
    [[NetworkManager sharedClient] postPath:APIDEMAND
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"service" : serviceType,
                                              @"price_range":priceRange,
                                              @"wedding_time" : weddingTime,
                                              @"city" : city,
                                              @"content":notes
                                              }
                                  withBlock:block];
}

+ (void)postInspirationLikeWithImageId:(int)imageId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIINSPIPATIONLIKE parameters:@{@"token":[UserInfoManager instance].tokenId_self,@"image_id":@(imageId)} withBlock:block];
}
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
          NSError *))block {
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    parameter[@"token"]=[UserInfoManager instance].tokenId_self;
    
    if ([name isNotEmptyCtg]) {
        parameter[@"name"] = name;
    }
    if ([lname isNotEmptyCtg]) {
        parameter[@"lover"] = lname;
    }
    if (role!=UserGenderUnknow) {
        parameter[@"role"] = role==UserGenderMale?@"m":@"f";
    }
    if (time>0) {
        parameter[@"wedding_timestamp"] = @(time);
    }
    if ([domain isNotEmptyCtg]) {
        parameter[@"domain"] = domain;
    }
    if ([address isNotEmptyCtg]) {
        parameter[@"wedding_address"] = address;
    }
	if([point isNotEmptyCtg]){
		NSArray *mapPoint = [point componentsSeparatedByString:@","];
		parameter[@"wedding_map_point"] = [NSString stringWithFormat:@"%@,%@",mapPoint[1],mapPoint[0]];
	}

    if ([myavataKey isNotEmptyCtg]) {
        parameter[@"my_avatar"] = myavataKey;
    }
    
    if (partnerAvataKey) {
        parameter[@"lover_avatar"] = partnerAvataKey;
    }
    
    [[NetworkManager sharedClient] postPath:APIWEDDINGHOMEUPDATEINFOMATION
                                 parameters:[parameter copy]
                                  withBlock:block];
    
}

//个人信息
+ (void)postUserCenterWithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params = @{@"token":[UserInfoManager instance].tokenId_self};
    [[NetworkManager sharedClient] postPath:APIUSERCENTER parameters:params withBlock:block];
}

+ (void)postSend_smsTellSupplier:(NSString *)Supplier withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIsend_sms
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"sms_type":@(0),
                                              @"supplier_user_id":Supplier,
                                              }
                                  withBlock:block];
}

+ (void)postLikeWithService_id:(NSNumber *)service_id Block:(void (^)(NSDictionary *restult,NSError *error))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"user_id" : service_id,
                             };
    [[NetworkManager sharedClient] postPath:APILIKECANCEL parameters:params withBlock:block];
}
//婚礼主页
+ (void)postWeddingHomeUpadateStoryWithStory:(WTWeddingStory *)story orStorys:(NSArray *)storys withBlock:(void(^)(NSDictionary *,NSError *error))block
{
	NSString	*urlPath = @"";
	NSMutableDictionary *storyDict = [NSMutableDictionary dictionary];
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
	
    [[NetworkManager sharedClient] postPath:urlPath
                                 parameters:storyDict
                                  withBlock:block];
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

+ (void)POSTWeddingHomeChooseMusic:(NSString *)theme_type andId:(int)musicId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGESTROYCHOODEMUSIC
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"theme_type":theme_type,
                                              @"id":@(musicId)
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
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"id":@(storyId)
                                              }
                                  withBlock:block];
    

}

+ (void)postLikeWithHotel_id:(NSNumber *)hotel_id Block:(void (^)(NSDictionary *restult,NSError *error))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"hotel_id" : hotel_id,
                             };
   [[NetworkManager sharedClient] postPath:APILIKECANCELHOTEL parameters:params withBlock:block];
}
+ (void)postOrderRefunChild_order_no:(NSString *)child_order_no reason:(NSString *)reason withBlock:(void (^)(NSDictionary *, NSError *))block
{
    if (!reason) {
        reason = @"";
    }
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"child_order_no" : child_order_no,
                             @"refund_reason" : reason
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

+ (void)postWeddingPlanInfoWithMatterId:(int)matterId
                               andTitle:(NSString *)title
                         andDescription:(NSString *)description
                           andCloseTime:(int64_t)closeTime
                          andRemindTime:(int64_t)remindTime
                              withBlock:
(void (^)(NSDictionary *, NSError *))block {
    NSDictionary *parameters = @{
                                 @"token" : [UserInfoManager instance].tokenId_self,
                                 @"matter_title" : title,
                                 @"matter_description":description,
                                 @"matter_close_time":@(closeTime)
                                 };
    NSMutableDictionary *muPa = [parameters mutableCopy];
    if (matterId>=0) {
        [muPa setObject:@(matterId) forKey:@"matter_id"];
    }
    if (remindTime>=0) {
        [muPa setObject:@(remindTime) forKey:@"matter_remind_time"];
    }
    
    
    [[NetworkManager sharedClient] postPath:APIWEDDINGPLANAdd
                                 parameters:[muPa copy]
                                  withBlock:block];
    
    
}

+ (void)postWeddingPlanChangeStatusWithMatterId:(int)matterId andStatus:(int)status withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGPLANCHANGESTATUS
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"matter_status" : @(status),
                                              @"matter_id":@(matterId)
                                              }
                                  withBlock:block];
    
    
}


+ (void)postWeddingPlanDelegateWithMatterId:(int)matterId withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGPLANDELEGATE
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"matter_id":@(matterId)
                                              }
                                  withBlock:block];
    
    
}

+ (void)postSetWeddingTime:(int64_t)weddingTime
                 WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIWEDDINGSETTIME
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"wedding_time":@(weddingTime)
                                              }
                                  withBlock:block];
}

+ (void)postReserveSupplier_id:(NSNumber *)supplier_id order_source:(NSNumber *)order_source weddingCityId:(NSString *)city_id time:(int64_t)time type:(NSInteger)type source_id:(NSNumber *)source_id WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSNumber *post_id;
    if (type == 0) {
        post_id = supplier_id;
    } else {
        post_id = source_id;
    }
    NSDictionary *dic = @{
                          @"token" : [UserInfoManager instance].tokenId_self,
                          @"supplier_user_id":[LWUtil getString:supplier_id andDefaultStr:@""],
                          @"order_source":order_source,
                          @"wedding_city" : city_id,
                          @"wedding_timestamp":@(time),
                          @"source_id":post_id
                          };
    [[NetworkManager sharedClient] postPath:APIWEDDINGRESERVE
                                 parameters:dic
                                  withBlock:block];
}


+ (void)postAlipayParamsWithChild_trade_no:(NSString *)child_trade_no withBlock:(void(^)(NSDictionary *,NSError *))block
{
    
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"child_order_no" : child_trade_no
                             };
    [[NetworkManager sharedClient] postPath:APIAPLIPAYPARAMETER
                                 parameters:params
                                  withBlock:block];
//    NSDictionary *params = @{
//                             @"token" : [UserInfoManager instance].tokenId_self,
//                             @"child_order_no" : child_trade_no
//                             };
//    [[NetworkManager sharedClient] getPath:APIAPLIPAYPARAMETER parameters:params withBlock:block useCache:NO];
}

//聊天
+ (void)postChatOnlineStatus:(NSArray *)peers WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *dic = @{
                          @"peers" : peers,
                          };
    NSData *data=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * URLString = [NSString stringWithFormat:@"%@%@",AVIMHOST,APICHATONLINEGET];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setValue:AVOSAPPID forHTTPHeaderField:@"X-LC-Id"];
    [request setValue:[NSString stringWithFormat:@"%@,master",AVOSMasterKey]  forHTTPHeaderField:@"X-LC-Key"];
    [request setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:URL]; //设置请求的地址
//    [request setHTTPBody:postData];  //设置请求的参数
    [request setHTTPBody:data];  //设置请求的参数
    
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error) {
        NSLog(@"error : %@",[error localizedDescription]);
         block(nil,error);
    }else{
        NSDictionary *myDictionary =  [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingAllowFragments error:nil];
        
        block(myDictionary,nil);
        NSLog(@"response : %@",response);
        NSLog(@"backData : %@",[[NSString alloc]initWithData:backData encoding:NSUTF8StringEncoding]);
    }
}

+ (void)postSendOnlineStatusMsg:(NSString*)conversationId unread:(int)unread uid:(NSString*)uid uname:(NSString*)uname suid:(NSString*)suid suname:(NSString*)suname WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    //#define AVOSAPPID       @"o8fvolewsx4ffj5gprqaavv1ukcbkyhbn109hgx8hgqw6v7x"
    //#define AVOSAPPKEY      @"o3h7p3peausargci68r2ojjidztcoyyzz07qkurtnezmcf8p"
    NSDictionary*conversationInfo=@{
                                    @"unread": @(unread),//为读数
                                    
                                    @"uid": uid,//用户id
                                    
                                    @"uname":uname , //用户名
                                    
                                    @"suid": suid,//商户用户id

                                    @"suname": suname ,   //商户用户名
                                    };
    
    NSDictionary *textDic=@{
                         conversationId:conversationInfo,
                             };
    
    NSDictionary *messageDic=@{
                               @"_lctype":@(-1),
                               @"text":textDic,
                                   };
    NSDictionary *dic = @{
                          @"conv_id" : AVIMSERVERCONVERSATIONID,
                          @"from_peer" : @"chatManage",
                          @"transient" : @(false),
                          @"message" : messageDic,
                          };
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * URLString = [NSString stringWithFormat:@"%@%@",AVIMHOST,APIPOSTMSG];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    [request setValue:AVOSAPPID forHTTPHeaderField:@"X-LC-Id"];
    [request setValue:[NSString stringWithFormat:@"%@,master",AVOSMasterKey]  forHTTPHeaderField:@"X-LC-Key"];
    [request setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"post"]; //指定请求方式
    [request setURL:URL]; //设置请求的地址
    //    [request setHTTPBody:postData];  //设置请求的参数
    [request setHTTPBody:data];  //设置请求的参数
    
    NSURLResponse * response;
    NSError * error;
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error : %@",[error localizedDescription]);
        block(nil,error);
    }else{
        NSDictionary *myDictionary =  [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingAllowFragments error:nil];
        
        block(myDictionary,nil);
        NSLog(@"response : %@",response);
        NSLog(@"backData : %@",[[NSString alloc]initWithData:backData encoding:NSUTF8StringEncoding]);
    }
}
@end
