//
//  WTLocalDataManager.m
//  weddingTime
//
//  Created by 默默 on 15/9/29.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WTLocalDataManager.h"
#import "UserInfoManager.h"
@interface WTLocalDataManager()
@property (nonatomic,retain) NESDBSync *dbNESDBSync;
+ (WTLocalDataManager *)instance;
@end
@implementation WTLocalDataManager
+ (WTLocalDataManager *)instance
{
    static WTLocalDataManager *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[WTLocalDataManager alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.dbNESDBSync = [[NESDBSync alloc]init];
        //        self.dbNESDBSync.path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"WTDataBase.db"];
    }
    return self;
}

+ (NSArray *)selectByModel:(NESBaseModel *)model
{
    if (![[WTLocalDataManager instance].dbNESDBSync isTableExists:[model class]]) {
        [[WTLocalDataManager instance].dbNESDBSync createTableWithModel:[model class]];
    }
    return [[WTLocalDataManager instance].dbNESDBSync selectByModel:model];
}

+(BOOL)insertToDBByModel:(NESBaseModel *)model
{
    if (![[WTLocalDataManager instance].dbNESDBSync isTableExists:[model class]]) {
        [[WTLocalDataManager instance].dbNESDBSync createTableWithModel:[model class]];
    }
    return [[WTLocalDataManager instance].dbNESDBSync insertByModel:model];
}

+(id)selectModel:(Class)modelClass byId:(NSInteger)modelId
{
    if (![[WTLocalDataManager instance].dbNESDBSync isTableExists:modelClass]) {
        [[WTLocalDataManager instance].dbNESDBSync createTableWithModel:modelClass];
    }
    return  [[WTLocalDataManager instance].dbNESDBSync selectModel:modelClass byId:modelId];
    // return [[WTLocalDataManager instance].dbNESDBSync selectAllByModel:modelClass][0];
}
+ (NSArray *)selectArray:(Class)modelClass
{
    if (![[WTLocalDataManager instance].dbNESDBSync isTableExists:modelClass]) {
        [[WTLocalDataManager instance].dbNESDBSync createTableWithModel:modelClass];
    }
    return [[WTLocalDataManager instance].dbNESDBSync selectAllByModel:modelClass];
}

@end

@implementation UserInfo

#pragma mark - Model
+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
	UserInfo *user = [UserInfo new];
	user.ID = [LWUtil getString:dict[@"id"] andDefaultStr:@""];
	user.name = [LWUtil getString:dict[@"name"] andDefaultStr:@""];
	user.group_id = [LWUtil getString:dict[@"group_id"] andDefaultStr:@""];
	user.avatar = [LWUtil getString:dict[@"avatar"] andDefaultStr:@""];
	user.phone = [LWUtil getString:dict[@"phone"] andDefaultStr:@""];
	return user;
}

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyWhitelist{
	return @[@"ID",@"group_id",@"name",@"phone",@"avatar"];
}


#pragma mark - SQLiteProtocol
- (NSString *)createTableSql{
	return @"CREATE TABLE IF NOT EXISTS user (id VARCHAR(20), name TEXT, group_id VARCHAR(20), avatar TEXT, phone VARCHAR(20), primary key (id))";
}

- (NSString *)replaceDataSql{
	return @"REPLACE INTO user (id, name, group_id, avatar, phone) values (:id, :name, :group_id, :avatar, :phone)";
}

- (NSString *)deleteDataSql{
	return  @"DELETE FROM user WHERE id = ?";
}

@end

@implementation OrderList

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.useDefaultPK = NO;
    }
    return self;
}


+(BOOL)insertOrderListToDB:(NSDictionary*)order
{
    OrderList *order_list=[OrderList model];
    [order_list mappingWithDictionary:order];
    
    order_list.order_id$pk=order[@"out_trade_no"] ;
    
    NSString *wedTime = order[@"update_time"];
    if ([wedTime isKindOfClass:[NSString class]]) {
        order_list.wedding_timestamp = wedTime;
    } else if ([wedTime isKindOfClass:[NSNumber class]]) {
        order_list.wedding_timestamp = [NSString stringWithFormat:@"%@", wedTime];
    }
    return [WTLocalDataManager insertToDBByModel:order_list];
}

+(NSArray*)getOrderListFromDB
{
    OrderList *order = [[OrderList alloc] init];
    order.user_id = [UserInfoManager instance].userId_self;
    NSArray *array = [WTLocalDataManager selectByModel:order];
//    NSArray *orders = [WTLocalDataManager selectArray:[OrderList class]];
    return array;
}

+ (NSArray *)getPartnerOrderListfromDB
{
    OrderList *order = [[OrderList alloc] init];
    order.user_id = [UserInfoManager instance].userId_partner;
    NSArray *array = [WTLocalDataManager selectByModel:order];
    return array;
}

@end

@implementation OrderDetail

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.useDefaultPK = NO;
    }
    return self;
}

+(BOOL)insertOrderDetailToDB:(NSDictionary*)order
{
    OrderDetail *order_detail=[OrderDetail model];
    [order_detail mappingWithDictionary:order];
    NSNumber *number = order[@"trans_status"];
    if ([number isKindOfClass:[NSString class]]) {
        int i = number.intValue;
        order_detail.trans_status = @(i);
    } else if ([number isKindOfClass:[NSNumber class]]) {
        order_detail.trans_status = number;
    }
    NSString *wedTime = order[@"wedding_timestamp"];
    if ([wedTime isKindOfClass:[NSString class]]) {
        order_detail.wedding_timestamp = wedTime;
    } else if ([wedTime isKindOfClass:[NSNumber class]]) {
        order_detail.wedding_timestamp = [NSString stringWithFormat:@"%@", wedTime];
    }
    order_detail.parent_title = order[@"order_status"];
    order_detail.child_title = order[@"order_operation"];
//    [order_detail setId:[order[@"out_trade_no"]integerValue]];
    order_detail.order_id$pk=[order[@"out_trade_no"] integerValue];
    order_detail.user_id = [UserInfoManager instance].userId_self;
    return [WTLocalDataManager insertToDBByModel:order_detail];
}

+(NSArray*)getOrderDetailFromDB
{
    
    NSArray *orders = [WTLocalDataManager selectArray:[OrderDetail class]];
    return orders;
}

+(OrderDetail*)getOrderDetailFromDB:(NSString*)out_trade_no
{
    OrderDetail *order_detail_temp = [[OrderDetail alloc] init];
    order_detail_temp.out_trade_no = out_trade_no;
    order_detail_temp.user_id = [UserInfoManager instance].userId_self;
    NSArray *array = [WTLocalDataManager selectByModel:order_detail_temp];
    OrderDetail *order_detail;
    if (array.count > 0) {
        order_detail = array[0];
    }
//    order_detail.out_trade_no$pk=out_trade_no;
    return order_detail;
}
@end
