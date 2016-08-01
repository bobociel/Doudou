//
//  UserService.m
//  AFNetworking+QHNetworking
//
//  Created by imqiuhang on 15/2/5.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import "UserService.h"
#import "RSA.h"
#define APILOGIN                @"/app/v010/u/sign/"                         //用户登陆
#define APIUSERBINDPHONE        @"/app/v010/u/set_phone/"                    //用户登录，绑定手机
#define APIMYINFOMATION         @"/app/v020/u/update_profile/"               //用户登录，完善我的信息

#define APIVerify               @"/app/v010/u/send_confirm_key/"             //用户注册，验证码
#define APIRegister             @"/app/v010/u/join/"                         //用户注册

#define APIFind_Verify          @"/app/v011/u/find/send_confirm_key"          //忘记密码，验证码
#define APICheck_Verify         @"/app/v011/u/find/checkpasswd"               //忘记密码，验证验证码
#define APISave_Password        @"/app/v011/u/find/save_password"             //忘记密码，重置密码

#define APICHANGEPASSWORD       @"/app/v010/u/update_password/"               //修改密码或设置密码
#define APIUSERDRAPRELATIONSHIP @"/app/v020/u/drop_relationship"              //解除绑定(另一半)
#define APIBINDALICODE          @"/app/v020/u/alipay/bind/"                   //绑定支付宝验证码(婚礼宝提现)
#define APIBINDALI              @"/app/v021/u/coupon/alipay"                  //绑定支付宝(婚礼宝提现)

#define APIRegisterWX    @"/app/v020/u/weixin_auth"                           //微信登录
#define kGETWXTOKENURL   @"https://api.weixin.qq.com/sns/oauth2/access_token" //微信授权
#define kGETWXUSERINFO   @"https://api.weixin.qq.com/sns/userinfo"            //获得微信用户信息

#define APIUSERUPDATEAVATAR     @"/app/v010/u/set_avatar/"  //暂时没用
#define APIWEDDINGGETTIME       @"/app/v010/u/wedding/time" //暂时没用

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
    
    [[NetworkManager sharedClient] postPath:APIUSERBINDPHONE parameters:params withBlock:block];
}

+ (void)loginWithEmail:(NSString *)EMail
              password:(NSString *)password
             withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    RSA *rsa = [[RSA alloc] init];
    
    NSString *emailStr = [NSString stringWithFormat:@"%@",[[rsa encryptWithString:EMail] base64EncodedString]];
    
    NSString *passwordStr = [NSString stringWithFormat:@"%@",[[rsa encryptWithString:password] base64EncodedString]];
    NSDictionary *params = @{
							 @"user_info" : emailStr,
                             @"pwd" : passwordStr,
                             };
    
    [[NetworkManager sharedClient] postPath:APILOGIN parameters:params withBlock:block];
}

+ (void)getVerifyCodeWithPhone:(NSString *)phone withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIVerify
                                 parameters:@{@"phone" : phone}
                                  withBlock:block];
}

+ (void)getVerifyCodeWithPhoneOrEmail:(NSString *)phone
							withBlock:(void (^)(NSDictionary *, NSError *))block {
    [[NetworkManager sharedClient] postPath:APIFind_Verify
                                 parameters:@{@"account_info" : phone}
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
                             @"phone" : [NSString stringWithFormat:@"%@",[[rsa encryptWithString:phone] base64EncodedString]],
                             @"pwd" : [NSString stringWithFormat:@"%@", [[rsa encryptWithString:password] base64EncodedString]],
                             @"confirm_key" : [NSString stringWithFormat:@"%@", [[rsa encryptWithString:confrimCode] base64EncodedString]]
                             };
    
	[[NetworkManager sharedClient] postPath:APIRegister parameters:params withBlock:block];
}

+ (void)updateUserInfomationWithAvata:(NSString *)avataKey
                          andUserName:(NSString *)userName
                              andRole:(UserGender)userGender
							 andToken:(NSString *)token
                            withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    NSString *userGenderStr =
    userGender == UserGenderMale ? @"bridegroom" : @"bride";
    NSDictionary *params = @{
							 @"avatar" : avataKey,
                             @"username" : userName,
                             @"role" : userGenderStr,
                             @"token" : token
                             };
    
    [[NetworkManager sharedClient] postPath:APIMYINFOMATION
                                 parameters:params
                                  withBlock:block];
}

+ (void)postChangePasswordWithToken:(NSString *)token
								Key:(NSString *)key
								old:(NSString *)oldpassword
							 andnew:(NSString *)newpassword
						  WithBlock:(void (^)(NSDictionary *result,NSError *error))block {
    [[NetworkManager sharedClient] postPath:APICHANGEPASSWORD
                                 parameters:@{@"key" : key,
                                              @"token" : token,
                                              @"old_pwd" : oldpassword,
                                              @"new_pwd" : newpassword
                                              }
                                  withBlock:block];
}

+ (void)postUpdateUserAvatarWithImageKey:(NSString *)imageKey
                               WithBlock:(void (^)(NSDictionary *, NSError *))block {
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
                                 parameters:@{ @"token" : [UserInfoManager instance].tokenId_self,
											   @"delete" : @(YES)}
                                  withBlock:block];
}

+ (void)getAliCodeWithPhoneOrEmail:(NSString *)phone withBlock:(void (^)(NSDictionary *, NSError *))block {
	[[NetworkManager sharedClient] postPath:APIBINDALICODE parameters:@{@"token":TOKEN,@"alipay_account" : phone} withBlock:block];
}

+ (void)postAliAccountWithTicketID:(NSString *)ID
						   andCode:(NSString *)code
						andAccount:(NSString *)account
							 block:(void (^)(NSDictionary *result, NSError *error))block
{
	[[NetworkManager sharedClient] postPath:APIBINDALI
								 parameters:@{@"token":TOKEN,@"id":ID,@"confirm_key":code,@"alipay_account":account}
								  withBlock:block];
}

//微信登录
+ (void)getWXUserInfoWithCode:(NSString *)code callback:(void(^)(NSDictionary *result,NSError *error))block
{
	NSDictionary *params = @{@"appid":WechatAppId,@"secret":WechatAppSecret,@"code":code,@"grant_type":@"authorization_code"};
	[[NetworkManager sharedClient] postPath:kGETWXTOKENURL parameters:params withBlock:^(NSDictionary *result, NSError *error) {
		if(error) { if(block) { block(nil,error);} }
		else
		{
			if(!result[@"access_token"] || !result[@"openid"]){
				NSError *error = [NSError errorWithDomain:APIHOST code:0 userInfo:nil];
				if(block) { block(nil,error);}
				return ;
			}
			NSDictionary *paramers = @{@"access_token":result[@"access_token"],@"openid":result[@"openid"]};
			[[NetworkManager sharedClient] getPath:kGETWXUSERINFO parameters:paramers withBlock:^(NSDictionary *result, NSError *error){
				if(error) { if(block){ block(nil,error);} }
				else
				{
					NSString *auth_info = [result modelToJSONString];
					[[NetworkManager sharedClient] postPath:APIRegisterWX parameters:@{@"auth_info":auth_info} withBlock:^(NSDictionary *result, NSError *error){
						if(error) { if(block) { block(nil,error);} }
						else
						{
							dispatch_async(dispatch_get_main_queue(), ^{
								[UserInfoManager instance].noPSW = [result[@"data"][@"has_pwd"] boolValue];
								[[UserInfoManager instance] saveOtherToUserDefaults];
								if(block) { block(result,error);}
							});
						}
					}];
				}
			} useCache:NO];
		}
	}];
}

@end
