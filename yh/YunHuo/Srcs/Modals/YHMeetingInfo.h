//
//  YHMeetingInfo.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHMeetingInfo : NSObject
@property (nonatomic) NSDate			*meetingTime;
@property (nonatomic) NSMutableArray	*attendees;
@property (nonatomic) NSMutableArray	*topics;
@property (nonatomic) int				hostIndex;
@property (nonatomic) NSMutableArray	*attachments;

@end
