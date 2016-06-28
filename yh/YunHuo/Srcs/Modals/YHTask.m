//
//  YHTask.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHTask.h"

@implementation YHTask

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	EncodeObject(self.logo, aCoder);
	EncodeObject(self.title, aCoder);
	EncodeObject(self.desc, aCoder);
	EncodeObject(self.members, aCoder);
	EncodeObject(self.dueDate, aCoder);
	EncodeBool(self.isNotifOn, aCoder);
}

- (id) initWithCoder:(NSCoder*)aDecoder
{
	if  ( self = [super init] )
	{
		DecodeObject(self.logo, aDecoder);
		DecodeObject(self.title, aDecoder);
		DecodeObject(self.desc, aDecoder);
		DecodeObject(self.members, aDecoder);
		DecodeObject(self.dueDate, aDecoder);
		DecodeBool(self.isNotifOn, aDecoder);
	}
	return self;
}

@end
