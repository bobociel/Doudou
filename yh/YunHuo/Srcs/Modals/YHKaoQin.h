//
//  YHKaoQin.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, YHKaoQinType)
{
	YHKaoQinTypeCheckIn,
	YHKaoQinTypeCheckOut,
};

@interface YHKaoQin : NSObject<NSCoding>
@property (nonatomic) NSDate		*time;
@property (nonatomic) CLLocation	*location;
@property (nonatomic,copy) NSString	*address;
@property (nonatomic) YHKaoQinType	type;
@end
