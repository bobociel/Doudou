//
//  WTInspiration.h
//  weddingTime
//
//  Created by 罗中华 on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTInspiration : NSObject
@property (nonatomic,copy) NSString *post_id;
@property (nonatomic,copy) NSString *share_id;
@property (nonatomic,copy) NSString *cover_id;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *attr_type;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *company;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *cover;
@property (nonatomic,strong) NSNumber *timestamp;

@property (nonatomic,assign) BOOL is_like;
@property (nonatomic,assign) BOOL is_video;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@end