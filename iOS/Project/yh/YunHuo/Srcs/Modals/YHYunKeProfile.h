//
//  YHYunKeProfile.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHDBStorage.h"

@interface YHYunKeProfile : NSObject<NSCoding,YHDBStorage>
@property (nonatomic) unsigned long long	phone;
@property (nonatomic,copy) NSString			*name;
@property (nonatomic,copy) NSString			*email;
@property (nonatomic) int					gender;
@property (nonatomic,copy) NSString			*avatarURLStr;
@property (nonatomic) UIImage				*avatar;

@end
