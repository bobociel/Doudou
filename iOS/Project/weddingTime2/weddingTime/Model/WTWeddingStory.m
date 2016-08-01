//
//  WTWeddingStory.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTWeddingStory.h"

@implementation WTWeddingStory

- (instancetype)init
{
    self = [super init];
    if(self){
        self.ID = 0;
        self.content = @"";
    }
    return self;
}

- (BOOL)hasSource
{
	return self != nil && (self.media.length > 0 || self.path > 0) ;
}

+ (NSDictionary *)modelCustomPropertyMapper
{
	return @{@"ID":@"id",
			 @"media_type":@"media_type",
			 @"content":@"content",
			 @"media":@"media",
			 @"path":@"path"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
