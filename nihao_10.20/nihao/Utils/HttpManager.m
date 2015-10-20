//
//  HttpManager.m
//  nihao
//
//  Created by 刘志 on 15/6/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "HttpManager.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "GTMNSString+URLArguments.h"

@implementation HttpManager

static const NSInteger SESSION_INVALID = 100;

static NSString *ssid = @"920005eaa3926e9af472a6610b3dfa9059a";
static NSString *jsessionid = nil;

+ (NSOperationQueue *) getHttpQueue {
    static NSOperationQueue *queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        queue = [[NSOperationQueue alloc] init];
    });
    return queue;
}

+ (AFHTTPRequestOperationManager *) initAFHttpManager {
    static AFHTTPRequestOperationManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        //manager.operationQueue.maxConcurrentOperationCount = 1;
    });
    return manager;
}

+ (void)userLoginWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(SuccessBlock)success failBlock:(FailBlock)fail {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[phoneNumber, password] forKeys:@[@"ci_phone", @"ci_login_password"]];
    [HttpManager requestByPost:USER_LOGIN params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)getAuthCodeByPhoneNumber:(NSString *)phoneNumber chc_type:(NSString *)chc_type success:(SuccessBlock)success failBlock:(FailBlock)fail {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[phoneNumber,chc_type] forKeys:@[@"chc_phone",@"chc_type"]];
    [HttpManager requestByPost:USER_GET_AUTH_CODE params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)getRecommendUserListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:USER_GET_RECOMMEND_USER_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)completeUserInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:USER_COMPLETE_INFO params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)addRelationBySelfUserID:(NSString *)selfUserID toPeerUserID:(NSString *)peerUserID success:(SuccessBlock)success failBlock:(FailBlock)fail {
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[selfUserID, peerUserID, random] forKeys:@[@"cr_relation_ci_id", @"cr_by_ci_id", @"random"]];
    [HttpManager requestByPost:USER_ADD_RELATION params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)removeRelationBySelfUserID:(NSString *)selfUserID toPeerUserID:(NSString *)peerUserID success:(SuccessBlock)success failBlock:(FailBlock)fail {
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[selfUserID, peerUserID, random] forKeys:@[@"cr_relation_ci_id", @"cr_by_ci_id", @"random"]];
    [HttpManager requestByPost:USER_REMOVE_RELATION params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)importContacts:(NSString *)contacts userID:(NSString *)userid success:(SuccessBlock)success failBlock:(FailBlock)fail {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[contacts, userid] forKeys:@[@"ci_phones", @"ci_id"]];
    [HttpManager requestByPost:USER_IMPORT_CONTACTS params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)verifyUserNameUnique:(NSString *)username userID:(NSString *)userID success:(SuccessBlock)success failBlock:(FailBlock)fail {
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[username, userID] forKeys:@[@"ci_nikename", @"ci_id"]];
    [HttpManager requestByPost:VERIFY_USERNAME_UNIQUE params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)fileUploadByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    
}

+ (void)userIconUploadWithImageData:(NSData *)imageData parameters:(NSDictionary *)parameters iconName:(NSString *)name success:(SuccessBlock)success failBlock:(FailBlock)fail {
    AFHTTPRequestOperationManager *manager = [HttpManager initAFHttpManager];
    NSString *sign = [HttpManager signParams:parameters];
    AFHTTPRequestSerializer *serializer = manager.requestSerializer;
    [serializer setValue:sign forHTTPHeaderField:@"sign"];
    [manager POST:COMMON_FILE_UPLOAD parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"UserIconUpload" fileName:name mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([HttpManager isSsidValid:operation responseObject:responseObject]) {
            success(operation, responseObject);
        } else {
            [HttpManager userIconUploadWithImageData:imageData parameters:parameters iconName:name success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success(operation, responseObject);
            } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                fail(operation,error);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)updateUserGPSByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:UPDATE_USER_GPS params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestHotCityListWithSuccess:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_HOT_CITY_LIST params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestTopUserListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_TOP_USERS_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestNewsListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail;{
    [HttpManager requestByPost:REQUEST_NEWS_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestUserPostListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_POST_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)deleteUserPostByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:DELETE_USER_POST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestUserFollowPostListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_FOLLOW_POST_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)commitUserCommentByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:COMMIT_USER_COMMENT params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)userPraiseByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:USER_PRAISE params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)userCancelPraiseByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:USER_CANCEL_PRAISE params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)deleteUserCommentByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:DELETE_USER_COMMENT params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestPostInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_POST_INFO params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestCommentsByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_POST_OR_NEWS_COMMENTS params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)publishNewAskByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:PUBLISH_NEW_ASK params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestAskCategoryListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_ASK_CATEGORY_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestAskCategoryHotAskListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_ASK_CATEGORY_HOT_ASK_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestAskCategoryAskListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_ASK_CATEGORY_ASK_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestAskCityListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail; {
    [HttpManager requestByPost:REQUEST_ASK_CITY_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestAskDetailByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_ASK_DETAIL params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)setAskBestAnswerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:SET_BEST_ANSWER_FOR_ASK params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)deleteAskByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
	[HttpManager requestByPost:DELETE_ASK params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation,responseObject);
	} fail:^(AFHTTPRequestOperation *operation, NSError *error) {
		fail(operation,error);
	}];
}

+ (void) queryCities : (SuccessBlock) success failBlock : (FailBlock) fail {
    [HttpManager requestByPost:QUERY_CITY params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestServiceList:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_SERVICE_LIST params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestMerchantAdsListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_MERCHANT_ADS_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestNewlyAddMerchantListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_NEWLY_ADD_MERCHANT_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestRecommendedMerchantListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
	[HttpManager requestByPost:REQUEST_RECOMMENDED_MERCHANT_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation,responseObject);
	} fail:^(AFHTTPRequestOperation *operation, NSError *error) {
		fail(operation,error);
	}];
}

+ (void)requestMerchantListByFilter:(MyMerchantListFilter *)filter success:(SuccessBlock)success failBlock:(FailBlock)fail {
    NSDictionary *parameters = [filter getNotNULLParameters];
    [HttpManager requestByPost:REQUEST_MERCHANT_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestFilterListWithParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_FILTER_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) queryLiveCities:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:QUERY_LIVE_CITIES params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) queryNations:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:QUERY_NATIONS params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)postDynamic : (NSDictionary *)parameters success : (SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:POST_DYNAMIC params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestDiscoverListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_DISCOVER_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestFriendsList:(NSDictionary *) params success :(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_FRIENDS_LIST params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestMerchantDetailWithParameters:(NSDictionary *) params success :(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_MERCHANT_DETAIL_LIST params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestUserFollowerListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_FOLLOWER_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestUserFollowListByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_FOLLOW_LIST params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestUserInfoByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_INFO params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)userFeedBackByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:USER_FEEDBACK params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUserInfo:(NSDictionary *)params success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USER_INFO params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUserInfosByUserNames:(NSString *)usernames success:(SuccessBlock)success failBlock:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_USERINFO_BYUSERNAME params:@{@"userNames":usernames} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)batchFollowUsersByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
	[HttpManager requestByPost:BATCH_FOLLOW_USERS params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation,responseObject);
	} fail:^(AFHTTPRequestOperation *operation, NSError *error) {
		fail(operation,error);
	}];
}

//上传用户备注名
+(void)importNickNameByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail{
    [HttpManager requestByPost:USER_MODIFY_NICKNAME params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];

}

//不显示当前查看用户的动态
+(void)addNotLookByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail{
    [HttpManager requestByPost:ADD_NOT_LOOK params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

//不显示我的动态给当前查看用户
+(void)addNotShowMyMomenToHerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail{
    [HttpManager requestByPost:NOT_SHOW_TO_HER params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

//取消不看此人动态
+(void)canlcelNotLookHerByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail{
    [HttpManager requestByPost:CANCEL_NOT_LOOK_HER params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

//取消此人不看我的动态
+(void)canlcelHerNotLookMeByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail{
    [HttpManager requestByPost:CANCEL_HER_NOT_LOOK_ME params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}


+ (void) requestUsersByNickName : (NSDictionary *) params success : (SuccessBlock) success failBlock : (FailBlock) fail {
    [HttpManager requestByPost:REQUEST_USERS_BY_NICKNAME params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) translateContent:(NSString *)content from:(NSString *)from to:(NSString *)to apiKey : (NSString *) apiKey success:(SuccessBlock)success fail:(FailBlock)fail {
    AFHTTPRequestOperationManager *manager = [HttpManager initAFHttpManager];
    AFHTTPRequestSerializer *requestSerializer = manager.requestSerializer;
    [requestSerializer setValue:apiKey forHTTPHeaderField:@"apikey"];
    NSDictionary *params = @{@"query":content,@"from":from,@"to":to};
    [manager GET:TRANSLATE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)calculateExchangeRateByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
	AFHTTPRequestOperationManager *manager = [HttpManager initAFHttpManager];
	[manager.requestSerializer setValue:CURRENCY_SERVICE_API_KEY forHTTPHeaderField:@"apikey"];
	[manager GET:CURRENCY_SERVICE parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation,responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		fail(operation,error);
	}];
}

+ (void)requestWeatherByParameters:(NSDictionary *)parameters success:(SuccessBlock)success failBlock:(FailBlock)fail {
	[HttpManager requestByPost:REQUEST_WEATHER_FROM_SERVER params:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation,responseObject);
	} fail:^(AFHTTPRequestOperation *operation, NSError *error) {
		fail(operation,error);
	}];
}

+ (void) makeYinlianOrder:(NSInteger)pi_id od_pi_count:(NSInteger)od_pi_count pi_params:(NSString *)pi_params oi_introduction:(NSString *)oi_introduction oi_source:(NSString *)oi_source ci_id:(NSString *)ci_id payType:(NSString *)payType success:(SuccessBlock)success fail:(FailBlock)fail{
    NSDictionary *params = @{@"pi_id":[NSString stringWithFormat:@"%ld",pi_id],@"od_pi_count":[NSString stringWithFormat:@"%ld",od_pi_count],@"pi_param":pi_params,@"oi_introduction":oi_introduction,@"oi_source":oi_source,@"ci_id":ci_id,@"payType":payType};
    [HttpManager requestByPost:MAKE_YINLIAN_ORDER params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestMobileContactGoodsList:(SuccessBlock)success fail:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_MOBILE_RECHARGE_GOODSLIST params:@{@"businessAction":@"话费充值"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) checkChargePhoneNumberIfValid:(NSString *)phone money:(NSString *)money success:(SuccessBlock)success fail:(FailBlock)fail{
    AFHTTPRequestOperationManager *manager = [HttpManager initAFHttpManager];
    [manager GET:CHECK_CHARGE_PHONE_NUMBER_ISVALID parameters:@{@"phone":phone,@"cardnum":money} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void)requestFriend : (NSString *) cfr_by_ci_id cfr_request_info : (NSString *) cfr_request_info cfr_request_ci_id : (NSString *) cfr_request_ci_id cfr_request_remark_name : (NSString *) cfr_request_remark_name success : (SuccessBlock) success fail : (FailBlock) fail {
    [HttpManager requestByPost:REQUEST_FRIEND params:@{@"cfr_by_ci_id":cfr_by_ci_id,@"cfr_request_info":cfr_request_info,@"cfr_request_ci_id":cfr_request_ci_id,@"cfr_request_remark_name":cfr_request_remark_name} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestPhoneChargeOrderStatus:(NSString *)orderNo success:(SuccessBlock)success fail:(FailBlock)fail {
    [HttpManager requestByPost:CHECK_CHARGE_PHONE_ORDER_STATUS params:@{@"orderNo" : orderNo} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUnreadMessageNums:(NSString *)ci_id success:(SuccessBlock)success fail:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_UNREAD_MESSAGES params:@{@"ci_id":ci_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUnreadLikeList:(NSInteger)ci_id page:(NSInteger)page success:(SuccessBlock)success fail:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_UNREAD_LIKE_LIST params:@{@"ci_id":[NSString stringWithFormat:@"%ld",ci_id],@"page":[NSString stringWithFormat:@"%ld",page],@"rows":DEFAULT_REQUEST_DATA_ROWS} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUnreadAskCommentList:(NSInteger)ci_id page:(NSInteger)page success:(SuccessBlock)success fail:(FailBlock)fail {
    [HttpManager requestByPost:REQUEST_UNREAD_ASK_COMMENT_LIST params:@{@"ci_id":[NSString stringWithFormat:@"%ld",ci_id],@"page":[NSString stringWithFormat:@"%ld",page],@"rows":DEFAULT_REQUEST_DATA_ROWS} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestUnreadCommentNums : (NSString *) ci_id success : (SuccessBlock) success fail : (FailBlock) fail {
    [HttpManager requestByPost:REQUEST_UNREAD_COMMENT_LIST params:@{@"ci_id":ci_id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestReport : (NSString *) ci_id cd_id : (NSString *) cd_id reportType : (NSString *) reportType reportComment : (NSString *) reportComment aki_id : (NSString *) aki_id cmd_id:(NSString *)cmd_id r_ci_id : (NSString *) r_ci_id success:(SuccessBlock)success fail:(FailBlock)fail {
    NSDictionary *params = @{@"ci_id":ci_id,@"cd_id":cd_id,@"reportType":reportType,@"reportComment":reportComment,@"aki_id":aki_id,@"cmd_id":cmd_id,
                             @"r_ci_id":r_ci_id};
    [HttpManager requestByPost:REQUEST_REPORT params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation,error);
    }];
}

+ (void) requestNewFriend : (NSInteger) cfr_by_ci_id cfr_request_info : (NSString *) cfr_request_info cfr_request_ci_id : (NSInteger) cfr_request_ci_id success : (SuccessBlock) success fail : (FailBlock) fail {
    
}

/**
 *  ssl验证
 *
 *  @return
 */
+ (AFSecurityPolicy*)customSecurityPolicy
{
    /**** SSL Pinning ****/
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"nihao" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [securityPolicy setPinnedCertificates:@[certData]];
    /**** SSL Pinning ****/
    return securityPolicy;
}

/**
 *  加密参数，规则为字段的key按照首字母排序，排序后对应的value拼成一段字符串，再添加ssid。
 *  若ssid的首字母或末字母为a或A时，将ssid添加到字符串的最前面，为d或D时，将ssid添加到字符串的最后。
 *  最终将得到的字符串进行md5加密
 *
 *  @param params 网络请求的参数
 *
 *  @return 加密后的字符串
 */
+ (NSString *) signParams : (NSDictionary *) params {
    NSMutableString *paramsStr = [[NSMutableString alloc] init];
    //NSString *ssid = [AppConfigure objectForKey:SSID];
    NSMutableArray *sortedArray = [NSMutableArray array];
    if(!IsStringEmpty(ssid)) {
        if([ssid hasPrefix:@"a"] || [ssid hasPrefix:@"A"] || [ssid hasSuffix:@"a"] || [ssid hasSuffix:@"A"]) {
            NSArray *array = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return  [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
            }];
            [sortedArray addObjectsFromArray:array];
        } else {
            NSArray *array = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return  [obj2 compare:obj1 options:NSCaseInsensitiveSearch];
            }];
            [sortedArray addObjectsFromArray:array];
        }
    } else {
        [sortedArray addObjectsFromArray:[params allKeys]];
    }

    for(NSString *key in sortedArray) {
        NSString *value = [NSString stringWithFormat:@"%@", params[key]];
        [paramsStr appendString:value];
    }
    
    if(!IsStringEmpty(ssid)) {
        if([ssid hasPrefix:@"a"] || [ssid hasPrefix:@"A"] || [ssid hasSuffix:@"a"] || [ssid hasSuffix:@"A"] ) {
            [paramsStr insertString:ssid atIndex:0];
        } else {
            [paramsStr appendString:ssid];
        }
    }
    NSString *md5 = [BaseFunction md5Digest:paramsStr];
    return md5;
}

/**
 *  ssid是否有效
 *
 *  @param responseObject 服务器返回结果
 *
 *  @return no为无效
 */
+ (BOOL) isSsidValid : (AFHTTPRequestOperation *)operation responseObject : (id) responseObject{
    NSDictionary *headers = operation.response.allHeaderFields;
    if(headers && [[headers allKeys] containsObject:@"ssid"]) {
        ssid = headers[@"ssid"];
        [AppConfigure setObject:ssid ForKey:SSID];
    }
    if([responseObject[@"code"] integerValue] == SESSION_INVALID) {
        return NO;
    } else {
        return YES;
    }
}

/**
 *  对请求进行预处理
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void) requestByPost : (NSString *) url params : (NSDictionary *) params success : (SuccessBlock) success fail : (FailBlock) fail {
    AFHTTPRequestOperationManager *manager = [HttpManager initAFHttpManager];
    NSString *sign = [HttpManager signParams:params];
    AFHTTPRequestSerializer *serializer = manager.requestSerializer;
    [serializer setValue:sign forHTTPHeaderField:@"sign"];
    [serializer setValue:@"1" forHTTPHeaderField:@"platform"];
    if([url isEqualToString:USER_LOGIN] || !IsStringEmpty(ssid)) {
        [serializer setValue:@"1" forHTTPHeaderField:@"updateSourceFlag"];
    } else {
        [serializer setValue:@"0" forHTTPHeaderField:@"updateSourceFlag"];
    }
    //[serializer setValue:ssid forHTTPHeaderField:@"ssid"];
    [serializer setValue:[AppConfigure objectForKey:DEVICE_TOKENS] forHTTPHeaderField:DEVICE_TOKENS];
    if([AppConfigure integerForKey:LOGINED_USER_ID] != 0) {
        [serializer setValue:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] forHTTPHeaderField:@"ci_id"];
    }
    
    AFHTTPRequestOperation *operation = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation isCancelled]) {
            [HttpManager requestByPost:url params:params success:success fail:fail];
        } else
           fail(operation,error);
    }];
    
    NSLog(@"%@",operation.request.URL);
}

@end
