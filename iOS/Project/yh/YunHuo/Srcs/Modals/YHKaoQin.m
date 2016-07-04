//
//  YHKaoQin.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHKaoQin.h"

@implementation YHKaoQin

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	EncodeObject(self.time, aCoder);
	EncodeObject(self.location, aCoder);
	EncodeObject(self.address, aCoder);
	EncodeInt(self.type, aCoder);
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
	if ( self = [super init] )
	{
		DecodeObject(self.time, aDecoder);
		DecodeObject(self.location, aDecoder);
		DecodeObject(self.address, aDecoder);
		DecodeInt(self.type, aDecoder);
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"{KaoQin:{time:%@},{address:%@}",self.time,self.address];
}
@end
