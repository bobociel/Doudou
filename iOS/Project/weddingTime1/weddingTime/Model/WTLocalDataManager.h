//
//  WTLocalDataManager.h
//  weddingTime
//
//  Created by 默默 on 15/9/29.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NESBaseModel.h"
#import "NESDBSync.h"
#import "SQLiteProtocol.h"
@interface WTLocalDataManager : NSObject
+(BOOL)insertToDBByModel:(NESBaseModel *)model;
+(id)selectModel:(Class)modelClass byId:(NSInteger)modelId;
@end

@interface UserInfo : NSObject <SQLiteProtocol>
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *group_id;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *phone;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end


@interface OrderList : NESBaseModel
@property (nonatomic, copy) NSString *order_id$pk;//自增key，前缀的名字不要和实际key一样
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *wedding_timestamp;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *trans_status;
@property (nonatomic, copy) NSString *trans_status_name;
@property (nonatomic, copy) NSString *out_trade_no;
@property (nonatomic, copy) NSString *child_orders;

+(BOOL)insertOrderListToDB:(NSDictionary*)order;
+(NSArray*)getOrderListFromDB;
+ (NSArray *)getPartnerOrderListfromDB;
@end

@interface OrderDetail : NESBaseModel
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *child_orders;
@property (nonatomic, copy) NSString *supplier_phone;
@property (nonatomic, copy) NSString *wedding_timestamp;
@property (nonatomic, copy) NSString *supplier_logo;
@property (nonatomic, copy) NSString *wedding_city;
@property (nonatomic, copy) NSString *child_title;
@property (nonatomic, copy) NSNumber *trans_status;
@property (nonatomic, copy) NSString *trans_status_name;
@property (nonatomic, assign) NSInteger order_id$pk;//自增key，前缀的名字不要和实际key一样
@property (nonatomic, copy) NSString *out_trade_no;
@property (nonatomic, copy) NSString *creater_username;
@property (nonatomic, copy) NSString *parent_title;
@property (nonatomic, copy) NSString *supplier_id;
@property (nonatomic, copy) NSString *supplier_company;

+(BOOL)insertOrderDetailToDB:(NSDictionary*)order;
+(OrderDetail*)getOrderDetailFromDB:(NSString*)out_trade_no;
+(NSArray*)getOrderDetailFromDB;
@end


