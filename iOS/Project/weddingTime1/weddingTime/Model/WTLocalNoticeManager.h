//
//  WTLocalNoticeManager.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/7.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationControlCenter.h"
#import "WTMatter.h"

@interface WTLocalNoticeManager : NSObject
+ (instancetype)manager;

- (void)addNoticeWithObject:(NSObject *)object;
- (void)addNoticeWithObjectArray:(NSArray *)objectArray;
- (void)removeNoticeWithClassType:(Class)className andID:(NSString *)ID;

- (void)dealNotificationWithNotification:(UILocalNotification *)noti application:(UIApplication *)application;
@end

@interface NSNumber (Compare)
- (BOOL)isEqualToString:(NSString *)string;
@end