//
//  LWAssistUtil.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "macrodefine.h"

typedef enum{
    NetWorkStatusTypeNone        = 0, //请勿复选
    NetWorkStatusTypeFail   = 1, //请勿复选
    NetWorkStatusTypeNoNetWork = 2<<1, //可复选
    NetWorkStatusTypeServerBad = 3<<2,
    NetWorkStatusTypeNoresult  = 4<<3,
    NetWorkStatusTypeNeedLogin = 5 //请勿复选
}NetWorkStatusType;

@interface LWAssistUtil : NSObject
//历史遗留
+ (NSString *)getCodeMessage:(NSError *)error
                  defaultStr:(NSString *)defaultStr noresultStr:(NSString*)noresultStr;
+ (NSString *)getCodeMessage:(NSError *)error
               andDefaultStr:(NSString *)defaultStr;
+ (NSString *)getCodeMessage:(NSError *)error
                 noresultStr:(NSString*)noresultStr customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock;
+ (NetWorkStatusType)getNetWorkStatusType:(NSError *)error;

//鼓励使用这个
+ (void)dealNetWorkServer:(NSError *)error successBlock:(void(^)())successBlock;
+ (void)dealNetWorkServer:(NSError *)error
             successBlock:(void(^)())successBlock defaultFailBlock:(void(^)(NSString*errorMsg))defaultFailBlock;
+ (void)dealNetWorkServer:(NSError *)error customFailBlock:(NSString*(^)(int status,NSString*msg))customFailBlock
             successBlock:(void(^)())successBlock defaultFailBlock:(void(^)(NSString*errorMsg))defaultFailBlock;

+ (NSString *)cellInfo:(id)info andDefaultStr:(NSString *)defaultStr;
+ (void)goSupplierHome:(NSString*)supplierId rootNav:(UIViewController*)controller;
+ (void)goHotelHome:(NSString*)supplierId rootNav:(UIViewController*)controller;
+(void)imageViewSetAsLineView:(UIImageView*)imageview color:(UIColor*)color;
+ (NSArray *)defaultSearchCitys;
+ (void)mp_setImageView:(UIImageView *)image withUrl:(NSString *)url;

+(BOOL)isLogin;
@end
