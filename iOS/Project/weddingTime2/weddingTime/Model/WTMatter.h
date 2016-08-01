//
//  WTMatter.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/7.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,WTMatterStatus) {
	WTMatterStatusAll = 0,
	WTMatterStatusUnFinished = 1,
	WTMatterStatusFinished = 3
};

@interface WTMatter : NSObject
@property (nonatomic, copy) NSString *matter_id;
@property (nonatomic, assign) WTMatterStatus status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) unsigned long long create_time;
@property (nonatomic, assign) unsigned long long close_time;
@property (nonatomic, assign) unsigned long long remind_time;
@property (nonatomic, assign) unsigned long long finish_time;
@end
