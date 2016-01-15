//
//  AppDelegate.m
//  TestNotification
//
//  Created by wangxiaobo on 16/1/11.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "AppDelegate.h"
#import "YYKit/Model/NSObject+YYModel.h"
#define CheckString(value) ( value == nil || [value isKindOfClass:[NSNull class]] ) ? @"" : value;
#define CheckArray(value) ( value == nil || [value isKindOfClass:[NSNull class]] ) ? [@[] mutableCopy] : value;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.

	NSString *jsonString = @"{\"names\":null,\"genders\":null,\"tokens\":\"dasdasdad\",\"frdArray\":null,\"aUser\":{\"names\":null,\"genders\":null,\"tokens\":\"dasdasdad\",\"frdArray\":null}}";

	User *user = [User modelWithJSON:jsonString];

	NSLog(@"%@",[user modelToJSONObject]);

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

@implementation Friend
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
	Friend *frd = [super modelWithDictionary:dictionary];

	frd.name = CheckString(dictionary[@"name"]);
	frd.token = CheckString(dictionary[@"token"]);
	frd.frdArray = CheckArray(dictionary[@"array"]);

	return frd;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation User

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
	User *user = [super modelWithDictionary:dictionary];

	user.name = CheckString(dictionary[@"name"]);
	user.token = CheckString(dictionary[@"token"]);
	user.frdArray = CheckArray(dictionary[@"array"]);
	user.frd = [Friend modelWithDictionary:dictionary[@"aUser"]];

	return user;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
