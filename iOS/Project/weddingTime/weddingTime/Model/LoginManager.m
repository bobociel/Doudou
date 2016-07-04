//
//  LoginManager.m
//  lovewith
//
//  Created by imqiuhang on 15/4/7.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "LoginManager.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "UserService.h"
#import "WTLoginViewController.h"
#import "WTMainViewController.h"
#import "QHNavigationController.h"

#define ERROR_NoresultCode                    404

@implementation LoginManager

- (void)loginWithPhone:(NSString *)phone andpassword:(NSString *)password {
    
	if(![phone isNotEmptyCtg]){
		[self loginFaildDelegate:@"请输入账号"];
		return ;
	}

    if (![password isNotEmptyCtg]) {
        [self loginFaildDelegate:@"请输入密码"];
        return;
    }
    
    [UserService loginWithEmail:phone password:password withBlock:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(loginSucceed:)]){
                [self.delegate loginSucceed:result];
                [[UserInfoManager instance] updateUserInfoFromServer];
            }
        }else {
            NSString *errStr = [LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""];
            if ([result[@"status"] intValue] == 4001) {
                errStr = @"账号密码不匹配";
            }
            
            [self loginFaildDelegate:errStr];
        }
    }];
}

+ (void)logoutWithFinishBlock:(void(^)())finish {
    if([[UserInfoManager instance].tokenId_self isNotEmptyCtg])
    {
        [[ChatMessageManager instance] closeClientWithCallback:^(BOOL succeeded, NSError *error) {
			[[UserInfoManager instance] exit];
			[((UINavigationController*)KEY_WINDOW.rootViewController) popToRootViewControllerAnimated:NO];
			[LoginManager pushToLoginViewControllerWithAnimation:YES];
			if(finish) { finish(); }
		}];
    }
}

+ (void)reblinding
{
    [UserInfoManager instance].tokenId_partner     = @"";
    [UserInfoManager instance].weddingTime         =  0;
    [UserInfoManager instance].avatar_partner      = @"";
    [UserInfoManager instance].username_partner    = @"";
    [UserInfoManager instance].phone_partner       = @"";
    [UserInfoManager instance].userId_partner      = @"";
    [UserInfoManager instance].userGender = UserGenderUnknow;
    [[UserInfoManager instance] saveToUserDefaults];
}

- (void)loginFaildDelegate:(NSString *)errInfo {
    if ([self.delegate respondsToSelector:@selector(logoutFaild:)]) {
        [self.delegate logoutFaild:errInfo];
    }
}

+ (void)loginSucceedAfter:(NSDictionary *)result
{
    [UserInfoManager instance].tokenId_self = [LWUtil getString:result[@"token"] andDefaultStr:[UserInfoManager instance].tokenId_self];
    
    [UserInfoManager instance].username_self = [LWUtil getString:result[@"username"] andDefaultStr:@""];
    [UserInfoManager instance].avatar_self = [LWUtil getString:result[@"avatar"] andDefaultStr:@""];
    
    [UserInfoManager instance].userId_self =[LWUtil getString:result[@"id"] andDefaultStr:@""];
    [UserInfoManager instance].userId_partner = [LWUtil getString:result[@"half_id"] andDefaultStr:@""];
    [UserInfoManager instance].username_partner = [LWUtil getString:result[@"half_username"] andDefaultStr:@""];
    [UserInfoManager instance].avatar_partner = [LWUtil getString:result[@"half_avatar"] andDefaultStr:@""];

	[UserInfoManager instance].weddingTime = [[LWUtil getNumber:result[@"wedding_timestamp"]] longLongValue];
	[UserInfoManager instance].domainName=[LWUtil getString:result[@"domain"] andDefaultStr:@""];
	[UserInfoManager instance].num_demand = [LWUtil getString:result[@"reward_count"] andDefaultStr:@""];
	[UserInfoManager instance].num_like = [LWUtil getString:result[@"follow_count"] andDefaultStr:@""];
	[UserInfoManager instance].num_order = [LWUtil getString:result[@"order_count"] andDefaultStr:@""];
	[UserInfoManager instance].wedding_address=[LWUtil getString:result[@"wedding_address"] andDefaultStr:@""];

    if ([LWUtil validatePhoneNumber:[LWUtil getString:result[@"half_phone"] andDefaultStr:@""]]) {
        [UserInfoManager instance].phone_partner =[LWUtil getString:result[@"half_phone"] andDefaultStr:@""];
    }
    
    if ([LWUtil validatePhoneNumber:[LWUtil getString:result[@"phone"] andDefaultStr:@""]]) {
        [UserInfoManager instance].phone_self =[LWUtil getString:result[@"phone"] andDefaultStr:@""];
    }
    
    if ([result[@"gender"] isEqualToString:@"m"]) {
        [UserInfoManager instance].userGender = UserGenderMale;
    }else {
        [UserInfoManager instance].userGender = UserGenderFemale;
    }

	NSArray *mapPoint = [[LWUtil getString:result[@"wedding_map_point"]  andDefaultStr:@""] componentsSeparatedByString:@","];
	if(mapPoint.count == 2){
		NSString *mapPointS = [NSString stringWithFormat:@"%@,%@",mapPoint[1],mapPoint[0]];
		[UserInfoManager instance].wedding_map_point = [LWUtil getString:mapPointS andDefaultStr:@""];
	}
    
    [[UserInfoManager instance] saveToUserDefaults];
    
    if([UserInfoManager instance].userId_self.length > 0 ){
        [[SQLiteAssister sharedInstance] loadDataBasePersonal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:reLoginNotify object:nil];
    
}

+(void)pushToLoginViewControllerWithAnimation:(BOOL)anmation
{
    QHNavigationController *nav =[[QHNavigationController alloc]initWithRootViewController:[WTLoginViewController new]];
    [KEY_WINDOW.rootViewController presentViewController:nav animated:anmation completion:nil];
}

+ (void)makeMainViewControllerWithAnimation:(BOOL)anmation
{
	QHNavigationController *nav =[[QHNavigationController alloc]initWithRootViewController:[WTMainViewController new]];
	KEY_WINDOW.rootViewController = nav;
}
@end
