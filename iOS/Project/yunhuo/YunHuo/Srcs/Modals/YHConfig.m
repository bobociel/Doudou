//
//  YHConfig.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/12.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHConfig.h"
#import "YHYunHuoPageInfo.h"

static YHConfig *_instance = nil;

@interface YHConfig()
@property (nonatomic,readonly) NSString *yunhuoPagesConfigPath;

@end

@implementation YHConfig

+ (YHConfig*) instance
{
	@synchronized([YHConfig class])
	{
		if ( _instance == nil )
		{
			_instance = [[YHConfig alloc] init];
		}
		return _instance;
	}
}

- (instancetype) init
{
	if ( self = [super init] )
	{
		self.lastLanuchTime = [NSDate date];
		self.lanuchedBefore = NO;
		self.projectsLanuchedBefore = NO;
	}
	return self;
}

- (void) load
{
	NSArray *data = [NSArray arrayWithContentsOfFile:self.yunhuoPagesConfigPath];
	if ( data.count == 0 )
	{
		data = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YunHuoPages" ofType:@"plist"]];
		[data writeToFile:self.yunhuoPagesConfigPath atomically:YES];
	}
	
	self.yunhuoPages = [NSMutableArray array];
	for ( int i = 0; i < data.count; ++i )
	{
		[self.yunhuoPages addObject:[[YHYunHuoPageInfo alloc] initWithDictionary:data[i]]];
	}
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	self.lanuchedBefore = [userDefault boolForKey:@"lanuchedBefore"];
	self.projectsLanuchedBefore = [userDefault boolForKey:@"projectsLanuchedBefore"];
	self.lastLanuchTime = [userDefault objectForKey:@"lastLanuchTime"];
}

- (void) save
{
//	NSError *error = nil;
//	[[NSFileManager defaultManager] removeItemAtPath:self.yunhuoPagesConfigPath error:&error];
	NSMutableArray *data = [NSMutableArray array];
	for ( YHYunHuoPageInfo *page in self.yunhuoPages )
	{
		[data addObject:[page toDictionary]];
	}
	[data writeToFile:self.yunhuoPagesConfigPath atomically:YES];
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setBool:self.lanuchedBefore forKey:@"lanuchedBefore"];
	[userDefault setBool:self.projectsLanuchedBefore forKey:@"projectsLanuchedBefore"];
	[userDefault setObject:self.lastLanuchTime forKey:@"lastLanuchTime"];
	
	[userDefault synchronize];
}

- (NSArray*) getVisibleYunHuoPages
{
	NSMutableArray *visiblepages = [NSMutableArray array];
	for ( YHYunHuoPageInfo *page in self.yunhuoPages )
	{
		if ( page.enabled )
		{
			[visiblepages addObject:page];
		}
	}
	return visiblepages;
}

- (NSString*) yunhuoPagesConfigPath
{
	NSString * string = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [string stringByAppendingString:@"/YunHuoPages.plist"];
}
@end
