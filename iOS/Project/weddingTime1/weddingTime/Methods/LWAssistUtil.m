//
//  LWAssistUtil.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "LWAssistUtil.h"
#import "UserInfoManager.h"
#import "WTSupplierViewController.h"
#import "QHNavigationController.h"
#import "UIImageView+ModePlacehoder.h"
@implementation LWAssistUtil
+ (NSString *)getCodeMessage:(NSError *)error
               andDefaultStr:(NSString *)defaultStr
{
    return [self getCodeMessage:error  defaultStr:defaultStr noresultStr:nil];
}

+ (NSString *)getCodeMessage:(NSError *)error
                  defaultStr:(NSString *)defaultStr noresultStr:(NSString*)noresultStr
{
    return [self getCodeMessage:error noresultStr:noresultStr defaultFailStr:defaultStr customFailBlock:nil];
}

+ (NSString *)getCodeMessage:(NSError *)error
                 noresultStr:(NSString*)noresultStr customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock{
     return [self getCodeMessage:error noresultStr:noresultStr defaultFailStr:nil customFailBlock:customFailBlock];
}

+ (NSString *)getCodeMessage:(NSError *)error
                 noresultStr:(NSString*)noresultStr defaultFailStr:(NSString *)defaultFailStr customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock{
    NetWorkStatusType type=[self getNetWorkStatusType:error];
    return [self getCodeMessage:type userInfo:error.userInfo noresultStr:noresultStr defaultFailStr:defaultFailStr customFailBlock:customFailBlock];
}

+ (NSString *)getCodeMessage:(NetWorkStatusType)type userInfo:(NSDictionary*)userInfo
                 noresultStr:(NSString*)noresultStr defaultFailStr:(NSString *)defaultFailStr customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock{
    NSString *errInfo;
    switch (type) {
        case NetWorkStatusTypeNeedLogin:
            errInfo = @"token过期，请重新登录";
            break;
        case NetWorkStatusTypeFail:
            if ([userInfo[@"status"] intValue]==1040) {
                if (![noresultStr isNotEmptyCtg]) {
                    noresultStr=@"暂时无结果";
                }
                errInfo = noresultStr;
            }
            else
            {
                if(![defaultFailStr isNotEmptyCtg])
                {
                    defaultFailStr=@"出问题啦，请稍后再试";
                }
                if(customFailBlock)
                {
                    errInfo = [self cellInfo:customFailBlock([userInfo[@"status"] intValue],userInfo[@"msg"]) andDefaultStr:defaultFailStr];
                }
                else
                {
                    errInfo = [self cellInfo:userInfo[@"msg"] andDefaultStr:defaultFailStr];
                }
            }
            break;
        case NetWorkStatusTypeServerBad:
            errInfo = @"服务器出现问题啦,请稍后";
            break;
        case NetWorkStatusTypeNoNetWork:
            errInfo = @"网络出现问题啦,请稍后";
            break;
        case NetWorkStatusTypeNoresult:
            if (![noresultStr isNotEmptyCtg]) {
                noresultStr=@"暂时无结果";
            }
            errInfo = noresultStr;
            break;
        case NetWorkStatusTypeNone:
            break;
        default:
            break;
    }
    return errInfo;
}

+ (NetWorkStatusType)getNetWorkStatusType:(NSError *)error
{
    if(error)
    {
        if (error.userInfo) {
            if ([error.userInfo[@"status"] intValue] == 1038) {
                return  NetWorkStatusTypeNeedLogin;
            } else {
                return  NetWorkStatusTypeFail;
            }
        }
        else
        {
            if (error.code == -1003 || error.code == 3840 || error.code == -1001) {
                return  NetWorkStatusTypeServerBad;
            } else if (error.code == -1009) {
                return NetWorkStatusTypeNoNetWork;
            } else if (error.code == 4004 || error.code == ERROR_NoresultCode) {
                return  NetWorkStatusTypeNoresult;
            }
        }
    }
    return NetWorkStatusTypeNone;
}

+ (void)dealNetWorkServer:(NSError *)error successBlock:(void(^)())successBlock
{
    [self dealNetWorkServer:error successBlock:successBlock defaultFailBlock:nil];
}

+ (void)dealNetWorkServer:(NSError *)error
             successBlock:(void(^)())successBlock defaultFailBlock:(void(^)(NSString*errorMsg))defaultFailBlock
{
    [self dealNetWorkServer:error  customFailBlock:nil successBlock:successBlock defaultFailBlock:defaultFailBlock];
}

+ (void)dealNetWorkServer:(NSError *)error customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock
             successBlock:(void(^)())successBlock defaultFailBlock:(void(^)(NSString*errorMsg))defaultFailBlock
{
    [self dealNetWorkServer:error noResultStr:nil defaultFailStr:nil customFailBlock:customFailBlock successBlock:successBlock failBlock:^(NSString *errorMsg, bool needLogin) {
        if (needLogin) {
            //todo
//            [LoginManager logoutWithFinishBlock:^{
//            }];
        }
        [WTProgressHUD ShowTextHUD:errorMsg showInView:KEY_WINDOW];
        if (defaultFailBlock) {
            defaultFailBlock(errorMsg);
        }
    }];
}

+ (void)dealNetWorkServer:(NSError *)error
              noResultStr:(NSString*)noResultStr defaultFailStr:(NSString *)defaultFailStr customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock successBlock:(void(^)())successBlock failBlock:(void(^)(NSString*errorMsg,bool needLogin))failBlock
{
    if(error)
    {
        NSString *errorInfo;
        bool needLogin=NO;
        if (error.userInfo) {
            if ([error.userInfo[@"status"] intValue] == 1038) {
                errorInfo=@"token过期，请重新登录";
                needLogin=YES;
            } else {
                if ([error.userInfo[@"status"] intValue]==1040) {
                    if (![noResultStr isNotEmptyCtg]) {
                        noResultStr=@"暂时无结果";
                    }
                    errorInfo = noResultStr;
                }
                else
                {
                    if(![defaultFailStr isNotEmptyCtg])
                    {
                        defaultFailStr=@"出问题啦，请稍后再试";
                    }
                    if(customFailBlock)
                    {
                        errorInfo = [self cellInfo:customFailBlock([error.userInfo[@"status"] intValue],error.userInfo[@"msg"]) andDefaultStr:defaultFailStr];
                    }
                    else
                    {
                        errorInfo = [self cellInfo:error.userInfo[@"msg"] andDefaultStr:defaultFailStr];
                    }
                }
            }
        }
        else
        {
            if (error.code == -1003 || error.code == 3840 || error.code == -1001) {
                errorInfo=@"服务器出现问题啦,请稍后";
            } else if (error.code == -1009) {
                errorInfo=@"网络出现问题啦,请稍后";
            } else if (error.code == 4004 || error.code == ERROR_NoresultCode) {
                if (![noResultStr isNotEmptyCtg]) {
                    noResultStr=@"暂时无结果";
                }
                errorInfo=noResultStr;
            }
        }
        if (failBlock) {
            failBlock(errorInfo,needLogin);
        }
    }
    else
    {
        if (successBlock) {
            successBlock();
        }
    }
}

+ (NSString *)cellInfo:(id)info andDefaultStr:(NSString *)defaultStr {
    if (!info) {
        return defaultStr;
    }
    
    if ([info isKindOfClass:[NSNull class]]) {
        return defaultStr;
    }
    
    if ([info isKindOfClass:[NSString class]]) {
        if ([info isNotEmptyWithSpace]) {
            if ([info isEqualToString:@"<null>"]) {
                return defaultStr;
            }
            return [NSString stringWithFormat:@"%@", info];
        } else {
            return defaultStr;
        }
    }
    
    return [NSString stringWithFormat:@"%@", info];
    
    return @"";
}
+ (void)goSupplierHome:(NSString*)supplierId rootNav:(UIViewController*)controller
{
    
    NSNumber *service_id = @([supplierId integerValue]);
    WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
    supplier.supplier_id = service_id;
    if (controller) {
        [controller.navigationController pushViewController:supplier animated:YES];
    }
    else
    {
        QHNavigationController *next=(QHNavigationController*)KEY_WINDOW.rootViewController;
        [next pushViewController:supplier animated:YES];
    }
}

+ (UIImage *)avatarPlceholdSelf {
    return  [UserInfoManager instance].userGender==UserGenderMale?[UIImage imageNamed :@"female_default"]:[UIImage imageNamed :@"male_default"];
}

+ (UIImage *)avatarPlceholdPartner {
    return  [UserInfoManager instance].userGender==UserGenderMale?[UIImage imageNamed :@"male_default"]:[UIImage imageNamed :@"female_default"];
}

+ (UIImage *)avatarPlcehold {
    return  [UIImage imageNamed :@"male_default"];
}

+ (void)goHotelHome:(NSString*)supplierId rootNav:(UIViewController*)controller
{
    
}

+(void)imageViewSetAsLineView:(UIImageView*)imageview color:(UIColor*)color
{
    imageview.contentMode=UIViewContentModeTop;
    imageview.image = [LWUtil imageWithColor:color frame:CGRectMake(0, 0, screenWidth, 0.5)];
}

+ (NSArray *)defaultSearchCitys {
    return @[
             @{
                 @"id" : @(0),
                 @"name" : @"全国"
                 },
             @{
                 @"id" : @(141),
                 @"name" : @"杭州"
                 },
             @{
                 @"id" : @(504),
                 @"name" : @"北京"
                 },
             @{
                 @"id" : @(506),
                 @"name" : @"上海"
                 },
             @{
                 @"id" : @(255),
                 @"name" : @"广州"
                 },
             @{
                 @"id" : @(128),
                 @"name" : @"南京"
                 },
             @{
                 @"id" : @(351),
                 @"name" : @"成都"
                 },
             @{
                 @"id" : @(505),
                 @"name" : @"天津"
                 },
             @{
                 @"id" : @(257),
                 @"name" : @"深圳"
                 },
             @{
                 @"id" : @(190),
                 @"name" : @"青岛"
                 },
             @{
                 @"id" : @(507),
                 @"name" : @"重庆"
                 },
             @{
                 @"id" : @(132),
                 @"name" : @"苏州"
                 },
             @{
                 @"id" : @(241),
                 @"name" : @"长沙"
                 },
             @{
                 @"id" : @(206),
                 @"name" : @"郑州"
                 },
             @{
                 @"id" : @(404),
                 @"name" : @"西安"
                 },
             @{
                 @"id" : @(224),
                 @"name" : @"武汉"
                 },
             @{
                 @"id" : @(169),
                 @"name" : @"福州"
                 },
             @{
                 @"id" : @(381),
                 @"name" : @"昆明"
                 },
             @{
                 @"id" : @(73),
                 @"name" : @"沈阳"
                 },
             @{
                 @"id" : @(74),
                 @"name" : @"大连"
                 },
             @{
                 @"id" : @(39),
                 @"name" : @"石家庄"
                 }
             ];
}

+ (void)mp_setImageView:(UIImageView *)image withUrl:(NSString *)url
{
    [image mp_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultPic"]];
}

+(BOOL)isLogin
{
    if(![[UserInfoManager instance].tokenId_self isNotEmptyCtg])    {
        [LoginManager pushToLoginViewControllerWithAnimation:YES];
        return NO;
    }
    return YES;
}
@end
