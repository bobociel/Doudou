//
//  WTLocalNoticeManager.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/7.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTLocalNoticeManager.h"
#import "WeddingPlanDetailViewController.h"
@implementation WTLocalNoticeManager

+ (instancetype)manager
{
	static WTLocalNoticeManager *manager ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[WTLocalNoticeManager alloc] init];
	});
	return manager;
}

- (instancetype)init
{
	self = [super init];
	if(self){

	}
	return self;
}

- (void)addNoticeWithObjectArray:(NSArray *)objectArray
{
	for (NSObject *object in objectArray)
	{
		[self addNoticeWithObject:object];
	}
}

- (void)addNoticeWithObject:(NSObject *)object
{
	if(!object) { return ;}
	NSString *ID ;
	NSDate *fireDate ;
	NSString *alertBody ;
	NSString *type = NSStringFromClass([object class]);
	if([object isKindOfClass:[WTMatter class]])
	{
		WTMatter *matter = (WTMatter *)object;
		ID = matter.matter_id;
		[self removeNoticeWithClassType:[object class] andID:ID];
		if(matter.remind_time < [[NSDate date] timeIntervalSince1970] ) { return; }
		fireDate = [NSDate dateWithTimeIntervalSince1970:matter.remind_time];
		alertBody = [NSString stringWithFormat:@"您有计划%@要完成。",matter.title];
	}

	UILocalNotification *notification = [[UILocalNotification alloc] init];
	if (notification != nil)
	{
		notification.userInfo = @{@"type":type,@"ID":ID};
		notification.fireDate = fireDate;
		notification.alertBody = alertBody;
		notification.timeZone = [NSTimeZone defaultTimeZone];
		notification.soundName = UILocalNotificationDefaultSoundName;
		notification.applicationIconBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1;
		
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	}
}

- (void)removeNoticeWithClassType:(Class)className andID:(NSString *)ID
{
	NSArray *noties = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *noti in noties)
	{
		if([noti.userInfo[@"type"] isEqualToString:NSStringFromClass(className)] && [noti.userInfo[@"ID"] isEqualToString:ID])
		{
			noti.applicationIconBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] - 1;
			[[UIApplication sharedApplication] cancelLocalNotification:noti];

			return ;
		}
	}
}

- (void)dealNotificationWithNotification:(UILocalNotification *)noti application:(UIApplication *)application;
{
	[self removeNoticeWithClassType:NSClassFromString(noti.userInfo[@"type"]) andID:noti.userInfo[@"ID"]];

	if(application.applicationState != UIApplicationStateActive)
	{
		[NotificationTopPush pushToPlanDetailWtihMatterID:noti.userInfo[@"ID"]];
	}
	else
	{
		[[NotificationControlCenter instance] pushTopViewOnKeyWindow:[UserInfoManager instance].avatar_self
															   title:@"提示"
															subTitle:noti.alertBody
																type:WTNotificationTopViewTypePlan
															 message:nil
															  object:noti.userInfo[@"ID"]];
	}
}

@end

@implementation NSNumber (Compare)
- (BOOL)isEqualToString:(NSString *)string
{
	return [self.stringValue isEqualToString:string];
}

@end
