//
//  WTBless.h
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WTWeddingBless : NSObject
@property (nonatomic, copy) NSString *bless_id;
@property (nonatomic, copy) NSString *bless_name;
@property (nonatomic, copy) NSString *bless_avatar;
@property (nonatomic, copy) NSString *bless;
@property (nonatomic, copy) NSString *part_num;
@end

@interface WTWeddingDesk : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *member;
@property (nonatomic, copy) NSString *sort;
@end

@interface WTWeddingProcess : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) unsigned long long time;
@end