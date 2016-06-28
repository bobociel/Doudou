//
//  YHProject.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHProject.h"

static int nextPID = 0;

@interface YHProject()
@property (nonatomic,readonly) NSString *iconPath;

+ (NSString*) projectsIconCachePath;

@end

@implementation YHProject

- (instancetype) init
{
	if ( self = [super init] )
	{
		self.pid = nextPID++;
		self.logo = [UIImage imageNamed:@"ProjectDefaultIcon"];
		self.subProjects = [NSMutableArray array];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	EncodeInt(self.pid, aCoder);
//	EncodeObject(self.logo, aCoder);
	EncodeObject(self.title, aCoder);
	EncodeObject(self.desc, aCoder);
	EncodeObject(self.members, aCoder);
	EncodeObject(self.dueDate, aCoder);
	EncodeBool(self.isNotifOn, aCoder);
	EncodeObject(self.subProjects, aCoder);
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	[fm createDirectoryAtPath:[YHProject projectsIconCachePath] withIntermediateDirectories:YES attributes:nil error:&error];
	NSLog(@"create path for projects icon %@",[YHProject projectsIconCachePath]);
	if ( error != nil )
	{
		NSLog(@"create path for projects icon failed!!!");
	}
	[UIImagePNGRepresentation(self.logo) writeToFile:self.iconPath atomically:YES];
}

- (id) initWithCoder:(NSCoder*)aDecoder
{
	if  ( self = [super init] )
	{
		DecodeInt(self.pid, aDecoder);
//		DecodeObject(self.logo, aDecoder);
		DecodeObject(self.title, aDecoder);
		DecodeObject(self.desc, aDecoder);
		DecodeObject(self.members, aDecoder);
		DecodeObject(self.dueDate, aDecoder);
		DecodeBool(self.isNotifOn, aDecoder);
		DecodeObject(self.subProjects, aDecoder);
		
		if ( self.pid >= nextPID )
		{
			nextPID = self.pid+1;
		}
		
		//TBD
		self.logo = [UIImage imageWithContentsOfFile:self.iconPath];
		if ( self.logo == nil )
		{
			self.logo = [UIImage imageNamed:@"ProjectDefaultIcon"];
		}
	}
	return self;
}

+ (NSString*) projectsIconCachePath
{
	static NSString *cachePath = nil;
	if ( cachePath == nil )
	{
		cachePath = [NSHomeDirectory() stringByAppendingString:@"/Library/ProjectsIconCache/"];
	}
	return cachePath;
}

- (NSString*) iconPath
{
	return [[YHProject projectsIconCachePath] stringByAppendingFormat:@"projecticon_%d.png",self.pid];
}

+ (YHProject*) combineProjects:(NSArray*)projects withName:(NSString *)name
{
	YHProject *newProj = nil;
	if ( projects.count > 0 )
	{
		newProj = [[YHProject alloc] init];
		newProj.logo = [projects[0] logo];
		newProj.title = name;
		for ( YHProject *oldproj in projects )
		{
			if ( oldproj.subProjects.count > 0 )
			{
				[newProj.subProjects addObjectsFromArray:oldproj.subProjects];
			}
			else
			{
				[newProj.subProjects addObject:oldproj];
			}
		}
		
	}
	return newProj;
}
@end
