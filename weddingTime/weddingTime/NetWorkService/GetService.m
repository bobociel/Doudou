//
//  GetListService.m
//  lovewith
//
//  Created by imqiuhang on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "GetService.h"
#import "UserInfoManager.h"
#define APIQINIUTOKEN                      @"/app/v020/qiniu/token"         //七牛token
//用户相关
#define APILIKELIST                        @"/app/v020/follow/list"          //用户喜欢列表
#define getCityIdWithLocation              @"/app/v020/default/locate/"      //定位用户城市
#define APIWEDDINGBUDGET                   @"/app/v021/u/budget"             //设置用户预算

//发现,服务商,作品,灵感以及搜索
#define APIFINDLIST                        @"/app/v020/discover/getlist/"   //发现列表

#define APISUPPLIERLIST                    @"/app/v022/filter/supplier"     //商家列表(筛选)
#define APIPOSTLIST                        @"/app/v022/default/posts"       //作品列表(筛选)
#define APIHOTELLIST                       @"/app/v020/filter/hotel/"       //酒店列表(筛选)
#define APIINSPIRATIONDEFAULTTAG           @"/app/v020/default/tag"         //灵感分类

#define APISUPPLIERDETAIL                  @"/app/v020/supplier/detail"     //商家详情
#define APIHOTELDETAIL                     @"/app/v020/hotel/detail"        //酒店详情
#define APIWORKSDETAIL                     @"/app/v020/supplier/post/detail/v2" //作品详情
#define APIBALLROOMDETAIL                  @"/app/v020/hotel/ballroom/detail"   //酒店宴会厅详情
#define APIMEALDETAIL                      @"/app/v020/hotel/menu/detail"       //酒店套餐详情

#define APISEARCHHOTEL                     @"/app/v020/search/hotel"        //酒店搜索
#define APISEARCHSUPPLIER                  @"/app/v020/search/supplier"     //商家搜索
#define APISEARCHINSPIRETIONWITHTAG        @"/app/v020/search/tag"          //灵感列表(标签搜索)
#define APISEARCHINSPIRETIONWITHCOLOR      @"/app/v020/search/color"        //灵感列表(颜色搜索)

#define APIGetHotVip                       @"/app/v010/default/hotvip"  //热门词
#define APICITYLIST                        @"/app/v020/default/city/"   //选择城市列表
#define APIALLCITYLIST                     @"/app/v021/site/city"       //所有城市列表
//婚礼主页
#define APIWEDDINGHOMEUPDATEINFOMATION @"/app/v020/u/update_home_page/" //婚礼请柬，更新用户信息
#define APIWEDDINGHOMEPAGEGETTHEME     @"/app/v020/card/theme_list"     //婚礼请柬，主题列表
#define APIWEDDINGHOMEPAGEGETSTORYLIST @"/app/v020/card/media_list"     //婚礼请柬，音乐列表
#define APIWEDDINGHOMEPAGETHEMECHOOSE  @"/app/v010/u/get_theme_choice"  //婚礼请柬，获取已选择的主题或者音乐(用于分享)
#define APIWEDDINGHOMEGETBLESSLIST     @"/app/v020/card/bless_list"     //婚礼请柬，祝福列表
#define APIWEDDINGHOMEDELETEBLESS      @"/app/v020/card/del_bless"      //婚礼请柬，删除祝福
#define APIWEDDINGHOMEBLESSCOUNT       @"/app/v020/card/bless_count"    //婚礼请柬，获得祝福数量
#define APIWEDDINGSHOWPHONE            @"/app/v020/card/contact"        //婚礼请柬，获得新人的联系方式（请柬）
#define APIWEDDINGDESKLIST             @"/app/v020/card/seat_chart/"    //婚礼请柬, 座位列表
#define APIWEDDINGPROCESSLIST          @"/app/v020/card/wedding/process/" //婚礼请柬, 婚礼流程
#define APIWEDDINGCARD                 @"/app/v021/goods"               //婚礼请柬，请柬商店
#define APIWEDDINGHOMEPAGEINVITELIST   @"/app/v020/u/get_invite_list"   //婚礼请柬，宾客列表(暂时不用)
//婚礼宝
#define APIBAOTICKETLIST(ID)     [NSString stringWithFormat:@"/app/v021/u/coupon/su/%@",ID] //婚礼宝商家优惠券列表
#define APIBAOTICKETUERLIST      @"/app/v021/u/coupon/user"                                 //婚礼宝用户优惠券列表
#define APIBAOTICKETWITHDREWLIST @"/app/v021/u/coupon/withdraw/recoder"                //婚礼宝用户已提现有虎泉列表
#define APIBAOTICKETDEATIL(ID)   [NSString stringWithFormat:@"/app/v021/u/coupon/detail/%@",ID]//婚礼宝,优惠券详情
//新娘商店
#define APISHOPLIST               @"/app/v022/default/collection"      //新娘商店,作品列表
//需求
#define APIPRICERANGE             @"/app/v020/reward/price"     //价格列表
#define APIDEMANDLIST             @"/app/v021/reward"           //需求列表
#define APIDEMANDETAIL            @"/app/v021/reward"           //需求详情
#define APIREWARDBIDS(rewardID)   [NSString stringWithFormat:@"/app/v021/reward/%@/bids",rewardID] //需求投标
//婚礼计划
#define APIWEDDINGPLANLIST        @"/app/v020/matter"              //婚礼计划,计划列表
#define APIWEDDINGPLANDETAIL      @"/app/v010/matter/matter_info"  //婚礼计划,计划详情
//获得聊天用户信息
#define APIGETCHATLISTDATA        @"/app/v010/channel/"
//开屏广告
#define APIWEDDINGAD              @"/app/v020/default/banner"
//最新版本信息
#define APIWEDDINGTIMEVERSION     @"/app/v020/version"

//订单
//#define APISUPPLIERLIST         @"/app/v020/filter/supplier/"          //(v0-2.1.1时用) 商家列表(过滤)
//#define APIPOSTLIST             @"/app/v020/default/posts"             //(v0-2.1.1时用) 作品列表(过滤)
//#define APISHOPLIST             @"/app/v020/default/post/collection"   //(v0-2.1.1使用) 新娘商店,作品列表
#define APIORDERLIST              @"app/v020/order/list"                 //订单模块(v1.0-2.0.5使用)
#define APIORDERDETAIL            @"app/v020/order/detail"               //订单模块(v1.0-2.0.5使用)
#define APIREWARDSELECT           @"app/v020/reward/select"              //需求选标(v1.0-2.0.5使用)
#define APIREWARDCLOSE            @"app/v020/reward/close"               //关闭需求(v1.0-2.0.5使用)

@implementation GetService
+ (void)getQiniuTokenWithBucket:(NSString *)bucket  WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIQINIUTOKEN
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
                                             @"bucket":bucket}
                                 withBlock:block
                                  useCache:NO];
}

//需求列表
+ (void)getDemandListWithPage:(NSUInteger)page block:(void (^)(NSDictionary *result, NSError *error))block
{
    [[NetworkManager sharedClient] getPath:APIDEMANDLIST
                                parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
											  @"page":@(page)}
                                 withBlock:block
                                  useCache:NO];
    
}

//需求详情
+ (void)getDemandDetailWithRewardId:(NSString *)rewardId WithBlock:(void (^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient] getPath:[NSString stringWithFormat:@"%@/%@",APIDEMANDETAIL,rewardId]
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self }
                                 withBlock:block
                                  useCache:NO];
    
}
//获取需求投标记录
+ (void)getDemandRibedWithRewardId:(NSString *)rewardId WithPage:(NSInteger)page WithBlock:(void (^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient] getPath:APIREWARDBIDS(rewardId)
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
                                             @"page":@(page)
                                             }
                                 withBlock:block
                                  useCache:NO];
    
}

//需求价格列表
+(void)getPriceRangeWithServiceId:(NSString *)serviceId WithBlock:(void(^)(NSDictionary *result, NSError *error))block{
    
    [[NetworkManager sharedClient]getPath:APIPRICERANGE
							   parameters:@{@"token":[UserInfoManager instance].tokenId_self,
											@"service_id":serviceId}
                                withBlock:block
                                 useCache:NO];
}
//需求选标
+(void)getRewardSelectWithRewardId:(NSString *)rewardId WithSupplierId:(int)supplierId WithBlock:(void(^)(NSDictionary *result, NSError *error))block{
    [[NetworkManager sharedClient]getPath:APIREWARDSELECT
							   parameters:@{
											@"token":[UserInfoManager instance].tokenId_self,
											@"reward_id":rewardId,
											@"supplier_id":@(supplierId)
											}
                                withBlock:block
                                 useCache:NO];
}

//灵感
+ (void)getInspiretionDefaultTagWithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIINSPIRATIONDEFAULTTAG
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self}
                                 withBlock:block
                                  useCache:NO];
}

+ (NSURLSessionDataTask *)getSearchInspiretionTagWithPage:(int)page
													 andtag:(NSString *)qTag
												  WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
    return [[NetworkManager sharedClient] getPath:APISEARCHINSPIRETIONWITHTAG
                                        parameters:@{
                                                     @"page" : @(page),
                                                     @"token" : [UserInfoManager instance].tokenId_self,
                                                     @"q" : qTag?qTag:@"婚礼"
                                                     }
                                         withBlock:block
                                          useCache:NO];
}

+ (NSURLSessionDataTask *)getSearchInspiretionColorWithPage:(int)page
													 andColor:(NSString *)qColor
													WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
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
+ (NSURLSessionDataTask *)getSearchHotelWithPage:(NSInteger)page
                          andQ:(NSString *)qStr
                     WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
   return [[NetworkManager sharedClient] getPath:APISEARCHHOTEL
                                parameters:@{
                                             @"page" : @(page),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"q" : qStr
                                             }
                                 withBlock:block
                                  useCache:NO];
}

+ (NSURLSessionDataTask *)getSearchSupplierWithPage:(NSInteger)page
                             andQ:(NSString *)qStr
                        WithBlock:(void (^)(NSDictionary *result, NSError *error))block {
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
+ (void)getLikeListWithTypeId:(int)typeId andPage:(NSUInteger)page WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APILIKELIST
                                parameters:@{@"page" : @(page),
                                             @"token" : [UserInfoManager instance].tokenId_self,
                                             @"type_id" : @(typeId)}
                                 withBlock:block useCache:NO];
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
        params = @{ @"city_id" : city };
    } else if(ifUpDrag == YES){
        params = @{ @"end" : @(model.update_time), @"city_id" : city};
    } else {
        params = @{@"since" : @(model.update_time), @"city_id" : city};
    }
    
    [[NetworkManager sharedClient] getPath:APIFINDLIST parameters:params withBlock:block useCache:NO];
}

+ (void)getHotelDetailWithId:(NSString *)hotelId WithBlock:(void (^)(NSDictionary *, NSError *))block
{
    NSDictionary *params = @{
                             @"token" : [UserInfoManager instance].tokenId_self,
                             @"hotel_id" : hotelId,
                             };
    [[NetworkManager sharedClient] getPath:APIHOTELDETAIL parameters:params withBlock:block useCache:YES];
}

+ (void)getSupplierListWithSupplierType:(NSInteger)supplierType
								   page:(NSInteger)page
								subpage:(NSInteger)subpage
								 cityID:(NSNumber *)cityID
								  synID:(NSString *)synID
								  Block:(void (^)(NSDictionary *,NSError *))block;
{
    NSMutableDictionary *params = [@{@"token" : [UserInfoManager instance].tokenId_self,
									 @"page" : @(page),
									 @"sub_page" : @(subpage),
									 @"service" : @(supplierType),
									 @"city_id" : cityID,
									 @"order_field" :synID ? : @""} mutableCopy] ;
    [[NetworkManager sharedClient] getPath:APISUPPLIERLIST parameters:params withBlock:block useCache:NO];
    
}

+ (void)getPostListWithSupplierType:(NSInteger)supplierType
							   page:(NSInteger)page
							subpage:(NSInteger)subpage
							 cityID:(NSNumber *)cityID
							  synID:(NSString *)synID
							  price:(NSString *)price
							  Block:(void (^)(NSDictionary *,NSError *))block
{
	NSMutableDictionary *params = [@{@"token" : [UserInfoManager instance].tokenId_self,
									 @"page" : @(page),
									 @"sub_page":@(subpage),
									 @"service" : @(supplierType),
									 @"city_id" : cityID,
									 @"order_field" : synID ? : @"",
									 @"price" : price} mutableCopy];
	
	[[NetworkManager sharedClient] getPath:APIPOSTLIST parameters:params withBlock:block useCache:NO];
}

+ (void)getHotelListWithPage:(NSInteger)page
         andHotelListFilters:(WTHotelFilters *)hotelFilters
                   WithBlock:(void (^)(NSDictionary *, NSError *))block {
    
	NSMutableDictionary *parameters = [hotelFilters modelToJSONObject] ? : [@{} mutableCopy];
	parameters[@"token"]=[UserInfoManager instance].tokenId_self;
    parameters[@"page"]=@(page);
	parameters[@"city_id"] = @([UserInfoManager instance].curCityId);

    [[NetworkManager sharedClient] getPath:APIHOTELLIST parameters:[parameters copy] withBlock:block useCache:NO];
}

+ (void)getCityListWithBlock:(void (^)(NSDictionary *,NSError *))block
{
    [[NetworkManager sharedClient] getPath:APICITYLIST parameters:nil withBlock:block useCache:YES];
}

+ (void)getAllCityWithBlock:(void (^)(NSDictionary *,NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIALLCITYLIST parameters:nil withBlock:block useCache:YES];
}

+ (void)getWorkDetailWithPostId:(NSString *)post_id Block:(void (^)(NSDictionary *,NSError *))block
{
    NSDictionary *params = @{
                             @"token" :[UserInfoManager instance].tokenId_self,
                             @"post_id" : post_id,
                             };
    [[NetworkManager sharedClient] getPath:APIWORKSDETAIL parameters:params withBlock:block useCache:NO];
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
    NSDictionary *dic;
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

+ (void)getCardListWithPage:(NSUInteger)page callback:(void(^)(NSDictionary *result,NSError *eror))callback
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGCARD
								parameters:@{@"token":TOKEN,@"cate_id":@(2)}
								 withBlock:callback useCache:NO];
}

+ (void)getCardDetailWithCardID:(NSString *)cardId callback:(void(^)(NSDictionary *result,NSError *eror))callback
{
	[[NetworkManager sharedClient] getPath:[NSString stringWithFormat:@"%@/%@",APIWEDDINGCARD,cardId]
								parameters:@{@"token":TOKEN}
								 withBlock:callback useCache:NO];
}


+ (void)getCityidWithLon:(float)lon andLat:(float)lat WithBlock:(void (^)(NSDictionary *, NSError *))block{
    [[NetworkManager sharedClient] getPath:getCityIdWithLocation
                                parameters:@{@"token" : [UserInfoManager instance].tokenId_self,
                                             @"location":[NSString stringWithFormat:@"%f,%f",lon,lat]
                                             }
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getShowPhoneWithBlock:(void (^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGSHOWPHONE parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

+ (void)getDeskListWithBlock:(void (^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGDESKLIST parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

+ (void)getProcessListWithBlock:(void (^)(NSDictionary *, NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGPROCESSLIST parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

//BUDGET
+ (void)getBudgetBlock:(void (^)(NSDictionary *, NSError *))block
{
    [[NetworkManager sharedClient] getPath:APIWEDDINGBUDGET parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

//婚礼宝
+ (void)getTicketListWithSID:(NSString *)ID block:(void(^)(NSDictionary *,NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIBAOTICKETLIST(ID) parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

+ (void)getUserTicketListWithPage:(NSInteger)page flag:(NSString *)flag block:(void(^)(NSDictionary *,NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIBAOTICKETUERLIST
								parameters:@{@"token":TOKEN,@"page":@(page),@"flag":flag}
								 withBlock:block
								  useCache:NO];
}

+ (void)getUserWithdrewTicketListBlock:(void(^)(NSDictionary *,NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIBAOTICKETWITHDREWLIST parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

+ (void)getTicketDetailWithTicketID:(NSString *)ID block:(void(^)(NSDictionary *,NSError *))block
{
	[[NetworkManager sharedClient] getPath:APIBAOTICKETDEATIL(ID) parameters:@{@"token":TOKEN} withBlock:block useCache:NO];
}

//新娘商店
+ (void)getShopListWithType:(WTWeddingType)type andPage:(NSInteger)page andSubpage:(NSInteger)subpage andCityID:(NSString *)ID block:(void(^)(NSDictionary *,NSError *))block
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"token"] = [UserInfoManager instance].tokenId_self;
	params[@"city"] = ID;
	params[@"page"] = @(page);
	params[@"sub_page"] = @(subpage);
	if(type == WTWeddingTypeShopMain){
		params[@"service"] = @(0);
		[[NetworkManager sharedClient] getPath:APISHOPLIST parameters:params withBlock:block useCache:NO];
	}else{
		params[@"service"] = @(type);
		[[NetworkManager sharedClient] getPath:APISHOPLIST parameters:params withBlock:block useCache:NO];
	}
}

+ (void)getShopDetailWithID:(NSString *)ID Block:(void(^)(NSDictionary *,NSError *))block
{
	NSDictionary *params = @{@"token" :[UserInfoManager instance].tokenId_self,
							 @"post_id" : ID,
							 };
	[[NetworkManager sharedClient] getPath:APIWORKSDETAIL parameters:params withBlock:block useCache:NO];
}

//获取热门词
+(void)getHotVipWithCityid:(NSInteger)cityid withBlock:(void(^)(NSDictionary *,NSError *))block{
    
    [[NetworkManager sharedClient]getPath:APIGetHotVip
							   parameters:@{@"token":[UserInfoManager instance].tokenId_self,
											@"city_id" :@(cityid)}
                                withBlock:block useCache:NO];
    
}

//婚礼计划
+ (void)getWeddingPlanListWithStatus:(NSUInteger)status
							 andPage:(NSUInteger)page
                           WithBlock:(void (^)(NSDictionary *, NSError *))block {
    NSDictionary *dic;
    if(status==0)
    {
        dic=@{@"page" : @(page),@"token" : [UserInfoManager instance].tokenId_self,};
    }
    else
    {
        dic=@{@"page" : @(page),
              @"token" : [UserInfoManager instance].tokenId_self,
              @"status":@(status)};
    }
    [[NetworkManager sharedClient] getPath:APIWEDDINGPLANLIST
                                parameters:dic
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getWeddingDetailWithId:(NSString *)detailId
					 WithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] getPath:APIWEDDINGPLANDETAIL
                                parameters:@{@"matter_id": detailId, @"token": TOKEN}
                                 withBlock:block
                                  useCache:NO];
}

+ (void)getWeddingAdviertisementWithBlock:(void (^)(NSDictionary *result,NSError *error))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGAD
								parameters:@{@"tag":@"app_open_screen",@"city":@([UserInfoManager instance].curCityId)}
								 withBlock:block useCache:NO];
}

+ (void)getWeddingTimeVersionInfoWithBlock:(void (^)(NSDictionary *result,NSError *error))block
{
	[[NetworkManager sharedClient] getPath:APIWEDDINGTIMEVERSION parameters:nil withBlock:block useCache:NO];
}

@end
