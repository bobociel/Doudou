//
//  UserService.m
//  AFNetworking+QHNetworking
//
//  Created by imqiuhang on 15/2/5.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import "UserService.h"
#import "RSA.h"
#import "Base64.h"
#define APIUSERBINDPHONE        @"/app/v010/u/set_phone/"
#define APILOGIN                @"/app/v010/u/sign/"             //登陆
#define APIVerify               @"/app/v010/u/send_confirm_key/" //验证码
#define APIFind_Verify          @"/app/v011/u/find/send_confirm_key" //验证码
#define APISave_Password        @"/app/v011/u/find/save_password" //验证码
#define APICheck_Verify         @"/app/v011/u/find/checkpasswd"
#define APIRegister             @"/app/v010/u/join/"             //注册
#define APIMYINFOMATION         @"/app/v020/u/update_profile/"   //完善我的信息
#define APICHANGEPASSWORD       @"/app/v010/u/update_password/"  //修改密码
#define APIUSERUPDATEAVATAR     @"/app/v010/u/set_avatar/"
#define APIWEDDINGGETTIME       @"/app/v010/u/wedding/time"
#define APIUSERDRAPRELATIONSHIP @"/app/v020/u/drop_relationship" //解除绑定

@implementation UserService
+ (void)bindPhoneWthPhone:(NSString *)phone
           andConfrimCode:(NSString *)confrimCode
                withToken:(NSString*)token
             withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    RSA *rsa = [[RSA alloc] init];
    
    NSString *emailStr = [NSString stringWithFormat:@"%@", [[rsa encryptWithString:phone] base64EncodedString]];

    NSDictionary *params = @{@"phone" : emailStr,
							  @"confirm_key" : [NSString stringWithFormat:@"%@", [[rsa encryptWithString:confrimCode] base64EncodedString]],
                             @"token" : token,
                             };
    
    [[NetworkManager sharedClient] postPath:APIUSERBINDPHONE
                                 parameters:params
                                  withBlock:block];
}

+ (void)loginWithEmail:(NSString *)EMail
              password:(NSString *)password
             withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    RSA *rsa = [[RSA alloc] init];
    
    NSString *emailStr = [NSString
                          stringWithFormat:@"%@",
                          [[rsa encryptWithString:EMail] base64EncodedString]];
    
    NSString *passwordStr = [NSString
                             stringWithFormat:@"%@",
                             [[rsa encryptWithString:password] base64EncodedString]];
    
    NSDictionary *params = @{
                             @"user_info" : emailStr,
                             @"pwd" : passwordStr,
                             };
    
    [[NetworkManager sharedClient] postPath:APILOGIN
                                 parameters:params
                                  withBlock:block];
}

+ (void)getVerifyCodeWithPhone:(NSString *)phone
                     withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIVerify
                                 parameters:@{
                                              @"phone" : phone
                                              }
                                  withBlock:block];
}

+ (void)getVerifyCodeWithPhoneOrEmail:(NSString *)phone
                     withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIFind_Verify
                                 parameters:@{
                                              @"account_info" : phone
                                              }
                                  withBlock:block];
}

+ (void)postPassWithPhoneOrEmail:(NSString *)phone Verify:(NSString *)Verify pass:(NSString*)pass
                             withBlock:(void (^)(NSDictionary *, NSError *))block{
    [[NetworkManager sharedClient] postPath:APISave_Password
                                 parameters:@{
                                              @"account_info" : phone,
                                              @"confirm_key" : Verify,
                                              @"password":pass
                                              }
                                  withBlock:block];
}

+ (void)postVerifyCodeWithPhoneOrEmail:(NSString *)phone Verify:(NSString *)Verify
                             withBlock:(void (^)(NSDictionary *, NSError *))block{
    [[NetworkManager sharedClient] postPath:APICheck_Verify
                                 parameters:@{
                                              @"account_info" : phone,
                                              @"confirm_key" : Verify
                                              }
                                  withBlock:block];
}

+ (void)registerWithPhone:(NSString *)phone
              andPassword:(NSString *)password
           andConfrimCode:(NSString *)confrimCode
                withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    RSA *rsa = [[RSA alloc] init];
    
    NSDictionary *params = @{
                             @"phone" : [NSString
                                         stringWithFormat:@"%@",
                                         [[rsa encryptWithString:phone] base64EncodedString]],
                             @"pwd" : [NSString
                                       stringWithFormat:
                                       @"%@", [[rsa encryptWithString:password] base64EncodedString]],
                             @"confirm_key" : [NSString
                                               stringWithFormat:
                                               @"%@", [[rsa encryptWithString:confrimCode] base64EncodedString]]
                             };
    
    [[NetworkManager sharedClient] postPath:APIRegister
                                 parameters:params
                                  withBlock:block];
}

+ (void)updateUserInfomationWithAvata:(NSString *)avataKey
                          andUserName:(NSString *)userName
                              andRole:(UserGender)userGender
                            withBlock:
(void (^)(NSDictionary *, NSError *))block {
    
    NSString *userGenderStr =
    userGender == UserGenderMale ? @"bridegroom" : @"bride";
    NSDictionary *params = @{
                             @"avatar" : avataKey,
                             @"username" : userName,
                             @"role" : userGenderStr,
                             @"token" : [UserInfoManager instance].tokenId_self
                             };
    
    [[NetworkManager sharedClient] postPath:APIMYINFOMATION
                                 parameters:params
                                  withBlock:block];
}

+ (void)postChangePasswordWithOld:(NSString *)oldpassword
                           andnew:(NSString *)newpassword
                        WithBlock:(void (^)(NSDictionary *result,
                                            NSError *error))block {
    [[NetworkManager sharedClient] postPath:APICHANGEPASSWORD
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"old_pwd" : oldpassword,
                                              @"new_pwd" : newpassword
                                              }
                                  withBlock:block];
}

+ (void)postUpdateUserAvatarWithImageKey:(NSString *)imageKey
                               WithBlock:
(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIUSERUPDATEAVATAR
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"avatar" : imageKey
                                              }
                                  withBlock:block];
}

+ (void)getWeddingTimeWithBlock:(void (^)(NSDictionary *result, NSError *error))block;
{
    [[NetworkManager sharedClient] getPath:APIWEDDINGGETTIME parameters:@{@"token":[UserInfoManager instance].tokenId_self} withBlock:block  useCache:YES];

}
+ (void)postDrapReleshipWithBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIUSERDRAPRELATIONSHIP
                                 parameters:@{
                                              @"token" : [UserInfoManager instance].tokenId_self,
                                              @"delete" : @(YES)
                                              }
                                  withBlock:block];
}
@end
