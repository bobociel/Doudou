//
//  UserInfo.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/30.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<SQLiteProtocol>
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *group_id;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *phone;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end
