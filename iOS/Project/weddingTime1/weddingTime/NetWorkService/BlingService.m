//
//  BlingService.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/18.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BlingService.h"
#import "NetworkManager.h"
#import "RSA.h"
#import "UserInfoManager.h"
#import "WTProgressHUD.h"
#import <Base64.h>
#import "WTAlertView.h"
#import "UserInfoManager.h"
#import <UIImageView+WebCache.h>
//绑定另一半
#define APIBLINGPARTNERINVITE @"app/v020/u/invite/new"
//获得是邀请者或被邀请者及状态
#define APIBLINGINVITESTATE @"app/v020/u/invite"
//被邀请者接受邀请
#define APIACCEPTINVITE @"app/v020/u/invite/accept"
//被接受着拒绝邀请
#define APIREFUSEINVITE @"app/v020/u/invite/decline"

@interface BlingService ()
{
    NSDictionary *dic;
}
@end
@implementation BlingService

+ (void)blingPartnerWithPhone:(NSString *)phone block:(void (^)(NSDictionary *result, NSError *error))block {
    
//    RSA *rsa = [[RSA alloc] init];
    NSString *token = [UserInfoManager instance].tokenId_self;
    
//    NSString *numStr = [NSString
//                          stringWithFormat:@"%@",
//                          [[rsa encryptWithString:phone] base64EncodedString]];
    //疑问
    NSDictionary *params = @{
                             @"phone" : phone,
                             @"token" : token,
                             };
    
    [[NetworkManager sharedClient] postPath:APIBLINGPARTNERINVITE
                                 parameters:params
                                  withBlock:block];
}

+ (void)getInviteStateWithBlock:(void (^)(NSDictionary *result, NSError *error))block
{
    //疑问
    NSString *token = [UserInfoManager instance].tokenId_self;
    
    [[NetworkManager sharedClient] getPath:APIBLINGINVITESTATE parameters:@{@"token":token} withBlock:block  useCache:NO];
    
}

+ (void)acceptInviteWithBlock:(void (^)(NSDictionary *result, NSError *error))block
{
    //疑问
    NSString *token = [UserInfoManager instance].tokenId_self;
    
    [[NetworkManager sharedClient] getPath:APIACCEPTINVITE parameters:@{@"token":token} withBlock:block  useCache:NO];
    
}

+ (void)refuseInviteWithBlock:(void (^)(NSDictionary *result, NSError *error))block
{
    //疑问
    NSString *token = [UserInfoManager instance].tokenId_self;
    
    [[NetworkManager sharedClient] getPath:APIREFUSEINVITE parameters:@{@"token":token} withBlock:block  useCache:NO];
    
}



@end
