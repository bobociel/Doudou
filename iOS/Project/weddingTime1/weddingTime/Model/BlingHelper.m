//
//  BlingHelper.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BlingHelper.h"
#import "BlingService.h"
#import "UserInfoManager.h"
#import <UIImageView+WebCache.h>
@interface BlingHelper ()

@end
@implementation BlingHelper
{
    NSDictionary *dic;
}


- (void)makeAlertWith:(NSDictionary *)result type:(int)type
{
    dic = result;
    NSString *str = [NSString stringWithFormat:@"%@邀请你成为另一半",result[@"partner_name"]];
    NSString *url = result[@"partner_avatar"];
    if (type == 1) {
      
        NSDictionary *partner = result[@"partner"];
        str = [NSString stringWithFormat:@"%@邀请你成为另一半",partner[@"username"]];
        url = partner[@"avatar"];
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView mp_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"male_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:str centerImage:image];
        //        alert.delegate = self;
        
        alert.buttonTitles = @[@"拒绝", @"确定"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            [alert close];
            
            if (index == 0) {
                [BlingService refuseInviteWithBlock:nil];
            } else if (index == 1) {
                NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
                
                [mu setObject:InviteState_double forKey:[UserInfoManager instance].userId_self];
                [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
                [[UserInfoManager instance] saveToUserDefaults];
                [BlingService acceptInviteWithBlock:^(NSDictionary *result, NSError *error) {
//                    [UserInfoManager instance].userId_partner = dic[@"id"];
//                    [UserInfoManager instance].username_partner = dic[@"username"];
//                    [UserInfoManager instance].avatar_partner = dic[@"avatar"];
                    [[UserInfoManager instance] updateUserInfoFromServer];
                }];
            }
            
        };
        [alert show];
    }];
}

- (void)makeRefuseAlertWith:(NSDictionary *)result
{
    dic = result;
    NSString *str = [NSString stringWithFormat:@"%@已经拒绝了你的邀请",result[@"partner_name"]]; //todo
    NSString *url = result[@"partner_avatar"];
    UIImageView *imageView = [[UIImageView alloc] init];
 
    [imageView mp_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"male_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:str centerImage:image];
        alert.buttonTitles = @[@"取消"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
            [mu setObject:InviteState_single forKey:[UserInfoManager instance].userId_self];
            [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
            [[UserInfoManager instance] saveToUserDefaults];
            [alert close];
        };
        
        [alert show];
    }];

}

- (void)makeSuccessAlertWith:(NSDictionary *)result
{
    [[UserInfoManager instance] updateUserInfoFromServer];
    dic = result;
    NSString *str = [NSString stringWithFormat:@"%@已经接受了你的邀请",result[@"partner_name"]]; //todo
    NSString *url = result[@"partner_avatar"];
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:str centerImage:image];
        alert.buttonTitles = @[@"确定"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){

            NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
            [mu setObject:InviteState_double forKey:[UserInfoManager instance].userId_self];
            [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
            [[UserInfoManager instance] saveToUserDefaults];
            [alert close];
        };
        
        [alert show];
    }];
}

- (void)makeCancelBindAlerWith:(NSDictionary *)result
{
    dic = result;
    NSString *str = [NSString stringWithFormat:@"%@已经解除了和你的绑定",result[@"partner_name"]]; //todo
    NSString *url = result[@"partner_avatar"];
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:str centerImage:image];
        alert.buttonTitles = @[@"确定"];
        [[UserInfoManager instance] updateUserInfoFromServer];
        NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
        [mu setObject:InviteState_single forKey:[UserInfoManager instance].userId_self];
        [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
        [[UserInfoManager instance]saveToUserDefaults];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            
            [alert close];
        };
        
        [alert show];
    }];

}

+ (void)updateInviteState
{
    
    if(![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
        [BlingService getInviteStateWithBlock:^(NSDictionary *result, NSError *error) {
            //            NSDictionary *data = result[@"data"];
            NSString *type = result[@"type"];
            if ([type isEqualToString:@"invitee"]) {
                BlingHelper *helper = [[BlingHelper alloc] init];
                [helper makeAlertWith:result type:1];
            }
        }];
    }
}




@end
