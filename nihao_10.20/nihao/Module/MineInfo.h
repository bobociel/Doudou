//
//  MineInfo.h
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineInfo : NSObject

@property (nonatomic, copy) NSString *ci_job;// 该客户的工作
@property (nonatomic, copy) NSString *ci_nikename;// 客户昵称
@property (nonatomic, copy) NSString *ci_email;// 该客户的邮箱
@property (nonatomic, copy) NSString *country_name_en;// 该客户的国家
@property (nonatomic, copy) NSString *ci_phone;// 该客户的手机
@property (nonatomic, copy) NSString *ci_header_img;// 该客户的头像地址
@property (nonatomic, assign) NSInteger byCount;// 关注该客户的人数
@property (nonatomic, assign) NSInteger ci_sex;// 客户性别
@property (nonatomic, assign) NSInteger ci_is_verified;// 是否认证
@property (nonatomic, assign) NSInteger ci_id;// 客户ID
@property (nonatomic, assign) NSInteger ci_age;// 该客户的年龄
@property (nonatomic, assign) NSInteger friend_type;// 查看者与该客户的关系
@property (nonatomic, assign) NSInteger relationCount;// 该客户关注的人数
@property (nonatomic, assign) NSUInteger ci_type;//用户类型
@property (nonatomic,copy) NSString *ci_city_id;//用户居住区域
@end
