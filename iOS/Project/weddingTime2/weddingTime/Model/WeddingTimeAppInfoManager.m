//
//  WeddingTimeAppInfoManager.m
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WeddingTimeAppInfoManager.h"
#import "UserInfoManager.h"
#import "UIImageView+WebCache.h"
#import "GetService.h"

@implementation WeddingTimeAppInfoManager
+ (WeddingTimeAppInfoManager *)instance {
    static WeddingTimeAppInfoManager *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[WeddingTimeAppInfoManager alloc] init];
    });
    return _instance;
}

+ (NSString *)shortVersion
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (double)currentVresionDouble
{
	return [WeddingTimeAppInfoManager versionDoubleWithVersion:[WeddingTimeAppInfoManager shortVersion]];
}

+ (double)versionDoubleWithVersion:(NSString *)versionString
{
	NSArray *versions= [versionString componentsSeparatedByString:@"."];
	double d1 = [versions[0] integerValue] * 10000;
	double d2 = [versions[1] integerValue] * 100;
	double d3 = [versions[2] integerValue] * 10;
	double d = d1 + d2 + d3;
	return d;
}

-(UIColor*)baseColor
{
    if (!_baseColor) {
        _baseColor=[LWUtil colorWithHexString:@"ff6499"];
    }
    return _baseColor;
}

+(UIFont*)fontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"STHeitiSC-Light" size:size];
}

+ (UIFont *)blodFontWithSize:(CGFloat)size
{
	return [UIFont fontWithName:@"Heiti SC" size:size];
}

-(NSMutableDictionary*)supplierOnlineStatus
{
    if (!_supplierOnlineStatus) {
        _supplierOnlineStatus=[NSMutableDictionary dictionary];
    }
    return _supplierOnlineStatus;
}

+ (NSArray *)defaultInspirationColors {
    return  @[
              @{@"color": @"#f26060", @"id": @(1), @"value": @"#f26060", @"name": @"红色婚礼"},
              @{@"color": @"#f15d94", @"id": @(2), @"value": @"#f15d94", @"name": @"玫红婚礼"},
              @{@"color": @"#fdb0b0", @"id": @(3), @"value": @"#fdb0b0", @"name": @"粉红婚礼"},
              @{@"color": @"#ffaf61", @"id": @(4), @"value": @"#ffaf61", @"name": @"橙色婚礼"},
              @{@"color": @"#f7de6a", @"id": @(5), @"value": @"#f7de6a", @"name": @"黄色婚礼"},
              @{@"color": @"#B4EEB4", @"id": @(6), @"value": @"#B4EEB4", @"name": @"薄荷绿婚礼"},
              @{@"color": @"#008B00", @"id": @(7), @"value": @"#008B00", @"name": @"墨绿婚礼"},
              @{@"color": @"#66cccc", @"id": @(8), @"value": @"#66cccc", @"name": @"Tiffany蓝婚礼"},
              @{@"color": @"#3CB3EB", @"id": @(9), @"value": @"#3CB3EB", @"name": @"天蓝婚礼"},
              @{@"color": @"#0304e5", @"id": @(10), @"value": @"#0304e5", @"name": @"宝蓝色婚礼"},
              @{@"color": @"#EEAEEE", @"id": @(11), @"value": @"#EEAEEE", @"name": @"浅紫色婚礼"},
              @{@"color": @"#C71585", @"id": @(12), @"value": @"#C71585", @"name": @"深紫色婚礼"},
              @{@"color": @"#b06f18", @"id": @(13), @"value": @"#b06f18", @"name": @"褐色婚礼"},
              @{@"color": @"#ffd700", @"id": @(14), @"value": @"#ffd700", @"name": @"金色婚礼"},
              @{@"color": @"#f6d5b2", @"id": @(15), @"value": @"#f6d5b2", @"name": @"裸色婚礼"},
              @{@"color": @"#CFCFCF", @"id": @(16), @"value": @"#CFCFCF", @"name": @"灰色婚礼"},
              @{@"color": @"#fefefe", @"id": @(17), @"value": @"#fefefe", @"name": @"白色婚礼"},
              @{@"color": @"#000000", @"id": @(18), @"value": @"#000000", @"name": @"黑色婚礼"}
              ];
}

+ (UIImage *)avatarPlcehold
{
    return [UIImage imageNamed:@"male_default"];
}

+ (UIImage *)avatarPlceholdSelf {
    return  [UserInfoManager instance].userGender==UserGenderMale?[UIImage imageNamed :@"male_default"]:[UIImage imageNamed :@"female_default"];
}

+ (UIImage *)avatarPlceholdPartner {
    return  [UserInfoManager instance].userGender==UserGenderMale?[UIImage imageNamed :@"female_default"]:[UIImage imageNamed :@"male_default"];
}

+(void)setMyAvatar:(id)myHeadImageView
{
    [self setImageWithUrl:[UserInfoManager instance].avatar_self forOb:myHeadImageView placehoderimg:[WeddingTimeAppInfoManager avatarPlceholdSelf]];
}

+(void)setPartnerAvatar:(id)partnerHeadImageView
{
    [self setImageWithUrl:[UserInfoManager instance].avatar_partner forOb:partnerHeadImageView placehoderimg:[WeddingTimeAppInfoManager avatarPlceholdPartner]];
}

+(void)setAvatar:(id)object userId:(NSString*)userId
{
    if ([userId isEqualToString:[UserInfoManager instance].userId_self]) {
        [self setMyAvatar:object];
    }
    else if ([userId isEqualToString:[UserInfoManager instance].userId_partner])
    {
        [self setPartnerAvatar:object];
    }
    else
    {
        UserInfo *userdic = [[SQLiteAssister sharedInstance] pullUserInfo:userId];
        [self setImageWithUrl:userdic.avatar forOb:object placehoderimg:[WeddingTimeAppInfoManager avatarPlcehold]];
    }
}

+(void)setImageWithUrl:(NSString*)url forOb:(id)object placehoderimg:(UIImage*)placeholder
{
    if ([object isKindOfClass:[UIImageView class]]) {
        UIImageView *imageview=(UIImageView*)object;
        UIImage *placehoderimg=imageview.image;
        if (!placehoderimg||![url isNotEmptyCtg]) {
            placehoderimg=placeholder;
        }
        
        [imageview sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placehoderimg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                imageview.image=placeholder;
            }
        }];
        
    }
    else if ([object isKindOfClass:[UIButton class]])
    {
        UIButton *btn=(UIButton*)object;
        UIImage *placehoderimg=btn.currentBackgroundImage;
        if (!placehoderimg||![url isNotEmptyCtg]) {
            placehoderimg=placeholder;
        }
        UIImageView *imageview=[UIImageView new];
        [imageview sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placehoderimg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                [btn setBackgroundImage:placeholder forState:UIControlStateNormal];
            }
            else
                [btn setBackgroundImage:imageview.image forState:UIControlStateNormal];
        }];
    }
}

+ (BOOL)openedNotification
{
	if(isEqualOrThanIOS8)
	{
		UIUserNotificationSettings *notificationSet = [[UIApplication sharedApplication] currentUserNotificationSettings];
		return notificationSet.types != UIUserNotificationTypeNone;
	}
	else
	{
		UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
		return type != UIRemoteNotificationTypeNone;
	}
}

+(void)checkUserNotificationSettings
{
    if (isEqualOrThanIOS8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
												UIUserNotificationTypeAlert   //弹出框
                                                | UIUserNotificationTypeBadge //状态栏
                                                | UIUserNotificationTypeSound //声音
                                                categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}

+ (void)checkVersion
{
    //检查版本更新
    [GetService getWeddingTimeVersionInfoWithBlock:^(NSDictionary *result, NSError *error) {
        if(!error){
            if([WeddingTimeAppInfoManager currentVresionDouble] < [WeddingTimeAppInfoManager versionDoubleWithVersion:result[@"version"]]){
                NSString *str = [NSString stringWithFormat:@"有新的版本更新是否前往更新？"];
                WTAlertView *alertView = [[WTAlertView alloc]initWithText:str centerImage:nil];
                [alertView setButtonTitles:@[@"取消",@"更新"]];
                [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                    [alertView close];
                    if(buttonIndex == 1){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"download_url"]]];
                    }
                }];
                [alertView show];
            }
		}else{
			[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""];
		}
    }];
}

@end
