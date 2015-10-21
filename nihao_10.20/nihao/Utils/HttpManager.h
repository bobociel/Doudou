//
//  HttpManager.h
//  nihao
//
//  Created by 刘志 on 15/6/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "MyMerchantListFilter.h"
#import "Constants.h"

#define SERVER_VERSON @"/nihaoclient_04"

#define BASE_URL [kServerAddress stringByAppendingString:SERVER_VERSON]

// 通用模块
#define COMMON_FILE_UPLOAD [kServerAddress stringByAppendingString:@"/fileServer/fileUpload/uploadPicture.shtml"]
#define UPDATE_USER_GPS [BASE_URL stringByAppendingString:@"/customer/updateCoordinates.shtml"]
#define MAKE_YINLIAN_ORDER [BASE_URL stringByAppendingString:@"/order/quickOrder.shtml"]
#define REQUEST_REPORT [BASE_URL stringByAppendingString:@"/customer/customerReport.shtml"]

// 获取热门城市列表
#define REQUEST_HOT_CITY_LIST [BASE_URL stringByAppendingString:@"/area/getHotCity.shtml"]
//翻译
#define TRANSLATE @"http://apis.baidu.com/apistore/tranlateservice/translate"

// 用户模块
#define USER_LOGIN [BASE_URL stringByAppendingString:@"/customer/userLogin.shtml"]
#define USER_GET_AUTH_CODE [BASE_URL stringByAppendingString:@"/customer/getCheckCode.shtml"]
#define USER_GET_RECOMMEND_USER_LIST [BASE_URL stringByAppendingString:@"/customer/getRecommendFriend.shtml"]
#define QUERY_LIVE_CITIES [BASE_URL stringByAppendingString:@"/area/getAllCity.shtml"]
#define QUERY_NATIONS [BASE_URL stringByAppendingString:@"/area/getAllCountry.shtml"]
#define USER_COMPLETE_INFO [BASE_URL stringByAppendingString:@"/customer/completeCustomerInfo.shtml"]
#define USER_ADD_RELATION [BASE_URL stringByAppendingString:@"/customerRelation/addRelation.shtml"]
#define USER_IMPORT_CONTACTS [BASE_URL stringByAppendingString:@"/customer/getCustomerByManyPhone.shtml"]
#define USER_REMOVE_RELATION [BASE_URL stringByAppendingString:@"/customerRelation/removeRelation.shtml"]
#define REQUEST_FRIENDS_LIST [BASE_URL stringByAppendingString:@"/customerRelation/getEachOtherRelationCustomer.shtml"]
#define VERIFY_USERNAME_UNIQUE [BASE_URL stringByAppendingString:@"/customer/isUniqueNikeName.shtml"]
#define REQUEST_USER_INFO [BASE_URL stringByAppendingString:@"/customer/getCustomerInfo.shtml"]
#define REQUEST_USERS_BY_NICKNAME [BASE_URL stringByAppendingString:@"/customer/getCustomerByNikeName.shtml"]
#define REQUEST_FRIEND [BASE_URL stringByAppendingString:@"/customer/friendRequest/addFriendRequest.shtml"]
#define BATCH_FOLLOW_USERS [BASE_URL stringByAppendingString:@"/customerRelation/addBatchRelation.shtml"]
#define USER_MODIFY_NICKNAME [BASE_URL stringByAppendingString:@"/customerRelation/updateRelationCustomerRemarkName.shtml"]
#define ADD_NOT_LOOK  [BASE_URL stringByAppendingString:@"/customerRelation/addMeNotLookHer.shtml"]
#define NOT_SHOW_TO_HER  [BASE_URL stringByAppendingString:@"/customerRelation/addHerNotLookMe.shtml"]
#define CANCEL_NOT_LOOK_HER [BASE_URL stringByAppendingString:@"/customerRelation/deleteMeNotLookHer.shtml"]
#define CANCEL_HER_NOT_LOOK_ME [BASE_URL stringByAppendingString:@"/customerRelation/deleteHerNotLookMe.shtml"]
// Home模块
#define REQUEST_TOP_USERS_LIST [BASE_URL stringByAppendingString:@"/customer/getTopCustomer.shtml"]
#define REQUEST_NEWS_LIST [BASE_URL stringByAppendingString:@"/news/getNewsList.shtml"]
#define REQUEST_USER_POST_LIST [BASE_URL stringByAppendingString:@"/dynamic/getDynamicListForCustomer.shtml"]
#define DELETE_USER_POST [BASE_URL stringByAppendingString:@"/dynamic/deleteDynamic.shtml"]
#define REQUEST_USER_FOLLOW_POST_LIST [BASE_URL stringByAppendingString:@"/dynamic/getDynamicListByFriend.shtml"]
#define COMMIT_USER_COMMENT [BASE_URL stringByAppendingString:@"/comment/addComment.shtml"]
#define USER_PRAISE [BASE_URL stringByAppendingString:@"/praise/addPraise.shtml"]
#define USER_CANCEL_PRAISE [BASE_URL stringByAppendingString:@"/praise/deletePraise.shtml"]
#define DELETE_USER_COMMENT [BASE_URL stringByAppendingString:@"/comment/deleteComment.shtml"]
#define POST_DYNAMIC [BASE_URL stringByAppendingString:@"/dynamic/publishDynamic.shtml"]
#define REQUEST_DISCOVER_LIST [BASE_URL stringByAppendingString:@"/dynamic/getDynamicListByAll.shtml"]
#define REQUEST_POST_INFO [BASE_URL stringByAppendingString:@"/dynamic/getDynamicInfo.shtml"]
#define REQUEST_POST_OR_NEWS_COMMENTS [BASE_URL stringByAppendingString:@"/comment/getCustomerCommentList.shtml"]
#define NEWS_URL [BASE_URL stringByAppendingString:@"/news/getNewsInfoPage.shtml?ni_id=%d"]

// 发布 Ask
#define PUBLISH_NEW_ASK [BASE_URL stringByAppendingString:@"/askInfo/publishAsk.shtml"]
// 获取 Ask 分类列表
#define REQUEST_ASK_CATEGORY_LIST [BASE_URL stringByAppendingString:@"/askCategory/getAskCategoryList.shtml"]
// 获取 Ask 分类详情热门 Question 列表
#define REQUEST_ASK_CATEGORY_HOT_ASK_LIST [BASE_URL stringByAppendingString:@"/askInfo/getHotAskInfoList.shtml"]
// 获取 Ask 分类详情列表
#define REQUEST_ASK_CATEGORY_ASK_LIST [BASE_URL stringByAppendingString:@"/askInfo/getAskInfoList.shtml"]
// 获取 Ask 城市列表
#define REQUEST_ASK_CITY_LIST [BASE_URL stringByAppendingString:@"/askInfo/getAskCityList.shtml"]
// 获取 Ask 详情
#define REQUEST_ASK_DETAIL [BASE_URL stringByAppendingString:@"/askInfo/getAskInfo.shtml"]
// 设置 Ask 最佳答案
#define SET_BEST_ANSWER_FOR_ASK [BASE_URL stringByAppendingString:@"/askInfo/setBeatReturn.shtml"]
// 删除 Ask
#define DELETE_ASK [BASE_URL stringByAppendingString:@"/askInfo/deleteAsk.shtml"]

// 获取天气接口
//#define REQUEST_WEATHER @"https://route.showapi.com/9-5"
#define REQUEST_WEATHER_FROM_SERVER [BASE_URL stringByAppendingString:@"/weather/getWeather.shtml"]

// Message模块
#define REQUEST_USERINFO_BYUSERNAME [BASE_URL stringByAppendingString:@"/customer/getCustomerInfosByUserName.shtml"]

// Listing模块
#define QUERY_CITY [BASE_URL stringByAppendingString:@"/area/getUseCity.shtml"]
#define REQUEST_SERVICE_LIST [BASE_URL stringByAppendingString:@"/merchantsCategory/getMerchantsCategoryList.shtml"]
#define REQUEST_MERCHANT_ADS_LIST [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantsInfoAdvertList.shtml"]
#define REQUEST_NEWLY_ADD_MERCHANT_LIST [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantsInfoNewAddList.shtml"]
#define REQUEST_RECOMMENDED_MERCHANT_LIST [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantsInfoRecommendList.shtml"]
#define REQUEST_MERCHANT_LIST [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantsInfoByConditions.shtml"]
#define REQUEST_FILTER_LIST [BASE_URL stringByAppendingString:@"/multiple/getMerchantsInfoQueryCondition.shtml"]
#define REQUEST_MERCHANT_DETAIL_LIST [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantInfoById.shtml"]
#define MERCHANT_DISCOUNT_URL [BASE_URL stringByAppendingString:@"/merchantsInfo/getMerchantInfoById.shtml?mhi_id=%ld&action=pager"]

// Contact模块


// Me模块
#define REQUEST_USER_INFO [BASE_URL stringByAppendingString:@"/customer/getCustomerInfo.shtml"]
#define REQUEST_USER_FOLLOWER_LIST [BASE_URL stringByAppendingString:@"/customerRelation/getOtherToMeRelationCustomer.shtml"]
#define REQUEST_USER_FOLLOW_LIST [BASE_URL stringByAppendingString:@"/customerRelation/getMeToOtherRelationCustomer.shtml"]
#define USER_FEEDBACK [BASE_URL stringByAppendingString:@"/customerResponse/addCustomerResponse.shtml"]
#define REQUEST_MOBILE_RECHARGE_GOODSLIST [BASE_URL stringByAppendingString:@"/product/info/getProductInfoListByBusiness.shtml"]
#define REQUEST_UNREAD_MESSAGES [BASE_URL stringByAppendingString:@"/multiple/getNoReadMessageCount.shtml"]
#define REQUEST_UNREAD_LIKE_LIST [BASE_URL stringByAppendingString:@"/praise/getPraiseNoReadList.shtml"]
#define REQUEST_NEW_FRIEND [BASE_URL stringByAppendingString:@"/customer/friendRequest/addFriendRequest.shtml"]
#define REQUEST_UNREAD_COMMENT_LIST [BASE_URL stringByAppendingString:@"/comment/getNoReadDynamicCommentList.shtml"]
#define REQUEST_UNREAD_ASK_COMMENT_LIST [BASE_URL stringByAppendingString:@"/comment/getNoReadAskCommentList.shtml"]

// 汇率转换
#define CURRENCY_SERVICE_API_KEY @"7e9354f8172cef845e17bef76f82fec9"
#define CURRENCY_SERVICE @"http://apis.baidu.com/apistore/currencyservice/currency"

//检测电话号码是否可以充值
#define CHECK_CHARGE_PHONE_NUMBER_ISVALID @"http://120.25.155.28:80/nihaocontact/juhe/checkPrepaidRecharge.shtml"
#define CHECK_CHARGE_PHONE_ORDER_STATUS [BASE_URL stringByAppendingString:@"/order/checkOrderType.shtml"]

@interface HttpManager : NSObject

typedef void(^SuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void(^FailBlock) (AFHTTPRequestOperation *operation, NSError *error);

/* ------ 用户模块 ------ */
// 用户登录
+ (void)userLoginWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取验证码,chc_type : 1登录，2找回密码
+ (void)getAuthCodeByPhoneNumber:(NSString *)phoneNumber chc_type : (NSString *) chc_type success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 根据条件获取推荐的用户列表
+ (void)getRecommendUserListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 根据传入的数据完善用户信息
+ (void)completeUserInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 关注接口
+ (void)addRelationBySelfUserID:(NSString *)selfUserID toPeerUserID:(NSString *)peerUserID success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 取消关注接口
+ (void)removeRelationBySelfUserID:(NSString *)selfUserID toPeerUserID:(NSString *)peerUserID success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 上传通讯录
+ (void)importContacts:(NSString *)contacts userID:(NSString *)userid success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 验证用户名唯一性
+ (void)verifyUserNameUnique:(NSString *)username userID:(NSString *)userID success:(SuccessBlock)success failBlock:(FailBlock)fail;

//根据用户名获取用户信息
+ (void)requestUserInfosByUserNames:(NSString *)usernames success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 批量关注用户
+ (void)batchFollowUsersByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//上传用户备注名
+(void)importNickNameByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//不查看他的动态
+(void)addNotLookByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//不允许他察看我的动态
+(void)addNotShowMyMomenToHerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//取消不看此人动态
+(void)canlcelNotLookHerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//取消不让此人看我的动态
+(void)canlcelHerNotLookMeByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;
/**
 *  请求添加好友
 *
 *  @param cfr_by_ci_id            被请求者的id
 *  @param cfr_request_info        请求说明
 *  @param cfr_request_ci_id       请求者id
 *  @param cfr_request_remark_name 请求备注
 */
+ (void)requestFriend : (NSString *) cfr_by_ci_id cfr_request_info : (NSString *) cfr_request_info cfr_request_ci_id : (NSString *) cfr_request_ci_id cfr_request_remark_name : (NSString *) cfr_request_remark_name success : (SuccessBlock) success fail : (FailBlock) fail;

/* ------ 通用模块 ------ */
// 文件上传
+ (void)fileUploadByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 用户头像上传
+ (void)userIconUploadWithImageData:(NSData *)imageData parameters:(NSDictionary *)parameters iconName:(NSString *)name success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 更新用户当前GPS位置
+ (void)updateUserGPSByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取热门城市列表
+ (void)requestHotCityListWithSuccess:(SuccessBlock)success failBlock:(FailBlock)fail;

/* ------ HomeE模块 ------ */
// 获取Top页用户列表
+ (void)requestTopUserListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取News列表
+ (void)requestNewsListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取用户的POST列表
+ (void)requestUserPostListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 删除用户的某条POST
+ (void)deleteUserPostByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取用户的Follow的用户的POST列表
+ (void)requestUserFollowPostListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 添加用户评论
+ (void)commitUserCommentByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 用户点赞
+ (void)userPraiseByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 用户取消点赞
+ (void)userCancelPraiseByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 删除用户评论
+ (void)deleteUserCommentByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

//发布动态
+ (void)postDynamic : (NSDictionary *)parameters success : (SuccessBlock)success failBlock:(FailBlock)fail;

//发现动态
+ (void)requestDiscoverListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取Post详情
+ (void)requestPostInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取评论列表
+ (void)requestCommentsByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 发布 Ask
+ (void)publishNewAskByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取 Ask 分类列表
+ (void)requestAskCategoryListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取 Ask 分类详情热门 Question 列表
+ (void)requestAskCategoryHotAskListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取 Ask 分类详情列表
+ (void)requestAskCategoryAskListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取 Ask 城市列表
+ (void)requestAskCityListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取 Ask 详情
+ (void)requestAskDetailByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 设置 Ask 最佳答案
+ (void)setAskBestAnswerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 删除 Ask
+ (void)deleteAskByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

/* ------ Listing模块 ------ */
// 查询开通服务城市
+ (void) queryCities : (SuccessBlock) success failBlock : (FailBlock) fail;

// 获取服务分类列表
+ (void)requestServiceList:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取商家广告列表
+ (void)requestMerchantAdsListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取最新添加商户列表
+ (void)requestNewlyAddMerchantListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取推荐商户列表
+ (void)requestRecommendedMerchantListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 根据条件获取商户列表
+ (void)requestMerchantListByFilter:(MyMerchantListFilter *)filter success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 根据选择的城市ID和一级分类获取筛选列表
+ (void)requestFilterListWithParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 查询所有城市
+ (void) queryLiveCities : (SuccessBlock) success failBlock : (FailBlock) fail;

//查询所有国家
+ (void) queryNations : (SuccessBlock) success failBlock : (FailBlock) fail;

//查询用户列表
+ (void) requestFriendsList :(NSDictionary *)params success : (SuccessBlock) success failBlock : (FailBlock) fail;
//获取商户详情
+ (void) requestMerchantDetailWithParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock) fail;

//根据昵称查询用户（未关注过的）
+ (void) requestUsersByNickName : (NSDictionary *) params success : (SuccessBlock) success failBlock : (FailBlock) fail;

/* ------ Me模块 ------ */
// 获取用户粉丝列表
+ (void)requestUserFollowerListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取用户关注的用户列表
+ (void)requestUserFollowListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取用户详情
+ (void)requestUserInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 用户反馈
+ (void)userFeedBackByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 汇率转换
+ (void)calculateExchangeRateByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

// 获取天气
+ (void)requestWeatherByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;

/**
 *  请求用户数据
 *
 *  @param params  by_ci_id 查看用户的id, ci_id当前登录用户的id
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestUserInfo : (NSDictionary *) params success : (SuccessBlock) success failBlock : (FailBlock) fail;

/**
 *  翻译
 *
 *  @param content 需要翻译的内容
 *  @param from    源语言,"en" or "zh"
 *  @param to      目标语言 "en" or "zh"
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) translateContent : (NSString *) content from : (NSString *) from to : (NSString *) to apiKey : (NSString *) apikey success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  创建银联支付订单
 *
 *  @param pi_id           商品id
 *  @param od_pi_count     下单购买数量
 *  @param pi_params       购买商品的属性配置
 *  @param oi_introduction 订单简介
 *  @param oi_source       订单来源，10:安卓 20:苹果
 *  @param ci_id           操作用户
 *  @param payType         支付类型，1表示银联组建
 */
+ (void) makeYinlianOrder : (NSInteger) pi_id od_pi_count : (NSInteger) od_pi_count pi_params : (NSString *) pi_params oi_introduction : (NSString *) oi_introduction  oi_source : (NSString *) oi_source ci_id : (NSString *) ci_id payType : (NSString *) payType success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  检测当前手机号码是否可以充值
 *
 *  @param phone 手机号码
 *  @param money 金额
 */
+ (void) checkChargePhoneNumberIfValid : (NSString *) phone money : (NSString *) money success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  请求话费充值商品列表
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestMobileContactGoodsList : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  请求手机充值订单状态
 *
 *  @param orderNo 订单号
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestPhoneChargeOrderStatus : (NSString *) orderNo success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  添加好友申请
 *
 *  @param cfr_by_ci_id      被请求者id
 *  @param cfr_request_info  请求说明
 *  @param cfr_request_ci_id 请求者id
 *  @param success           成功回调
 *  @param fail              失败回调
 */
+ (void) requestNewFriend : (NSInteger) cfr_by_ci_id cfr_request_info : (NSString *) cfr_request_info cfr_request_ci_id : (NSInteger) cfr_request_ci_id success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  获取客户端未读消息总量
 *
 *  @param ci_id   用户id
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestUnreadMessageNums : (NSString *) ci_id success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  获取未读评论列表
 *
 *  @param ci_id   用户id
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestUnreadCommentNums : (NSString *) ci_id success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  获取未读的点赞列表
 *
 *  @param ci_id   用户id
 *  @param page    页码
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestUnreadLikeList : (NSInteger) ci_id page : (NSInteger) page success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  获取未读的ask回复列表
 *
 *  @param ci_id   用户id
 *  @param page    页码
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestUnreadAskCommentList : (NSInteger) ci_id page : (NSInteger) page success : (SuccessBlock) success fail : (FailBlock) fail;

/**
 *  举报
 *
 *  @param ci_id         举报人id
 *  @param cd_id         动态id
 *  @param reportType    0:垃圾营销；1:淫秽色情；2：敏感信息；3:骚扰我；4:不实信息;5.其他信息
 *  @param reportComment 举报备注
 *  @param aki_id        ask id
 *  @param cmd_id        评论id
 *  @param r_ci_id       举报客户id
 *  @param success       成功回调
 *  @param fail          失败回调
 */
+ (void) requestReport : (NSString *) ci_id cd_id : (NSString *) cd_id reportType : (NSString *) reportType reportComment : (NSString *) reportComment aki_id : (NSString *) aki_id cmd_id:(NSString *)cmd_id r_ci_id : (NSString *) r_ci_id success:(SuccessBlock)success fail:(FailBlock)fail;

+ (NSString *) signParams : (NSDictionary *) params;

@end
