//
//  UserService.h
//  AFNetworking+QHNetworking
//
//  Created by imqiuhang on 15/2/5.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "UserInfoManager.h"

@interface UserService : NSObject
+ (void)bindPhoneWthPhone:(NSString *)phone
           andConfrimCode:(NSString *)confrimCode
                withToken:(NSString*)token
                withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)loginWithEmail:(NSString *)EMail password:(NSString *)password withBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)getVerifyCodeWithPhone:(NSString *)phone withBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)getVerifyCodeWithPhoneOrEmail:(NSString *)phone
                            withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postPassWithPhoneOrEmail:(NSString *)phone Verify:(NSString *)Verify pass:(NSString*)pass
                       withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)postVerifyCodeWithPhoneOrEmail:(NSString *)phone Verify:(NSString *)Verify
                             withBlock:(void (^)(NSDictionary *, NSError *))block;

+ (void)registerWithPhone:(NSString *)phone andPassword:(NSString *)password andConfrimCode:(NSString *)confrimCode withBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)updateUserInfomationWithAvata:(NSString *)avataKey andUserName:(NSString *)userName andRole:(UserGender)userGender withBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)postChangePasswordWithOld:(NSString *)oldpassword andnew:(NSString *)newpassword WithBlock:(void (^)(NSDictionary *result, NSError *error))block;

+ (void)postUpdateUserAvatarWithImageKey:(NSString *)imageKey WithBlock:(void (^)(NSDictionary *result, NSError *error))block;


+ (void)getWeddingTimeWithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)postDrapReleshipWithBlock:(void (^)(NSDictionary *, NSError *))block;
@end
