//
//  YHTask.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHTask : NSObject<NSCoding>
@property (nonatomic) UIImage			*logo;
@property (nonatomic,copy) NSString		*title;
@property (nonatomic,copy) NSString		*desc;
@property (nonatomic) NSMutableArray	*members;
//@property (nonatomic) id				*admin;
@property (nonatomic) NSDate			*dueDate;
@property (nonatomic) BOOL				isNotifOn;

@end