//
//  NSDate+AlarmClock.m
//  LiCai
//
//  Created by yuyunfeng on 14-9-5.
//
//

#import "NSDate+AlarmClock.h"

@implementation NSDate (AlarmClock)

- (void) setAlarmClock:(NSString*)title
{
	//建立后台消息对象
	UILocalNotification *notification=[[UILocalNotification alloc] init];
	if ( notification != nil )
	{
		notification.repeatInterval = NSDayCalendarUnit;
		notification.fireDate = self;
		notification.timeZone = [NSTimeZone defaultTimeZone];
		notification.soundName = @"tap.aif";
		notification.alertBody = title;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	}
}

@end
