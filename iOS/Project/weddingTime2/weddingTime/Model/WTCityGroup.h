//
//  WTCityGroup.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/27.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTCity : NSObject
@property (nonatomic, strong) NSString *cityID;
@property (nonatomic, strong) NSString *cityName;
@end

@interface WTCityGroup : NSObject
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSMutableArray *arrayCitys;
@end

