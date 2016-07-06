//
//  TouchViewModel.m
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "YHYunHuoPageInfo.h"

@implementation YHYunHuoPageInfo

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.icon forKey:@"Icon"];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super init] )
	{
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.icon = [aDecoder decodeObjectForKey:@"Icon"];
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary*)dict
{
    if ( self = [super init] )
	{
        self.name = dict[@"Name"];
        self.icon = dict[@"Icon"];
		self.index = [dict[@"ID"] integerValue];
		self.enabled = [dict[@"Enabled"] boolValue];
		self.pageControllerClass = dict[@"Controller"];
    }
    return self;
}

- (NSDictionary*) toDictionary
{
	return @{@"Name":self.name,@"Icon":self.icon,@"index":@(self.index),@"Enabled":@(self.enabled),@"Controller":self.pageControllerClass};
}
@end
