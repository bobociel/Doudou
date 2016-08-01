//
//  GetListService.m
//  lovewith
//
//  Created by imqiuhang on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "GetService.h"
#import "UserInfoManager.h"
#import "SliderListVCManager.h"
#define APIQINIUTOKEN                      @"/app/v020/qiniu/token"

#define APIDEMANDLIST                      @"app/v020/reward/list/user"//需求列表
#define APIPRICERANGE                      @"/app/v020/reward/price"//价格列表
#define APIDEMANDETAIL                     @"app/v020/reward/detail"//需求详情
#define APIREWARDBIDS                      @"app/v020/reward/bids" //获取需求投标记录
#define APIREWARDSELECT                    @"app/v020/reward/select"//需求选标
#define APIREWARDCLOSE                     @"app/v020/reward/close"//关闭需求
//#define APIINSPIRATIONDEFAULTTAG           @"/app/v020/default/tag"
#define APIINSPIRATIONDEFAULTTAG           @"/app/v020/default/tag"

#define APISEARCHINSPIRETIONWITHTAG        @"/app/v020/search/tag"
#define APISEARCHINSPIRETIONWITHCOLOR      @"/app/v020/search/color"
#define APISEARCHHOTEL                     @"/app/v020/search/hotel"
#define APISEARCHSUPPLIER                  @"/app/v020/search/supplier"

#define APIUSERCENTER                      @"app/v020/u/center/profile/get/"
#define APILIKELIST                        @"/app/v020/follow/list" //喜欢列表

//发现
#define APIFINDLIST                        @"/app/v020/discover/getlist/"
//服务商详情
#define APISUPPLIERDETAIL                  @"/app/v020/supplier/detail"
#define APIHOTELDETAIL                     @"/app/v020/hotel/detail"
#define APISUPPLIERLIST                    @"/app/v020/filter/supplier/"
#define APIHOTELLIST                       @"app/v020/filter/hotel/"

#define APICITYLIST                        @"/app/v020/default/city/"
#define APIWORKSDETAIL                     @"app/v020/supplier/post/detail"
#define APIBALLROOMDETAIL                  @"app/v020/hotel/ballroom/detail"
#define APIMEALDETAIL                      @"app/v020/hotel/menu/detail"


#define APIGETCHATLISTDATA                 @"/app/v010/channel/"
#define APIORDERLIST                       @"app/v020/order/list"
#define APIORDERDETAIL                     @"app/v020/order/detail"

//婚礼主页
#define APIWEDDINGHOMEUPDATEINFOMATION @"/app/v020/u/update_home_page/"//   更新婚礼主页资料
#define APIWEDDINGHOMEPAGEGETTHEME     @"/app/v020/card/theme_list"
#define APIWEDDINGHOMEPAGEGETSTORYLIST @"/app/v020/card/media_list"
#define APIWEDDINGHOMEPAGETHEMECHOOSE  @"/app/v010/u/get_theme_choice" //获取已选择的主题或者音乐
#define APIWEDDINGHOMEPAGEINVITELIST   @"/app/v020/u/get_invite_list"  //宾客列表
#define getCityIdWithLocation          @"/app/v020/default/locate/"

#define APIWEDDINGHOMEGETBLESSLIST     @"/app/v020/card/bless_list"
#define APIWEDDINGHOMEDELETEBLESS      @"/app/v020/card/del_bless"
#define APIWEDDINGHOMEBLESSCOUNT       @"/app/v020/card/bless_count"

//热门词
#define APIGetHotVip @"/app/v010/default/hotvip"

//婚礼计划
#define APIWEDDINGPLANDETAIL                @"/app/v010/matter/matter_info"
#define APIWEDDINGPLANLIST                  @"/app/v020/matter"

//最新版本信息
#define APIWEDDINGTIMEVERSION               @"/app/v020/version"

@implementation GetService
+ (void)getQiniuTokenWithBucket:(NSString *)bucket  WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIQINIUTOKEN
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"bucket":bucket
                                             }
                                 withBlock:block
                                  useCache:NO];
}


//需求列表
+ (void)getDemandListWithBlock:(void (^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient] getPath:APIDEMANDLIST
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             }
                                 withBlock:block
                                  useCache:NO];
    
}
//需求详情
+ (void)getDemandDetailWithRewardId:(int)rewardId WithBlock:(void (^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient] getPath:APIDEMANDETAIL
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"reward_id":@(rewardId)
                                             }
                                 withBlock:block
                                  useCache:NO];
    
}
//获取需求投标记录
+ (void)getDemandRibedWithRewardId:(int)rewardId WithPage:(int)page WithBlock:(void (^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient] getPath:APIREWARDBIDS
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"reward_id":@(rewardId),
                                             @"page":@(page)
                                             }
                                 withBlock:block
                                  useCache:NO];
    
}

//需求价格列表
+(void)getPriceRangeWithServiceId:(NSString *)serviceId WithBlock:(void(^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient]getPath:APIPRICERANGE parameters:@{
                                                                     @"token":[UserInfoManager instance].tokenId_self,
                                                                     @"service_id":serviceId
                                                                     }
                                withBlock:block
                                 useCache:NO];
}
//需求选标
+(void)getRewardSelectWithRewardId:(int)rewardId WithSupplierId:(int)supplierId WithBlock:(void(^)(NSDictionary *result, NSError *error))block{
    [[NetworkManager sharedClient]getPath:APIREWARDSELECT parameters:@{
                                                                       @"token":[UserInfoManager instance].tokenId_self,
                                                                       @"reward_id":@(rewardId),
                                                                       @"supplier_id":@(supplierId)
                                                                       }
                                withBlock:block
                                 useCache:NO];
}
//关闭需求
+(void)getRewardCloseWithRewardId:(int)rewardId WithBlock:(void(^)(NSDictionary *result, NSError *error))block{
    [[NetworkManager sharedClient]getPath:APIREWARDCLOSE parameters:@{
                                                                      @"token":[UserInfoManager instance].tokenId_self,
                                                                      @"reward_id":@(rewardId),
                                                                      }
                                withBlock:block
                                 useCache:NO];
}



//灵感
+ (void)getInspiretionDefaultTagWithBlock:(void (^)(NSDictionary *, NSError *))block {
    //todo灵感接口
    [[NetworkManager sharedClient] getPath:APIINSPIRATIONDEFAULTTAG
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self
                                             }
                                 withBlock:block
                                  useCache:NO];
}

+ (AFHTTPRequestOperation *)getSearchInspiretionTagWithPage:(int)page andtag:(NSString *)qTag WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
    return [[NetworkManager sharedClient] getPath:APISEARCHINSPIRETIONWITHTAG
                                        parameters:@{
                                                     @"page" : @(page),
                                                     @"token" : [UserInfoManager instance].tokenId_self,
                                                     @"q" : qTag?qTag:@"婚礼"
                                                     }
                                         withBlock:block
                                          useCache:NO];
}

+ (AFHTTPRequestOperation *)getSearchInspiretionColorWithPage:(int)page andColor:(NSString *)qColor WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
    return [[NetworkManager sharedClient] getPath:APISEARCHINSPIRETIONWITHCOLOR
                                       parameters:@{
                                                    @"page" : @(page),
                                                    @"token" : [UserInfoManager instance].tokenId_self,
                                                    @"q" : qColor?qColor:@""
                                                    }
                                        withBlock:block
                                         useCache:NO];
}

//搜索
+ (AFHTTPRequestOperation *)getSearchHotelWithPage:(int)page
                          andQ:(NSString *)qStr
                     WithBlock:
(void (^)(NSDictionary *result, NSError *error))block {
   return [[NetworkManager sharedClient] getPath:APISEARCHHOTEL
                                parameters:@{
                                             @"page" : @(page),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"q" : qStr
                                             }
                                 withBlock:block
                                  useCache:NO];
}

+ (AFHTTPRequestOperation *)getSearchSupplierWithPage:(int)page
                             andQ:(NSString *)qStr
                        WithBlock:(void (^)(NSDictionary *result,
                                            NSError *error))block {
   return [[NetworkManager sharedClient] getPath:APISEARCHSUPPLIER
                                parameters:@{
                                             @"page" : @(page),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"q" : qStr
                                             }
                                 withBlock:block
                                  useCache:NO];
}


//喜欢列表
+ (void)getLikeListWithTypeId:(int)typeId
                      andPage:(int)page
                    WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APILIKELIST
                                parameters:@{
                                             @"page" : @(page),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"type_id" : @(typeId)
                                             }
                                 withBlock:block
                                  useCache:NO];
}


//个人信息
+ (void)getUserCenterWithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params = @{@"user":[UserInfoManager instance].tokenId_self,};
    [[NetworkManager sharedClient] getPath:APIUSERCENTER parameters:params withBlock:block
                                  useCache:YES];
}

// 服务商详情
+ (void)getSupplierDetailWithId:(NSNumber *)supplierId WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params = @{
                             @"supplier_user_id" : supplierId,
                             @"token" :[UserInfoManager instance].tokenId_self
                             };
    [[NetworkManager sharedClient] getPath:APISUPPLIERDETAIL parameters:params withBlock:block useCache:NO];

}
+ (void)getFindListWithCount:(NSUInteger)count CityId:(NSString *)city WithifUpDrag:(BOOL)ifUpDrag model:(FindItemModel *)model WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params;
    if (count == 0) {
        params = @{
                   @"city_id" : city,
                   };
    } else if(ifUpDrag == YES){
        
        params = @{
                   @"end" : [NSNumber numberWithLongLong:model.update_time],
                   @"city_id" : city,
                   };
        ifUpDrag = NO;
        
    } else {
        
        params = @{
                   @"since" : [NSNumber numberWithLongLong:model.update_time],
                   @"city_id" : city,
                   };
    }
    
    [[NetworkManager sharedClient] getPath:APIFINDLIST parameters:params withBlock:block useCache:NO];
}

+ (void)getHotelDetailWithId:(NSNumber *)hotelId WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"hotel_id" : hotelId,
                             };
    [[NetworkManager sharedClient] getPath:APIHOTELDETAIL parameters:params withBlock:block useCache:YES];
}

+ (void)getSupplierListWithSupplier_id:(int)supplier_id page_no:(int)page city_id:(NSNumber *)city_id syn_id:(NSString *)syn_id Block:(void (^)(NSDictionary *,NSError *))block
{
    NSNumber *supplierId = [NSNumber numberWithInt:supplier_id];
    NSNumber *page_no = [NSNumber numberWithInt:page];
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"service" : supplierId,
                             @"page" : page_no,
                             @"city_id" : city_id,
                             @"order_field" :syn_id,
                             };
    
    
    [[NetworkManager sharedClient] getPath:APISUPPLIERLIST parameters:params withBlock:block useCache:NO];
    
}

+ (void)getHotelListWithPage:(int)page
         andHotelListFilters:(HotelOrSupplierListFilters *)hotelListFilters
                   WithBlock:(void (^)(NSDictionary *, NSError *))block {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:15];
    parameters[@"page"]=@(page);
    parameters[@"token"]=[UserInfoManager instance].tokenId_self;
    if (hotelListFilters.isFromFilters) {
        if (hotelListFilters.city_id>=0) {
            parameters[@"city_id"] = @(hotelListFilters.city_id);
        }
        
        if ([hotelListFilters.order_field isNotEmptyCtg]) {
            parameters[@"order_field"]=hotelListFilters.order_field;
        }
        
        if (hotelListFilters.hotel_type>=0) {
            parameters[@"hotel_type"]=@(hotelListFilters.hotel_type);
            //            parameters[@"hotel_type"] = [NSArray arrayWithArray:hotelListFilters.hotel_types];
        }
        
        if (hotelListFilters.price_start>=0) {
            parameters[@"price_start"]=@(hotelListFilters.price_start);
        }
        
        if (hotelListFilters.price_end>=0) {
            parameters[@"price_end"]=@(hotelListFilters.price_end);
        }
        
        if (hotelListFilters.desk_start>=0) {
            parameters[@"desk_start"]=@(hotelListFilters.desk_start);
        }
        
        if (hotelListFilters.desk_end>=0) {
            parameters[@"desk_end"]=@(hotelListFilters.desk_end);
        }
        
        if ([hotelListFilters.key_word isNotEmptyCtg]) {
            //            parameters[@"key_word"] = [NSArray arrayWithArray:hotelListFilters.key_words];
            parameters[@"key_word"] = hotelListFilters.key_word;
        }
    }

    [[NetworkManager sharedClient] getPath:APIHOTELLIST
                                parameters:[parameters copy]
                                 withBlock:block
                                  useCache:NO];
}


+ (void)getCityListWithBlock:(void (^)(NSDictionary *,NSError *))block
{
    [[NetworkManager sharedClient] getPath:APICITYLIST parameters:nil withBlock:block useCache:YES];
}

+ (void)getWorkDetailWithPostId:(NSNumber *)post_id Block:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" :[UserInfoManager instance].tokenId_self,
                             @"post_id" : post_id,
                             };
    [[NetworkManager sharedClient] getPath:APIWORKSDETAIL parameters:params withBlock:block useCache:YES];
}

+ (void)getBanquetWithballroomId:(NSNumber *)ballroom_id Block:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"ballroom_id" : ballroom_id,
                             };
    [[NetworkManager sharedClient] getPath:APIBALLROOMDETAIL parameters:params withBlock:block useCache:YES];
}
+ (void)getMealDetailWithMealId:(NSNumber *)meal_id Block:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"menu_id" : meal_id,
                             };
    [[NetworkManager sharedClient] getPath:APIMEALDETAIL parameters:params withBlock:block useCache:YES];
}


+ (void)getChatListMsg:(NSString *)channels
             withBlock:(void (^)(NSDictionary *, NSError *))block
{
    [[NetworkManager sharedClient] postPath:APIGETCHATLISTDATA
								 parameters:@{
											  @"channels" : channels,
											  @"token" : [UserInfoManager instance].tokenId_self
											  }
								  withBlock:block];
}

+ (void)getOrderListWithBlcok:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             };
    [[NetworkManager sharedClient] getPath:APIORDERLIST parameters:params withBlock:block useCache:NO];
}




+ (void)getOrderDetailWithOrder_id:(NSString *)order_id Blcok:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"out_trade_no" : order_id,
                             };
    [[NetworkManager sharedClient] getPath:APIORDERDETAIL parameters:params withBlock:block useCache:NO];
}

+ (void)getHomePageThemeWithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIWEDDINGHOMEPAGEGETTHEME
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self}
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getHomepageThemeChoosedWithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIWEDDINGHOMEPAGETHEMECHOOSE
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self}
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getHomePageStoryWithPage:(NSInteger)page andMediaType:(NSString *)mediaType WithBlock:(void (^)(NSDictionary *, NSError *))block {
	[[NetworkManager sharedClient] postPath:APIWEDDINGHOMEPAGEGETSTORYLIST
                                 parameters:@{@"page":@(page),@"token":[UserInfoManager instance].tokenId_self,@"media_type":mediaType}
                                  withBlock:block];
}

+ (void)getHomePageInviteListWithPage:(int)page type:(NSInteger)type WithBlock:(void (^)(NSDictionary *, NSError *))block {
    NSDictionary *dic=@{};
    if (type==2) {
        dic=@{
              @"page" : @(page),
              @"token" : [UserInfoManager instance].tokenId_self,
              };
    }
    else
    {
        dic=@{
              @"page" : @(page),
              @"token" : [UserInfoManager instance].tokenId_self,
              @"is_part":@(type)
              };
    }
    [[NetworkManager sharedClient] getPath:APIWEDDINGHOMEPAGEINVITELIST
                                parameters:dic
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getBlessListWithPage:(NSInteger)page WithBlock:(void(^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGHOMEGETBLESSLIST
								parameters:@{@"page":@(page),@"token":TOKEN}
								 withBlock:block
								  useCache:NO];
}

+ (void)deleteBlessWith:(NSString *)blessID withBlock:(void(^)(NSDictionary *result,NSError *error))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGHOMEDELETEBLESS
								parameters:@{@"bless_id":blessID,@"token":TOKEN}
								 withBlock:block
								  useCache:NO];
}

+ (void)getBlessCountWithBlock:(void(^)(NSDictionary *result,NSError *error))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGHOMEBLESSCOUNT
								parameters:@{@"token":TOKEN}
								 withBlock:block useCache:NO];
}


+ (void)getCityidWithLon:(float)lon andLat:(float)lat WithBlock:(void (^)(NSDictionary *, NSError *))block{
    [[NetworkManager sharedClient] getPath:getCityIdWithLocation
                                parameters:@{
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"location":[NSString stringWithFormat:@"%f,%f",lon,lat]
                                             }
                                 withBlock:block
                                  useCache:NO];
}

//获取热门词
+(void)getHotVipWithCityid:(int)cityid withBlock:(void(^)(NSDictionary *,NSError *))block{
    
    [[NetworkManager sharedClient]getPath:APIGetHotVip parameters:@{
                                                                    @"token":[UserInfoManager instance].tokenId_self,
                                                                    @"city_id" :@(cityid)
                                                                    }
                                withBlock:block useCache:NO];
    
}

//婚礼计划
+ (void)getWeddingPlanListWithStatus:(int)status
							 andPage:(int)page
                           WithBlock:(void (^)(NSDictionary *, NSError *))block {
    NSDictionary *dic=@{};
    if(status==0)
    {
        dic=@{@"page" : @(page),@"token" : [UserInfoManager instance].tokenId_self,};
    }
    else
    {
        dic=@{
              @"page" : @(page),
              @"token" : [UserInfoManager instance].tokenId_self,
              @"status":@(status),
              };
    }
    [[NetworkManager sharedClient] getPath:APIWEDDINGPLANLIST
                                parameters:dic
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getWeddingDetailWithId:(int)status
					 WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIWEDDINGPLANDETAIL
                                parameters:@{
                                             @"matter_id" : @(status),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             }
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getWeddingTimeVersionInfoWithBlock:(void (^)(NSDictionary *result,NSError *error))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGTIMEVERSION parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

@end
