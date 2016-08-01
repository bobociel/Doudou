//
//  WTDemand.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,WTDemandStatus) {
	WTDemandStatusWait,
	WTDemandStatusChat,
	WTDemandStatusClose
};

@interface WTDemand : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, assign) WTDemandStatus status;
@property (nonatomic, assign) WTWeddingType service_id;
@property (nonatomic, copy) NSString *service_name;
@property (nonatomic, copy) NSString *city_name;
@property (nonatomic, copy) NSString *price_range_content;
@property (nonatomic, assign) double bid_num;
@property (nonatomic, assign) unsigned long long wedding_time;
@property (nonatomic, assign) unsigned long long create_time;
@end
